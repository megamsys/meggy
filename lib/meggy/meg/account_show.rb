require 'meggy/meg'
require 'megam/core/server_api'
require 'command_line_reporter'

class Meggy
  class Meg
    class AccountShow < Meg
      include CommandLineReporter

      banner "meg account show"
      def run
        begin
          Megam::Config[:email] = Meggy::Config[:email]
          Megam::Config[:api_key] = Meggy::Config[:api_key]
          @excon_res = Megam::Account.show(Megam::Config[:email])
          acct_res = @excon_res.data[:body]
          report(acct_res)
        rescue Megam::API::Errors::ErrorWithResponse => ewr
          res = ewr.response.data[:body].some_msg
          text.error(res[:msg])
          text.msg("#{text.color("Retry Again", :white, :bold)}")
          text.info(res[:links])
        end
      end

      def report(acct_res)
        table :border => true do
          row :header => true, :color => 'green' do
            column 'Account', :width => 15
            column 'Information', :width => 32, :align => 'left'
          end
          row do
            column 'email'
            column acct_res.email
          end
          row do
            column 'api_key'
            column acct_res.api_key
          end
          row do
            column 'authority'
            column acct_res.authority
          end
          row do
            column 'created_at'
            column acct_res.created_at
          end
        end
      end

    end
  end
end
