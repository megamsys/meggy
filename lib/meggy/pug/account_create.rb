require "securerandom"
require 'megam/core/account'
require 'megam/core/config'
require 'megam/core/error'
require "megam/core/text"
require 'megam/api'

class Meggy
  class Pug
    class AccountCreate < Pug
      #attr_accessor :name_args
      
      deps do
      #We'll include our API client as the dependency.
      end
      
      banner "pug account create EMAIL (options)"
 
 def isEmail(str)
  return str.match(/[a-zA-Z0-9._%]@(?:[a-zA-Z0-9]\.)[a-zA-Z]{2,4}/)
end

      def run
        @email = @name_args[0]        
       if @email.nil? && isEmail(@email).nil?         
          text.fatal("You must specify an email")
          show_usage
          exit 1        
       else
       
       if @email =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
            options = { :id => "0", :email => @email,:api_key => generate_api_token, :authority => "admin"}
            begin
                Megam::Config[:email] = options[:email]
                Megam::Config[:api_key] = options[:api_key]
                @excon_res = Megam::Account.create(options)   
                ress = @excon_res.data[:body].some_msg 
                text.info(ress[:msg])
                text.info(ress[:links])         
            #rescue other errors like connection refused by megam_play     
            rescue Megam::API::Errors::ErrorWithResponse => ewr      
                 res = ewr.response.data[:body].some_msg
                 text.error(res[:msg])
                 text.msg("#{text.color("Retry Again", :white, :bold)}")
                 text.info(res[:links])                                              
            end 
          else
          text.fatal("You must specify a correct email")
          end
        end         
      end
      
      private      
      
    
      def generate_api_token
        api_token = SecureRandom.urlsafe_base64(nil, true)
      end

    end
  end
end
