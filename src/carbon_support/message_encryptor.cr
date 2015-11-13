require "json"
require "openssl/cipher"

module CarbonSupport
  class MessageEncryptor
    class InvalidMessage < Exception
    end

    def initialize(@secret, @cipher = "aes-256-cbc", @digest = :sha1, @sign_secret = nil)
      @verifier = MessageVerifier.new(@sign_secret || @secret, digest: @digest)
    end

    # Encrypt and sign a message. We need to sign the message in order to avoid
    # padding attacks. Reference: http://www.limited-entropy.com/padding-oracle-attacks.
    def encrypt_and_sign(value)
      verifier.generate(_encrypt(value))
    end

    # Decrypt and verify a message. We need to verify the message in order to
    # avoid padding attacks. Reference: http://www.limited-entropy.com/padding-oracle-attacks.
    def decrypt_and_verify(value)
      _decrypt(verifier.verify(value))
    end

    private def _encrypt(value)
      cipher = new_cipher
      cipher.encrypt
      cipher.key = @secret

      # Rely on OpenSSL for the initialization vector
      iv = cipher.random_iv

      encrypted_data = MemoryIO.new
      encrypted_data.write(cipher.update(value))
      encrypted_data.write(cipher.final)

      "#{::Base64.strict_encode encrypted_data.to_slice}--#{::Base64.strict_encode iv}"
    end

    private def _decrypt(encrypted_message : String)
      cipher = new_cipher
      encrypted_data, iv = encrypted_message.split("--").map { |v| ::Base64.decode(v) }

      cipher.decrypt
      cipher.key = @secret
      cipher.iv = iv

      decrypted_data = MemoryIO.new
      decrypted_data.write cipher.update(encrypted_data)
      decrypted_data.write cipher.final
      # def assert_not_verified(value)
      #   assert_raise(ActiveSupport::MessageVerifier::InvalidSignature) do
      #     @encryptor.decrypt_and_verify(value)
      #   end
      # end
      JSON.parse([decrypted_data.to_s].to_json)[0] # TODO: find a better way to check string


    rescue OpenSSL::Cipher::Error | InvalidByteSequenceError
      raise InvalidMessage.new
    end

    private def new_cipher
      OpenSSL::Cipher.new(@cipher)
    end

    private def verifier
      @verifier
    end
  end
end
