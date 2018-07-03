
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cloudflare_clearance/version"

Gem::Specification.new do |spec|
  spec.name          = "cloudflare_clearance"
  spec.version       = CloudflareClearance::VERSION
  spec.authors       = ["nuii0"]
  spec.email         = ["nuii0@tuta.io"]

  spec.summary       = %q{A ruby gem to bypass the Cloudflare Anti-Bot protection}
  spec.homepage      = "https://github.com/nuII0/cloudflare_clearance"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-coolline"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "execjs"
  spec.add_development_dependency "pry-stack_explorer"

end
