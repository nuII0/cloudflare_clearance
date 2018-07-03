# frozen_string_literal: true
require 'net/http'

module CloudflareClearance
  module HttpAdapter
    class NetHttp
      def self.get(uri, header)
        uri = URI.parse uri.to_s
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme.eql? 'https'
        http.request Net::HTTP::Get.new(uri, header)
      end
    end
  end
end

