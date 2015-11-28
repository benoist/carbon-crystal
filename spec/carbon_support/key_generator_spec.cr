require "../spec_helper"

module CarbonSupportTest
  describe CarbonSupport::KeyGenerator do
    secret = SecureRandom.hex(64)
    generator = CarbonSupport::KeyGenerator.new(secret, iterations: 2)

    it "Generating a key of the default length" do
      derived_key = generator.generate_key("some_salt")
      derived_key.should be_a(Slice(UInt8))
      derived_key.size.should eq 64
    end

    it "Generating a key of an alternative length" do
      derived_key = generator.generate_key("some_salt", 32)
      derived_key.should be_a(Slice(UInt8))
      derived_key.size.should eq 32
    end
  end

  describe CarbonSupport::KeyGenerator do
    secret = SecureRandom.hex(64)
    generator = CarbonSupport::KeyGenerator.new(secret, iterations: 2)
    caching_generator = CarbonSupport::CachingKeyGenerator.new(generator)

    it "Generating a cached key for same salt and key size" do
      derived_key = caching_generator.generate_key("some_salt", 32)
      cached_key = caching_generator.generate_key("some_salt", 32)

      cached_key.should eq derived_key
    end

    it "Does not cache key for different salt" do
      derived_key = caching_generator.generate_key("some_salt", 32)
      different_salt_key = caching_generator.generate_key("other_salt", 32)

      derived_key.should_not eq different_salt_key
    end

    it "Does not cache key for different length" do
      derived_key = caching_generator.generate_key("some_salt", 32)
      different_length_key = caching_generator.generate_key("some_salt", 64)

      derived_key.should_not eq different_length_key
    end
  end
end
