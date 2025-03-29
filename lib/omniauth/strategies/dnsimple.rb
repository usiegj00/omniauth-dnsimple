# frozen_string_literal: true

require "omniauth-oauth2"
require "net/http"
require "json"

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

      # Override method in OmniAuth::Strategies::OAuth2 to error
      # when we don't have a client_id or secret
      def request_phase
        if missing_client_id?
          fail!(:missing_client_id)
        elsif missing_client_secret?
          fail!(:missing_client_secret)
        else
          super
        end
      end
      
      # Override the build_access_token method to manually handle the token request
      def build_access_token
        code = request.params['code']
        state = request.params['state']
        
        # Create the token request manually
        uri = URI.parse(options.client_options.token_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data({
          'grant_type' => 'authorization_code',
          'client_id' => options.client_id,
          'client_secret' => options.client_secret,
          'code' => code,
          'redirect_uri' => callback_url,
          'state' => state
        })
        
        response = http.request(request)
        
        if response.code.to_i == 200
          data = JSON.parse(response.body)
          ::OAuth2::AccessToken.from_hash(client, data)
        else
          error_msg = "Failed to get access token: #{response.code} - #{response.body}"
          raise ::OAuth2::Error.new(OpenStruct.new(status: response.code, body: response.body))
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