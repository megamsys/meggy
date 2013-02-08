#require './identity_create'
require_relative 'identity_create'
require_relative 'identity_list'
require_relative 'identity_delete'
#require './identity_list'
#require './identity_delete'
#load './identity_create.rb'
#module Commands
  class Identity
    def run(args)
	puts args
 array = Array.new
 arg_len = args.length
puts arg_len
	case
	when args[1] == '--create'
		@ic = IdentityCreate.new
		for i in (2..arg_len-1)
			array.push args[i]
		end
		@ic.run(array)
	when args[1] == '--list'
		@il = IdentityList.new
		for i in (2..arg_len-1)
			array.push args[i]
		end
		@il.run(array)
	when args[1] == '--delete'
		@id = IdentityDelete.new
		for i in (2..arg_len-1)
			array.push args[i]
		end
		@id.run(array)
	else
		#ih = IdentityHelp.new
		#ih.list
		puts "Identity Help"
	end
	
    end
  end
#end





