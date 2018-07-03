require "cloudflare_clearance/version"
require 'cloudflare_clearance/clearance'

module CloudflareClearance
  class Error < StandardError; end
  class ChallengeError < Error; end
  class ClearanceError < Error; end
  class CookieError < Error; end
  class DriverUnavailable < Error; end
end
