require "../../spec_helper"

def assert_equal(first, other)
  first.to_s.should eq other.to_s
end

def assert_match(regex, str)
  !!(regex =~ str)
end

class TestView < CarbonView::Base
end

module CarbonViewTest
  describe CarbonView::Helpers::AssetUrlHelper do
    it "returns an asset path" do
      puts TestView.new.asset_path("image.png")
      puts TestView.new.javascript_path("script.js")
      puts TestView.new.audio_path("track.mp3")
      puts TestView.new.asset_path("style.css")
    end
  end
end
