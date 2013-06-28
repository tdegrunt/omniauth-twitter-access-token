# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-twitter-access-token/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'oauth', '~> 0.4.7'

  gem.authors       = ["Tom de Grunt"]
  gem.email         = ["tom@degrunt.nl"]
  gem.description   = %q{A Twitter strategy using token/token-secret for OmniAuth. Can be used for client side Twitter login. }
  gem.summary       = %q{A Twitter strategy using token/token-secret for OmniAuth.}
  gem.homepage      = "https://github.com/tdegrunt/omniauth-twitter-access-token"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.name          = "omniauth-twitter-access-token"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::TwitterAccessToken::VERSION
end
