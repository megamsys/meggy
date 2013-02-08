
require 'nm/command'
require 'nm/help'

class Check


  def start(args)
	com = Command.new

    command = args.shift.strip rescue "help"
	puts "Command check : "+command

	com.run(ccoommand, args)

  end

end
