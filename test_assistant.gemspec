# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_assistant/version'

Gem::Specification.new do |spec|
  spec.name          = "test_assistant"
  spec.version       = TestAssistant::VERSION
  spec.authors       = ["Aleck Greenham"]
  spec.email         = ["greenhama13@gmail.com"]
  spec.summary       = "A toolbox for increased testing efficiency with RSpec"
  spec.description   = "A collection of testing tools, hacks, and utilities for writing and fixing tests faster"
  spec.homepage      = "https://github.com/greena13/test_assistant"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"
end
