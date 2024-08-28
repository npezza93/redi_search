# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redi_search/version"

Gem::Specification.new do |spec|
  spec.name          = "redi_search"
  spec.version       = RediSearch::VERSION
  spec.authors       = "Nick Pezza"
  spec.email         = "pezza@hey.com"

  spec.summary       = %q(RediSearch ruby wrapper that can integrate with Rails)
  spec.homepage      = "https://github.com/npezza93/redi_search"
  spec.license       = "MIT"
  spec.require_path  = "lib"
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "github_repo" => "ssh://github.com/npezza93/redi_search",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "https://github.com/npezza93/redi_search/releases",
  }

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "activesupport", "< 9.0"
  spec.add_dependency "redis", ">= 4.0"
  spec.add_dependency "zeitwerk"
end
