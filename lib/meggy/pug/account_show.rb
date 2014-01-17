require 'meggy/pug'
require 'megam/core/server_api'


class Meggy
  class Pug
    class AccountShow < Pug

      banner "pug account show"
      def run
       if Meggy::Config[:email].nil?         
          text.fatal("You must specify an email in config file")
          show_usage
          exit 1        
       else
            text.info("Start Account Show")
            begin
                Megam::Config[:email] = Meggy::Config[:email]
                Megam::Config[:api_key] = Meggy::Config[:apikey]
                @excon_res = Megam::Account.show(Meggy::Config[:email])   
                ress = @excon_res.data[:body]
                text.info(ress)
            #rescue other errors like connection refused by megam_play     
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

