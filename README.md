# OmniAuth DNSimple

This is an UNOFFICIAL OmniAuth strategy for authenticating to DNSimple. To use it, you'll need to sign up for an OAuth2 Application ID and Secret on the [DNSimple website](https://dnsimple.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-dnsimple'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install omniauth-dnsimple
```

## Usage

```ruby
use OmniAuth::Builder do
  provider :dnsimple, ENV['DNSIMPLE_CLIENT_ID'], ENV['DNSIMPLE_CLIENT_SECRET']
end
```

### Configuring

You can configure several options, which you pass in to the `provider` method via a hash:

* `fetch_info`: When set to `true`, the strategy will make an additional API call to get the account information. Defaults to `true`.

For example:

```ruby
use OmniAuth::Builder do
  provider :dnsimple, ENV['DNSIMPLE_CLIENT_ID'], ENV['DNSIMPLE_CLIENT_SECRET'], 
           fetch_info: false
end
```

### Authentication Hash

An example auth hash available in `request.env['omniauth.auth']`:

```ruby
{
  "provider" => "dnsimple",
  "uid" => "123456",
  "info" => {
    "name" => "user@example.com",
    "email" => "user@example.com"
  },
  "credentials" => {
    "token" => "a1b2c3d4e5f6g7h8i9j0", # The OAuth 2.0 access token
    "refresh_token" => "1a2b3c4d5e6f7g8h9i0j", # The OAuth 2.0 refresh token
    "expires_at" => 1496120719, # The time the token expires as a unix timestamp
    "expires" => true # A boolean for whether the token expires
  },
  "extra" => {
    "raw_info" => {
      "data" => {
        "user" => {
          "id" => 1234,
          "email" => "user@example.com"
        },
        "account" => {
          "id" => 123456,
          "email" => "user@example.com"
        }
      }
    }
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/usiegj00/omniauth-dnsimple.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 