require "securerandom"
require 'megam/core/server_api'
require 'megam/core/account'
require 'megam/core/config'
require 'megam/core/error'
require "megam/core/text"
require 'megam/api'
require 'command_line_reporter'


class Meggy
  class Meg
    class AccountCreate < Meg
          include CommandLineReporter

      deps do
      #We'll include our API client as the dependency.
      end

      banner "meg account create EMAIL (options)"

      def run
        @email = @name_args[0]
       if @email.nil?
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
                report(options,ress[:msg])
            #rescue other errors like connection refused by megam_play
            rescue Megam::API::Errors::ErrorWithResponse => ewr
                 res = ewr.response.data[:body].some_msg
                 text.error(res[:msg])
                 text.msg("#{text.color("Retry Again", :white, :bold)}")
                 text.info(res[:links])
            end
          else
          text.fatal("You must specify a valid email format eg: someone@megam.co")
          end
        end
      end

      private


      def generate_api_token
        api_token = SecureRandom.urlsafe_base64(nil, true)
      end
      
      def report(options, acct_msg)
        table :border => true do
          row :header => true, :color => 'green' do
            column 'Account', :width => 15
            column 'Information', :width => 40, :align => 'left'
          end
          row do
            column 'email'
            column options[:email]
          end
          row do
            column 'api_key'
            column options[:api_key]
          end
          row do
            column 'message'
            column acct_msg
          end          
        end
      end
      
      

    end
  end
end
