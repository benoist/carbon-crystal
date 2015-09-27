require "../spec_helper"

describe FileString do
  context "#join" do
    it "joins the paths" do
      FileString.new("some/").join("/path").to_s.should eq "some/path"
    end
  end
end
