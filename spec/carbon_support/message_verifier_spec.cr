require "../spec_helper"

module CarbonSupportTest
  verifier = CarbonSupport::MessageVerifier.new("Hey, I'm a secret!")
  data_hash = {"some" => "data", "now" => Time.new(2010, 1, 1).epoch}.to_json

  describe CarbonSupport::MessageVerifier do
    it "valid_message" do
      data, hash = verifier.generate(data_hash).split("--")
      verifier.valid_message?(nil).should be_falsey
      verifier.valid_message?("").should be_falsey
      verifier.valid_message?("#{data.reverse}--#{hash}").should be_falsey
      verifier.valid_message?("#{data}--#{hash.reverse}").should be_falsey
      verifier.valid_message?("purejunk").should be_falsey
    end

    it "simple_round_tripping" do
      message = verifier.generate(data_hash)
      verifier.verified(message).should eq data_hash
      verifier.verify(message).should eq data_hash
    end

    it "verified_returns_false_on_invalid_message" do
      verifier.verified("purejunk").should be_falsey
    end

    it "verify_exception_on_invalid_message" do
      expect_raises(CarbonSupport::MessageVerifier::InvalidSignature) do
        verifier.verify("purejunk")
      end
    end
  end
end
