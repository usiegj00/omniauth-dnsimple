require "spec_helper"
require "omniauth-oauth2"

RSpec.describe OmniAuth::Strategies::DNSimple do
  let(:app) do
    lambda do |env|
      [200, {}, ["Hello World"]]
    end
  end

  let(:request) { double("Request", params: {}, cookies: {}, env: {}) }
  let(:options) { {} }

  subject do
    OmniAuth::Strategies::DNSimple.new(app, "client_id", "client_secret", options).tap do |strategy|
      allow(strategy).to receive(:request) { request }
    end
  end

  describe "client options" do
    it "has correct name" do
      expect(subject.options.name).to eq(:dnsimple)
    end

    it "has correct site" do
      expect(subject.options.client_options.site).to eq("https://api.dnsimple.com")
    end

    it "has correct authorize url" do
      expect(subject.options.client_options.authorize_url).to eq("https://dnsimple.com/oauth/authorize")
    end

    it "has correct token url" do
      expect(subject.options.client_options.token_url).to eq("https://api.dnsimple.com/v2/oauth/access_token")
    end
  end

  describe "info" do
    before do
      allow(subject).to receive(:raw_info).and_return(
        "data" => {
          "user" => {
            "id" => 1234,
            "email" => "user@example.com"
          },
          "account" => {
            "id" => 5678,
            "email" => "user@example.com"
          }
        }
      )
    end

    context "when fetch_info is true" do
      let(:options) { { fetch_info: true } }

      it "returns the email" do
        expect(subject.info[:email]).to eq("user@example.com")
      end

      it "returns the name" do
        expect(subject.info[:name]).to eq("user@example.com")
      end
    end

    context "when fetch_info is false" do
      let(:options) { { fetch_info: false } }

      it "returns a generic name" do
        expect(subject.info[:name]).to eq("DNSimple user")
      end
    end
  end

  describe "uid" do
    context "when access_token.params has account_id" do
      before do
        allow(subject).to receive_message_chain(:access_token, :params).and_return({ "account_id" => "1234" })
      end

      it "returns the account_id from access_token params" do
        expect(subject.uid).to eq("1234")
      end
    end

    context "when access_token.params does not have account_id" do
      before do
        allow(subject).to receive_message_chain(:access_token, :params).and_return({})
        allow(subject).to receive(:raw_info).and_return(
          "data" => {
            "account" => {
              "id" => 5678
            }
          }
        )
      end

      it "returns the account id from raw_info" do
        expect(subject.uid).to eq("5678")
      end
    end
  end

  describe "extra" do
    let(:raw_info) do
      {
        "data" => {
          "user" => {
            "id" => 1234,
            "email" => "user@example.com"
          },
          "account" => {
            "id" => 5678,
            "email" => "user@example.com"
          }
        }
      }
    end

    before do
      allow(subject).to receive(:raw_info).and_return(raw_info)
    end

    context "when fetch_info is true" do
      let(:options) { { fetch_info: true } }

      it "returns the raw_info" do
        expect(subject.extra).to eq({ raw_info: raw_info })
      end
    end

    context "when fetch_info is false" do
      let(:options) { { fetch_info: false } }

      it "returns an empty hash" do
        expect(subject.extra).to eq({})
      end
    end
  end

  describe "#request_phase" do
    context "with no client id" do
      before do
        allow(subject).to receive(:options).and_return(double(client_id: nil, client_secret: "valid"))
      end

      it "calls fail! with :missing_client_id" do
        expect(subject).to receive(:fail!).with(:missing_client_id)
        subject.request_phase
      end
    end

    context "with no client secret" do
      before do
        allow(subject).to receive(:options).and_return(double(client_id: "valid", client_secret: nil))
      end

      it "calls fail! with :missing_client_secret" do
        expect(subject).to receive(:fail!).with(:missing_client_secret)
        subject.request_phase
      end
    end
  end
end 