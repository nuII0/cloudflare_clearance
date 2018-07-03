# frozen_string_literal: true
require "cloudflare_clearance/cookie_set"
require 'cloudflare_clearance/drivers/driver'

module CloudflareClearance
  class Selenium < Driver
    DEFAULT_BROWSER = :firefox
    #DEFAULT_OPTS = ::Selenium::WebDriver::Firefox::Options.new(
      #args: ['-headless']
    #)

    def initialize(selenium_webdriver: (::Selenium::WebDriver.for DEFAULT_BROWSER, options: default_options))
      require "selenium-webdriver"
      @driver = selenium_webdriver
    end

    def get_clearance(url, retries: 5, seconds_wait_retry: 6)
      @driver.get(url)
      cookieset = wait_for_cookies(retries, seconds_wait_retry)
      ClearanceData.new(user_agent: user_agent, cookieset: cookieset)
    end

    def self.available?
      require "selenium-webdriver"
      true
    rescue LoadError
      false
    end

    def self.deprecated?
      false
    end

    private

    def default_options
      ::Selenium::WebDriver::Firefox::Options.new(
        args: ['-headless']
      )
    end

    def user_agent
      @driver.execute_script("return navigator.userAgent")
    end

    def wait_for_cookies(retries, seconds_wait_retry)
      CookieSet.from_cookiehash(cookies)
    rescue CookieError => e
      if (retries -= 1) >= 0
        sleep seconds_wait_retry
        retry
      else
        raise ClearanceError, "Unable to obtain clearance. #{e.class.name} Reason: #{e.message}"
      end
    end

    def cookies
      @driver.manage.all_cookies
    end
  end
end
