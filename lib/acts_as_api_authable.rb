require "warden"

require "acts_as_api_authable/railtie"
require "acts_as_api_authable/config"
require "acts_as_api_authable/strategies"
require "acts_as_api_authable/failure_app"

module ActsAsApiAuthable
  def self.Configure
    config = OpenStruct.new({
      invalid_time_allowed: false,
      unsigned_requests_allowed: false,
      max_request_age: 60,
      max_clock_skew: 5,
      authable_models: [],
      allowed_types: [:signature, :http_only_cookie],
    })

    yield config

    ActsAsApiAuthable.Configuration = Config.new(config)

    return unless ActsAsApiAuthable.Configuration.valid?

    Rails.application.config.middleware.insert_before Rack::Head, Warden::Manager do |manager|
      manager.default_strategies ActsAsApiAuthable.Configuration.allowed_types
     manager.failure_app = ActsAsApiAuthable::FailureApp
    end
  end

  def self.Configuration
    @config
  end

  def self.Configuration=(value)
    @config = value
  end
end

