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
  spec.require_path  = "lib"
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end

  spec.metadata["github_repo"] = "ssh://github.com/npezza93/redi_search"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] =
    "https://github.com/npezza93/redi_search/releases"

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_runtime_dependency "activesupport", ">= 5.1", "< 6.2"
  spec.add_runtime_dependency "redis", ">= 4.0", "< 5.0"

  spec.add_development_dependency "bundler", ">= 1.17", "< 3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
