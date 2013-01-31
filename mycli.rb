require 'rubygems'
require 'mixlib/cli'

class MyCLI
  include Mixlib::CLI
puts "mycli"
  option :config_file, 
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => 'config.rb',
    :description => "The configuration file to use",
	:required => true
puts "mycli-conf"
option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
end

# ARGV = [ '-c', 'foo.rb', '-l', 'debug' ]
cli = MyCLI.new
cli.parse_options
cli.config[:config_file] # 'foo.rb'
