require 'nm/identity_create'
require 'rubygems'
require 'mixlib/cli'

class Command 

  include Mixlib::CLI
  def run(cmd, args=[])
	puts "Command --> run @name_args start"
	puts args
	puts "@name_args end"
	ic = IdentityCreate.new
	ic.run
  end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      show_usage
      exit(1)
    end

end



