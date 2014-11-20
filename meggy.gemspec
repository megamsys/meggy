$:.unshift File.expand_path("../lib", __FILE__)
require "meggy/version"

Gem::Specification.new do |gem|
  gem.name = "meggy"
  gem.version = Meggy::VERSION
  gem.authors     = ["Kishorekumar Neelamegam","Thomas Alrin","Rajthilak"]
  gem.email = ["nkishore@megam.co.in", "alrin@megam.co.in", "rajthilak@megam.co.in"]
  gem.homepage = "https://github.com/megamsys/meggy"
  gem.license = "Apache V2"
  gem.extra_rdoc_files = ["README.md", "LICENSE" ]
  gem.summary = %q{CLI to manage megam (http://www.gomegam.com).}
  gem.description = %q{Command-line tool to deploy  and manage Megam(http://www.gomegam.com).}
  gem.post_install_message = <<-MESSAGE
! You are free to invoke `meg` now. Read docs: http://www.gomegam.com/docs for more info.
! Support: http://support.megam.co
MESSAGE
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'megam_api'
  gem.add_runtime_dependency 'mixlib-cli'
  gem.add_runtime_dependency 'mixlib-config'
  gem.add_runtime_dependency 'mixlib-log'
  gem.add_runtime_dependency 'rubyzip'
  gem.add_runtime_dependency 'randexp'
  gem.add_runtime_dependency 'command_line_reporter'
  gem.add_development_dependency 'rspec'
end
