# frozen_string_literal: true

require 'cloudflare_clearance/drivers/driver'
require 'cloudflare_clearance/http_adapter/net_http'

require_relative 'challenge_solver/exec_js'

module CloudflareClearance
  class ExecJs < Driver
    USER_AGENTS = [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/65.0.3325.181 Chrome/65.0.3325.181 Safari/537.36",
      "Mozilla/5.0 (Linux; Android 7.0; Moto G (5) Build/NPPS25.137-93-8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.137 Mobile Safari/537.36",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",
      "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:60.0) Gecko/20100101 Firefox/60.0",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:59.0) Gecko/20100101 Firefox/59.0",
      "Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:57.0) Gecko/20100101 Firefox/57.0"
    ].freeze

    USER_AGENT = USER_AGENTS.sample

    def initialize(http_adapter: CloudflareClearance::HttpAdapter::NetHttp, challenge_solver: ChallengeSolver::ExecJs, user_agent: USER_AGENT)
      require "execjs"
      @http_adapter = http_adapter
      @challenge_solver = challenge_solver
      @user_agent = USER_AGENT
    end

    def get_clearance(url, seconds_wait_retry: 6)
      uri = URI.parse(url)

      challenge_response = initial_request uri

      challenge_cookies = challenge_response.header["Set-Cookie"]

      unless (challenge_cookies&.include?("__cfduid"))
        raise ClearanceError, "__cfduid Cookie was not set. Is it a Cloudflare protected page?"
      end

      answer = @challenge_solver.solve(body: challenge_response.body, domain: uri.host, timeout: seconds_wait_retry)

    end

    def self.available?
      require "execjs"
      true
    rescue LoadError
      false
    end

    def self.deprecated?
      true
    end

    private

    def initial_request uri
      header = {
        'User-Agent' => USER_AGENT
      }
      @http_adapter.get(uri, header)
    end

    class << self
      def get_clearance(url, adapter: Adapter::NetHttp.new(url), header: { }, challenge: nil)
        uri = URI.parse(url)

        header = {
          'User-Agent' => USER_AGENT,
        }.merge(header)
        header['Referer'] = uri.host

        antibot_response = adapter.get(uri, header)
        raise "__cfduid Cookie was not set. Is it a Cloudflare protected page?" unless antibot_response.header["Set-Cookie"]&.include? "__cfduid"

        answer = challenge ? challenge.solve(body: antibot_response.body.to_s, domain: uri.host) : JsChallenge.solve(body: antibot_response.body.to_s, domain: uri.host)

        cfuri = uri + '/cdn-cgi/l/chk_jschl'
        cfuri.query = URI.encode_www_form(answer)

        clearance_response = adapter.get(cfuri, header)
        raise "cf_clearance Cookie was not set." unless clearance_response.header["Set-Cookie"]&.include? "cf_clearance"

        return ClearanceData.new(USER_AGENT, HTTP::Cookie.parse(clearance_response.header["Set-Cookie"], uri).detect{ |c| c.name.eql? "cf_clearance"} )
      end
    end
  end
end
