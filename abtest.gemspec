# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abtest/version'

Gem::Specification.new do |spec|
  spec.name          = "abtest"
  spec.version       = Abtest::VERSION
  spec.authors       = ["Steve Saarinen"]
  spec.email         = ["ssaarinen@whitepages.com"]
  spec.description   = %q{Railtie base to enable engine baset AB test modules}
  spec.summary       = %q{Manages registered AB test engines and provides before_filter to dynamically add load paths for enabled tests}
  spec.homepage      = "http://www.whitepages.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
