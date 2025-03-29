# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class DNSimple < OmniAuth::Strategies::OAuth2
      option :name, :dnsimple

      # This allows overriding the OAuth endpoints via environment variables
      AUTH_URL = ENV.fetch("DNSIMPLE_AUTH_URL", "https://dnsimple.com")
      API_URL = ENV.fetch("DNSIMPLE_API_URL", "https://api.dnsimple.com")
      
      private_constant :AUTH_URL, :API_URL

      option :client_options, {
        site: API_URL,
        authorize_url: "#{AUTH_URL}/oauth/authorize",
        token_url: "#{API_URL}/v2/oauth/access_token"
      }

      option :token_method, :post
      option :auth_scheme, :request_body
      option :client_params_in_body, true
      
      # Configure whether we make another API call to DNSimple to fetch
      # additional account info
      option :fetch_info, true

      uid do
        access_token.params["account_id"] || (raw_info["data"]["account"]["id"].to_s if raw_info.dig("data", "account"))
      end

      info do
        if options.fetch_info && raw_info.dig("data", "account")
          {
            name: raw_info["data"]["account"]["email"],
            email: raw_info["data"]["account"]["email"]
          }
        else
          { name: "DNSimple user" } # only mandatory field
        end
      end

      extra do
        if options.fetch_info
          { raw_info: raw_info }
        else
          {}
        end
      end

      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end

      # override method in OmniAuth::Strategies::OAuth2 to error
      # when we don't have a client_id or secret:
      def request_phase
        if missing_client_id?
          fail!(:missing_client_id)
        elsif missing_client_secret?
          fail!(:missing_client_secret)
        else
          super
        end
      end

      private

      def raw_info
        @raw_info ||= access_token.get('v2/whoami').parsed
      rescue StandardError
        {}
      end

      def missing_client_id?
        [nil, ""].include?(options.client_id)
      end

      def missing_client_secret?
        [nil, ""].include?(options.client_secret)
      end
    end
  end
end 