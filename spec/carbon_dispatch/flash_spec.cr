def flash
  json = <<-JSON
          {
            "discard": ["alert"], "flashes": {"notice": "success"}
          }
        JSON
  CarbonDispatch::Flash::FlashHash.from_session_value(json)
end

class CarbonDispatch::Flash
  describe FlashHash do
    it "loads from the session value and sweeps" do
      flash.@flashes.should eq({"notice" => "success"})
      flash.@discard.should eq(Set(String).new(["notice"]))
    end

    it "returns the keys" do
      flash.keys.should eq ["notice"]
    end

    it "handles key?" do
      flash.has_key?("notice").should eq true
      flash.has_key?("invalid").should eq false
    end

    it "deletes a key" do
      flash = flash
      flash.delete("notice").should eq flash
      flash.has_key?("notice").should eq false
    end
  end
end
