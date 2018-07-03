require "cloudflare_clearance/cookie"

module CloudflareClearance
  CookieSet = Struct.new(:cf_duid, :cf_clearance, :other, keyword_init: true) do

    def initialize(cf_duid:, cf_clearance:, other: [])
      super
    end

    def to_a
      [cf_clearance, cf_duid, *other]
    end

    def self.from_cookiehash(cookiehash)
      cookies = cookiehash.map { |c| Cookie.new(c) }

      cf_duid_cookie = cookies.find{ |c| c.name.eql? "__cfduid" }
      raise CookieError, "__cfduid is not set" unless cf_duid_cookie

      cf_clearance_cookie = cookies.find{ |c| c.name.eql? "cf_clearance" }
      raise CookieError, "cf_clearance is not set" unless cf_clearance_cookie

      other_cookies = cookies.reject do |c|
        (c.eql? cf_duid_cookie) || (c.eql? cf_clearance_cookie)
      end

      new(cf_clearance: cf_clearance_cookie, cf_duid: cf_duid_cookie, other: other_cookies)
    end

  end
end
