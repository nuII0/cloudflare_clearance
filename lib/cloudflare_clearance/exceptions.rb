module CloudflareClearance
  class Error < StandardError; end
  class ChallengeError < Error; end
  class ClearanceError < Error; end
  class CookieError < Error; end

  class DriverUnavailable < Error; end
end
