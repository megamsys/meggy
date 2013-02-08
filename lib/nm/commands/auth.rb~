#require 'command'
#module Nm::Commands
#module Commands
require 'rubygems'
require 'mixlib/cli'
require 'highline/import'
class Auth
	include Mixlib::CLI
  option :username, 
    :short => "-u",
    :long => "--username",
    :description => "Enter username",
	:required => true

  option :password, 
    :short => "-p",
    :long => "--password",
    :description => "Enter Password",
	:required => true

    def run(args)
	puts "Enter username : "
	@username = $stdin.gets
	@password = ask("Enter password: ") { |q| q.echo = false }
	puts "Logged in as : "+@username+@password
    end
end
#end





