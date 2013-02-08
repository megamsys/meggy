
require 'rubygems'
require 'mixlib/cli'

class IdentityCreate

  include Mixlib::CLI
banner "Usage: ruby mycli.rb sub-command (options)"

  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true

  option :identity_name,
    :short => "-i USER",
    :long => "--identity_name IDENTITY_NAME",
    :description => "User's Identity Name(Account_name)"

    def run
	id_create = IdentityCreate.new
	id_create.parse_options
	#puts id_create.to_yaml
	puts "Identity Create"
	puts @name_args
    end

end
#end





