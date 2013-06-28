require 'oauth'

module OmniAuth
  module Strategies
    class TwitterAccessToken
      include OmniAuth::Strategy

      option :name, 'twitter_access_token'

      args [:client_id, :client_secret]

      option :client_id, nil
      option :client_secret, nil

      option :client_options, {
        :site => 'https://api.twitter.com',
        :authorize_path => '/oauth/authenticate',
        :request_token_path => '/oauth/request_token',
        :access_token_path => '/oauth/access_token',
        :ssl => { :version => "SSLv3" }
      }

      option :access_token_options, {
        :header_format => 'OAuth %s',
        :param_name => 'access_token'
      }

      attr_accessor :access_token

      uid { raw_info['id'] }

      info do
        {
          :nickname => raw_info['screen_name'],
          :name => raw_info['name'],
          :location => raw_info['location'],
          :image => image_url(options),
          :description => raw_info['description'],
          :urls => {
            'Website' => raw_info['url'],
            'Twitter' => "https://twitter.com/#{raw_info['screen_name']}",
          }
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      credentials do
        hash = {'token' => access_token.token}
        hash
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get('/1.1/account/verify_credentials.json?include_entities=false&skip_status=true').body) || {}
      end

      def client
        ::OAuth::Consumer.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def request_phase
        form = OmniAuth::Form.new(:title => "User Token", :url => callback_path)
        form.text_field "Token", "token"
        form.text_field "Token Secret", "token_secret"
        form.button "Sign In"
        form.to_response
      end

      def callback_phase
        if !request.params['token'] || request.params['token'].to_s.empty?
          raise ArgumentError.new("No access token provided.")
        end
        if !request.params['token_secret'] || request.params['token_secret'].to_s.empty?
          raise ArgumentError.new("No token secret provided.")
        end

        self.access_token = build_access_token
        #self.access_token = self.access_token.refresh! if self.access_token.expired?

        # Validate that the token belong to the application
        # app_raw = self.access_token.get('/app').parsed
        # if app_raw["id"] != options.client_id
        #   raise ArgumentError.new("Access token doesn't belong to the client.")
        # end

        # Instead of calling super, duplicate the functionlity, but change the provider to 'facebook'.
        # This is done in order to preserve compatibilty with the regular facebook provider
        hash = auth_hash
        hash[:provider] = "twitter"
        self.env['omniauth.auth'] = hash
        call_app!

       rescue ::OAuth::Error => e
         fail!(:invalid_credentials, e)
       rescue ::MultiJson::DecodeError => e
         fail!(:invalid_response, e)
       rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
         fail!(:timeout, e)
       rescue ::SocketError => e
         fail!(:failed_to_connect, e)
      end

      protected

      def deep_symbolize(hash)
        hash.inject({}) do |h, (k,v)|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
          h
        end
      end

      def build_access_token
        ::OAuth::AccessToken.new(
          client,
          request.params["token"],
          request.params["token_secret"]
        )
      end

      def image_url(options)
        original_url = options[:secure_image_url] ? raw_info['profile_image_url_https'] : raw_info['profile_image_url']
        case options[:image_size]
        when 'mini'
          original_url.sub('normal', 'mini')
        when 'bigger'
          original_url.sub('normal', 'bigger')
        when 'original'
          original_url.sub('_normal', '')
        else
          original_url
        end
      end

    end
  end
end
