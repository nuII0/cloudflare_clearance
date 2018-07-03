module CloudflareClearance
  Cookie = Struct.new(:name, :value, :path,
                      :domain, :expires, :secure, keyword_init: true) do
    def to_s
      "#{name}=#{value}"
    end
  end
end

