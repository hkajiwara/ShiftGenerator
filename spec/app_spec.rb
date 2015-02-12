require File.dirname(__FILE__) + '/spec_helper'

describe "ShiftGen app" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  context "when accessing / via GET" do
    it "returns a valid response" do
      get '/'
      expect(last_response).to be_ok
    end
  end

  context "when accessing /generate via GET" do
    it "returns a valid response" do
      get '/generate'
      expect(last_response).to be_ok
    end
  end

  context "when accessing /help via GET" do
    it "returns a valid response" do
      get '/help'
      expect(last_response).to be_ok
    end
  end

  context "when accessing /NotExistPage via GET" do
    it "returns an invalid response of 404 Not Found" do
      get '/NotExistPage'
      expect(last_response.status).to eq(404)
    end
  end

  context "when accessing /shift via POST" do
    it "returns a valid response" do
      post '/shift', params={members: "", 
                              member_assignments0: "", 
                              time_assignments0: "",
                              member_assignments1: "", 
                              time_assignments1: "",
                              member_assignments2: "", 
                              time_assignments2: ""
                            }
      expect(last_response.status).to eq(200)
    end
  end
end