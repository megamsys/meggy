require 'meggy/pug'
require "megam/core/text"

class Meggy
  class Pug
    class BookList < Pug

deps do
      #We'll include our API client as the dependency.
      #
    end
      banner "pug book list (options)"
        
      def run
        puts "Identity Listing..."
        begin
                #Megam::Config[:email] = "b@b.com"
                #Megam::Config[:api_key] = 'oWEbCrBll4TRCR6MXrdMiw=='
                #Megam::Config[:email] = "#{ENV['MEGAM_API_EMAIL']}"
                #Megam::Config[:api_key] = "#{ENV['MEGAM_API_KEY']}"
                
                Megam::Config[:email] = Meggy::Config[:email] 
                Megam::Config[:api_key] = Meggy::Config[:apikey] 
                @excon_res = Megam::Node.list
                
                    rescue ArgumentError => ae
      hash = {"msg" => ae.message, "msg_type" => "error"}
      re = Megam::Error.from_hash(hash)
      return re
    rescue Megam::API::Errors::ErrorWithResponse => ewr
      hash = {"msg" => ewr.message, "msg_type" => "error"}
      re = Megam::Error.from_hash(hash)
      return re
    rescue StandardError => se
      hash = {"msg" => se.message, "msg_type" => "error"}
      re = Megam::Error.from_hash(hash)
      return re
      end
                @nodes=@excon_res.data[:body]
                text.msg("NODE NAME<-->TYPE<-->APP TYPE<-->CREATED AT")
                @nodes.each do |n|
                	text.msg(n.node_name+"<-->"+n.node_type+"<-->"+n.predefs[:name]+"<-->"+n.node.created_at)
                end
                
       end
    end
  end
end
