# frozen_string_literal: true

require 'cloudflare_clearance/clearance_data'
require 'cloudflare_clearance/http_adapter/net_http'
require 'cloudflare_clearance/drivers'

require 'uri'

module CloudflareClearance
  class Clearance
    attr_reader :cookieset, :user_agent, :clearance_data

    SOLVE_DELAY_SEC = 6

    DRIVER = Drivers.autodetect.new

    def initialize(url, driver: DRIVER, delay: SOLVE_DELAY_SEC)
      parse_url(url)
      @driver = driver
      @clearance_data = @driver.get_clearance(url, seconds_wait_retry: delay)
      @cookieset = clearance_data.cookieset
      @user_agent = clearance_data.user_agent
    end

    def get(url, header = {})
      header["Cookie"] = cookie_string
      header["User-Agent"] = @user_agent

      HttpAdapter::NetHttp.get(url, header)
    end

    def cookie_string
      "#{@cookieset.cf_clearance.to_s};#{@cookieset.cf_duid.to_s}"
    end

    private

    def parse_url(url)
      raise ArgumentError, 'Url is not a Http(s) url' unless url.to_s =~ %r{\A#{URI.regexp(%w[http https])}\z}
      URI.parse url.to_s
    end

  end
end
