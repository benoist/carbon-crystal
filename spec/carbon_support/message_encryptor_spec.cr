require "../spec_helper"

macro assert_not_decrypted(value)
  expect_raises(CarbonSupport::MessageEncryptor::InvalidMessage) do
    encryptor.decrypt_and_verify(verifier.generate({{value.id}}))
  end
end

macro assert_not_verified(value)
  expect_raises(CarbonSupport::MessageVerifier::InvalidSignature) do
    encryptor.decrypt_and_verify({{value.id}})
  end
end

module CarbonSupportTest
  secret = SecureRandom.hex(64)
  verifier = CarbonSupport::MessageVerifier.new(secret)
  encryptor = CarbonSupport::MessageEncryptor.new(secret)
  data_hash = {"some" => "data", "now" => Time.new(2010, 1, 1).to_s}.to_json

  describe CarbonSupport::MessageEncryptor do
    it "encrypting_twice_yields_differing_cipher_text" do
      first_message = encryptor.encrypt_and_sign(data_hash).split("--").first
      second_message = encryptor.encrypt_and_sign(data_hash).split("--").first
      first_message.should_not eq second_message
    end

    it "messing_with_either_encrypted_values_causes_failure" do
      text, iv = verifier.verify(encryptor.encrypt_and_sign(data_hash)).split("--")
      assert_not_decrypted([iv, text].join "--")
    end

    it "messing_with_verified_values_causes_failures" do
      text, iv = encryptor.encrypt_and_sign(data_hash).split("--")
      assert_not_verified([iv, text].join "--")
    end

    it "signed_round_tripping" do
      message = encryptor.encrypt_and_sign(data_hash)
      String.new(encryptor.decrypt_and_verify(message)).should eq data_hash
    end
  end
end
