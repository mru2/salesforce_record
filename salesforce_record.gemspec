# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_record/version'

Gem::Specification.new do |spec|
  spec.name          = "salesforce_record"
  spec.version       = SalesforceRecord::VERSION
  spec.authors       = ["ClicRDV"]
  spec.email         = ["david.ruyer@clicrdv.com"]
  spec.summary       = %q{ActiveRecord-like mixin for querying, fetching and updating Salesforce models}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "salesforce_adapter", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
