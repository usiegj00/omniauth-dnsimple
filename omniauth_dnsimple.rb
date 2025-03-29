require 'omniauth-oauth2'
require 'net/http'
require 'json'

module OmniAuth
  module Strategies
    class Dnsimple < OmniAuth::Strategies::OAuth2
      option :name, :dnsimple

      option :client_options, {
        site: 'https://api.dnsimple.com',
        authorize_url: 'https://dnsimple.com/oauth/authorize',
        token_url: 'https://api.dnsimple.com/v2/oauth/access_token'
      }
      
      option :token_method, :post
      option :auth_scheme, :request_body
      option :client_params_in_body, true

      uid do
        raw_info['data']['account']['id'].to_s rescue nil
      end

      info do
        {
          email: raw_info['data']['account']['email'],
          name: raw_info['data']['account']['email']
        }
      rescue StandardError => e
        Rails.logger.error "Error fetching DNSimple info: #{e.message}"
        {}
      end

      def raw_info
        @raw_info ||= access_token.get('v2/whoami').parsed
      rescue StandardError => e
        Rails.logger.error "Error fetching DNSimple raw info: #{e.message}"
        {}
      end
      
      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end
      
      # Override the build_access_token method to manually handle the token request
      def build_access_token
        code = request.params['code']
        state = request.params['state']
        
        Rails.logger.info "Building access token using code: #{code}"
        
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
        
        Rails.logger.info "Sending token request to #{uri} with data: #{request.body}"
        
        response = http.request(request)
        
        Rails.logger.info "DNSimple token response: #{response.code} - #{response.body}"
        
        if response.code.to_i == 200
          data = JSON.parse(response.body)
          ::OAuth2::AccessToken.from_hash(client, data)
        else
          error_msg = "Failed to get access token: #{response.code} - #{response.body}"
          Rails.logger.error error_msg
          raise ::OAuth2::Error.new(OpenStruct.new(status: response.code, body: response.body))
        end
      end
    end
  end
end
