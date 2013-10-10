
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


      banner "pug account create EMAIL(options)"
      
      def run
        @account_name = @name_args[0]
	      
       if @account_name.nil?
          #show_usage
          text.fatal("You must specify an email name")
          #exit 1
        
       else
        options = { :id => 00, :email => @account_name, :api_key => generate_api_token, :authority => "admin"}
             
                begin
                Megam::Config[:email] = options[:email]
                Megam::Config[:api_key] = options[:api_key]
                @excon_res = Megam::Account.create(options)             
                 rescue Megam::API::Errors::ErrorWithResponse => ewr      
                   @res = ewr.response
                   ress = @res.data[:body].some_msg
                   text.error(ress[:msg])
                   text.msg "#{text.color("Retry Again", :white, :bold)}"
                   text.info(ress[:links])                                               
                 else
                   ress = @excon_res.data[:body].some_msg 
                   text.info(ress[:msg])
                   text.info(ress[:links])
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
