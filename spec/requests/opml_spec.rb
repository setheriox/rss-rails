require 'rails_helper'

RSpec.describe "Opmls", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/opml/index"
      expect(response).to have_http_status(:success)
    end
  end

end
