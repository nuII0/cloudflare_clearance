# frozen_string_literal: true
module CloudflareClearance
  ClearanceData = Struct.new(:user_agent, :cookieset, keyword_init: true) do
    def initialize(user_agent:, cookieset:)
      super
    end
  end
end
