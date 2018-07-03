# frozen_string_literal: true
require 'cloudflare_clearance/drivers/selenium'
require 'cloudflare_clearance/drivers/http_js'

module CloudflareClearance
  class Drivers
    def self.autodetect
      best_available ||
        raise( DriverUnavailable, "Could not find a supported Driver. " +
              "See https://github.com/nuii0/cloudflare_clearance for Driver dependencies." )
    end

    def self.best_available
      drivers.reject(&:deprecated?).find(&:available?)
    end

    def self.drivers
      @drivers || [
        HttpJs,
        Selenium
      ]
    end

  end
end

