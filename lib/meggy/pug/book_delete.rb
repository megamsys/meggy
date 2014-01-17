require 'megam/core/server_api'
require 'meggy/pug'

class Meggy
  class Pug
    class BookDelete < Pug

      banner "pug book delete BOOKNAME [options]"
      def run
        @book_name = @name_args[0]
        if @book_name.nil?
          text.fatal("You must specify a Book Name")
          show_usage
          exit 1
        else

          begin
            Megam::Config[:email] = Meggy::Config[:email]
            Megam::Config[:api_key] = Meggy::Config[:apikey]
            node_hash=Megam::DeleteNode.create(@book_name, "server", "delete")
          rescue Megam::API::Errors::ErrorWithResponse => ewr
            res = ewr.response.data[:body].some_msg
            text.error(res[:msg])
            text.msg("#{text.color("Retry Again", :white, :bold)}")
            text.info(res[:links])
          rescue StandardError => se
          end
          unless node_hash.class == Megam::Error
            begin
              @excon_res = Megam::Request.create(node_hash)
              text.info(@excon_res.data[:body].some_msg[:msg])
            rescue Megam::API::Errors::ErrorWithResponse => ewr
              res = ewr.response.data[:body].some_msg
              text.error(res[:msg])
              text.msg("#{text.color("Retry Again", :white, :bold)}")
              text.info(res[:links])
            end
          else
            text.error(node_hash.some_msg[:msg])
          end
        end
      end

    end
  end
end

