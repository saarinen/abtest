# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abtest/version'

Gem::Specification.new do |spec|
  spec.name          = "abtest"
  spec.version       = Abtest::VERSION
  spec.authors       = ["Steve Saarinen", "Keatton Lee"]
  spec.email         = ["ssaarinen@whitepages.com", "klee@whitepages.com"]
  spec.description   = %q{Rails based AB test framework}
  spec.summary       = %q{Manages AB experiments and allows for view and asset context switching for experiments.}
  spec.homepage      = "http://www.whitepages.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
