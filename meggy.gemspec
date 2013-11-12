$:.unshift File.expand_path("../lib", __FILE__)
require "meggy/version"

Gem::Specification.new do |gem|
  gem.name = "meggy"
  gem.version = Meggy::VERSION  
  gem.authors     = ["Kishorekumar Neelamegam","Thomas Alrin","Rajthilak"]
  gem.email = ["nkishore@megam.co.in", "alrin@megam.co.in", "rajthilak@megam.co.in"]
  gem.homepage = "https://github.com/indykish/meggy"
  gem.license = "Apache V2"
  gem.extra_rdoc_files = ["README.md", "LICENSE" ]
  gem.summary = "CLI to manage apps on megam (https://www.megam.co)."
  gem.description = "Command-line tool to deploy apps and manage apps Megam(https://www.megam.co)."
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'megam_api'
  gem.add_runtime_dependency 'launchy'
  gem.add_runtime_dependency 'rubyzip'
  gem.add_runtime_dependency 'mixlib-config'
  gem.add_runtime_dependency 'mixlib-log'
  gem.add_development_dependency 'rspec'   
  gem.files         = `git ls-files`.split("\n")
end
