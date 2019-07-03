# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redi_search/version"

Gem::Specification.new do |spec|
  spec.name          = "redi_search"
  spec.version       = RediSearch::VERSION
  spec.authors       = "Nick Pezza"
  spec.email         = "npezza93@gmail.com"

  spec.summary       = %q(RediSearch ruby wrapper that can integrate with Rails)
  spec.homepage      = "https://github.com/npezza93/redi_search"
  spec.license       = "MIT"
  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.metadata["github_repo"] = "ssh://github.com/npezza93/redi_search"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] =
    "https://github.com/npezza93/redi_search/releases"

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_runtime_dependency "activemodel", ">= 5.1", "< 6.1"
  spec.add_runtime_dependency "activesupport", ">= 5.1", "< 6.1"
  spec.add_runtime_dependency "redis", ">= 4.0", "< 5.0"

  spec.add_development_dependency "appraisal", "~> 2.2"
  spec.add_development_dependency "bundler", ">= 1.17", "< 3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 12.0"
end
