# frozen_string_literal: true

require_relative "lib/omniauth/dnsimple/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-dnsimple"
  spec.version       = OmniAuth::DNSimple::VERSION
  spec.authors       = ["Jonathan Siegel"]
  spec.email         = ["usiegj00@no-spam-please.com"]

  spec.summary       = "OmniAuth strategy for DNSimple"
  spec.description   = "OmniAuth strategy for authenticating with DNSimple via OAuth2"
  spec.homepage      = "https://github.com/usiegj00/omniauth-dnsimple"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth-oauth2", "~> 1.7"
  
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end 