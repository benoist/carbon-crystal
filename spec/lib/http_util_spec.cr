require "../spec_helper"

describe HTTPUtil do
  context ".status_code" do
    it "returns the HTTP status code for the given status Symbol or String" do
      status_code = HTTPUtil.status_code(:ok)
      status_code.should eq(200)

      status_code = HTTPUtil.status_code("ok")
      status_code.should eq(200)

      status_code = HTTPUtil.status_code(:unprocessable_entity)
      status_code.should eq(422)

      status_code = HTTPUtil.status_code("unprocessable_entity")
      status_code.should eq(422)

      status_code = HTTPUtil.status_code(:non_authoritative_information)
      status_code.should eq(203)

      status_code = HTTPUtil.status_code("non_authoritative_information")
      status_code.should eq(203)
    end

    it "returns the given status as Int32, when the given status is NOT a Symbol or String" do
      status_code = HTTPUtil.status_code(201)
      status_code.should eq(201)

      status_code = HTTPUtil.status_code(502.32)
      status_code.should eq(502)
    end

    it "returns the HTTP status code 500, when the given status is NOT existing" do
      status_code = HTTPUtil.status_code(:not_ok)
      status_code.should eq(500)

      status_code = HTTPUtil.status_code("not_ok")
      status_code.should eq(500)

      status_code = HTTPUtil.status_code(:coffeepot)
      status_code.should eq(500)

      status_code = HTTPUtil.status_code("coffeepot")
      status_code.should eq(500)
    end
  end
end
