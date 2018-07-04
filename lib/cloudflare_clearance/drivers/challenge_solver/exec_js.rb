# frozen_string_literal: true
module CloudflareClearance
  class ChallengeSolver
    class ExecJs

      ATTRIBUTES = %w[jschl_vc pass].freeze

      class << self
        def solve(body:, domain:, timeout: 5)
          raise Error, "Required Attributes not found in body. Either this is not a Cloudflare protected page or they changed their Anti-Bot Detection" unless ATTRIBUTES.all?{|a| body.to_s.include? a}
          sleep(timeout)
          js = extract_js(body)

          { "pass" => body.match(%r{name="pass" value="(.+?)"})[1],
            "jschl_answer" => (ExecJS.exec(js) + domain.to_s.length).to_s,
            "jschl_vc" => body.match(%r{name="jschl_vc" value="(\w+)"})[1] }
        rescue Error
          if body&.to_s&.downcase&.include? 'captcha'
            raise Error, "Cloudflare Page is protected with Captcha"
          end
          raise
        end

        private

        # Thanks to:
        # https://github.com/Anorov/cloudflare-scrape/blob/master/cfscrape/__init__.py
        # for hints.
        def extract_js(body)
          js = body.match(%r{setTimeout\(function\(\)\{\s+(var s,t,o,p,b,r,e,a,k,i,n,g,f.+?\r?\n[\s\S]+?a\.value =.+?)\r?\n})[1]
          js = js.gsub(%r{a\.value = (parseInt\(.+?\)).+}, "\\1")
          js = js.gsub(%r{\s{3,}[a-z](?: = |\.).+}, "")
          js = js.gsub(%r{[\n\']}, "")

          js = js.sub(%r{(parseInt)}, 'return \1')
        end
      end
    end
  end
end
