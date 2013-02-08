#require 'optparse'
require './command'
require './help'

module Nm
class MyCLI
 
com = Command.new


if !ARGV.empty?
 array = Array.new
 
 if (ARGV[0] == '--login' || ARGV[0] == '--identity')
 	ARGV.each do|a|
   		array.push a
 	end
	com.run(array)
 else
	h = Help.new
	h.list
 end
else
	h = Help.new
	h.list
end
end #class
end #module
