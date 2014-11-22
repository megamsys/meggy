require 'megam/core/server_api'
require 'megam/core/config'
require 'megam/core/error'
require "megam/core/text"
require 'megam/api'
require 'meggy/meg'
require 'yaml'
require "command_line_reporter"


class Meggy
  class Meg
    class CsarPush < Meg
          include CommandLineReporter


     #attr_accessor :name_args

    deps do
      #We'll include our API client as the dependency.
    end
    
     option :email,
    :short => "-e EMAIL",
    :long => "--email EMAIL",
    :description => "User's registered Email. Default value from .megam/meg.rb conf file.",
    :default => Meggy::Config[:email],
    :on => :head
    
     option :apikey,
    :short => "-k APIKEY",
    :long => "--apikey APIKEY",
    :description => "Apikey for the given email. Default value from .megam/meg.rb conf file.",
    :default => Meggy::Config[:apikey],
    :on => :head

    banner "meg csar push CSARID [options]"

    def run
        csar_id = @name_args[0]
        if csar_id.nil?   
          text.fatal("You must specify a CSAR ID, use `meg csar list` to list the ids.")
          show_usage
          exit 1  
        end
        begin
            Megam::Config[:email] = Meggy::Config[:email]
            Megam::Config[:api_key] = Meggy::Config[:api_key]                                           
            @excon_res = Megam::CSAR.push(csar_id)
            report(@excon_res.data[:body])
            rescue Megam::API::Errors::ErrorWithResponse => ewr
                 res = ewr.response.data[:body].some_msg
                 text.error(res[:msg])
                 text.msg("#{text.color("Retry Again 1", :white, :bold)}")
                 text.info(res[:links])
             rescue ArgumentError => ae
                text.error(ae)
                text.msg("#{text.color("Retry Again 2", :white, :bold)}")
        end
      end
      
      def report(csar_res)
        table :border => true do
          row :header => true, :color => 'green' do
            column 'CSAR', :width => 15
            column 'Information', :width => 52, :align => 'left'
          end
          row do
            column 'message'
            column csar_res.some_msg[:msg]
          end          
        end
      end
      
    end
  end
end
