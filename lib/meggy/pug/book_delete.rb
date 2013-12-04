require 'meggy/pug'

class Meggy
  class Pug
    class BookDelete < Pug
    
    option :bookname,
    :short => "-n BOOKNAME",
    :long => "--bookname BOOKNAME",
    :description => "Name of the book which you want to delete. [eg: book1.megam.co]",
    :required => true    
    

      banner "pug book delete BOOKNAME [options]"
      def run
      
=begin
        puts "Action : IdentityDelete entry"
        if name_args.length < 1
          show_usage
          text.fatal("You must supply a regular expression to match the results against")
          exit 42
        end

        #     all_identities = Meggy::ApiClient.list

        #     matcher = /#{name_args[0]}/
        #     identities_to_delete = {}
        #     all_identities.each do |name, identity|
        #       next unless name =~ matcher
        #       identities_to_delete[identity.name] = identity
        #     end

        #     if identities_to_delete.empty?
        #       ui.info "No identities match the expression /#{name_args[0]}/"
        #       exit 0
        #     end

        text.msg("The following identities will be deleted:")
        text.msg("")
        text.msg(text.list(identities_to_delete.keys.sort, :columns_down))
        text.msg("")
        text.confirm("Are you sure you want to delete these identities")

        identities_to_delete.sort.each do |name, identity|
          identity.destroy
          text.msg("Deleted identity #{name}")
        end
        
=end
       @book_name = @name_args[0]        
       if @book_name.nil?         
          text.fatal("You must specify a Book Name")
          show_usage
          exit 1        
       else
            
            text.info("start")
            begin
                Megam::Config[:email] = Meggy::Config[:email] 
                Megam::Config[:api_key] = Meggy::Config[:apikey] 
    		node_hash=Megam::DeleteNode.create(@book_name, "server", "delete")
		@excon_res = Megam::Request.create(node_hash)
		rescue Megam::API::Errors::ErrorWithResponse => ewr   
                 res = ewr.response.data[:body].some_msg
                 text.error(res[:msg])
                 text.msg("#{text.color("Retry Again", :white, :bold)}")
                 text.info(res[:links])
             end

	end
      end

    end
  end
end

