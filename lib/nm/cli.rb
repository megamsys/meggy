#class nm::CLI

#def self.start(*args)
# use the mix_cli lib to set it up.
#end

require 'rubygems'
require 'mixlib/cli'

class MyCLI
  include Mixlib::CLI

  option :config_file, 
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => 'config.rb',
    :description => "The configuration file to use"
	:required => true
end

