$:.unshift File.expand_path("../lib", __FILE__)
require "meggy/version"

Gem::Specification.new do |gem|
  gem.name = "meggy"
  gem.version = Meggy::VERSION

  gem.author = "Thomas"
  gem.email = "support@megam.co"
  gem.homepage = "http://megam.co/"
  gem.summary = "CLI to deploy identity and integrate apps live on Megam."
  gem.description = "Command-line tool to deploy identity and manage identity, integrate live on Megam."
  gem.executables = "nm"
  gem.license = "Apache V2"
  gem.post_install_message = <<-MESSAGE
! The `meggy` gem has been deprecated and replaced with the Heroku Toolbelt.
! Download and install from: https://megam.co/download
MESSAGE

  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_dependency "rest-client", "~> 1.6.1"
  gem.add_dependency "launchy", ">= 0.3.2"
  gem.add_dependency "rubyzip"
end
