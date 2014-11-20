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
    class CsarList < Meg
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

    banner "meg csar list [options]"

    def run        
        begin
          Megam::Config[:email] = Meggy::Config[:email]
          Megam::Config[:api_key] = Meggy::Config[:api_key]  
                                 
          @excon_res = Megam::CSAR.list
          report(@excon_res.data[:body])
         rescue Megam::API::Errors::ErrorWithResponse => ewr
             res = ewr.response.data[:body].some_msg
             text.error(res[:msg])
             text.msg("#{text.color("Retry Again", :white, :bold)}")
             text.info(res[:links])
         rescue ArgumentError => ae
             text.error(ae)
             text.msg("#{text.color("Retry Again", :white, :bold)}")
         end
      end
      
      def report(csar_res)
        table :border => true do
          row :header => true, :color => 'green' do
            column 'CSAR', :width => 25
            column 'Created At', :width => 30, :align => 'left'
          end
          csar_res.each  do |csar_res_one|
            row do
              column csar_res_one.id
              column csar_res_one.created_at
            end               
          end     
        end
      end
      
    end
  end
end
