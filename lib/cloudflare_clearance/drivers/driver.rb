# frozen_string_literal: true
module CloudflareClearance
  class Driver
    def self.available?
      raise NotImplementedError
    end

    def self.deprecated?
      raise NotImplementedError
    end

    def get_clearance(*)
      raise NotImplementedError
    end
  end
end
