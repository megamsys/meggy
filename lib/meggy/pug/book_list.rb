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
        begin

          Megam::Config[:email] = Meggy::Config[:email]
          Megam::Config[:api_key] = Meggy::Config[:apikey]
          @excon_res = Megam::Node.list

          @nodes=@excon_res.data[:body]
          text.summarize(@nodes)       

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
