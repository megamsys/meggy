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
    class CloudsetList < Meg
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

    banner "meg cloudset list [options]"

    def run        
        begin
          Megam::Config[:email] = Meggy::Config[:email]
          Megam::Config[:api_key] = Meggy::Config[:api_key]  
                                 
          @excon_res = Megam::PredefCloud.list
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
      
      def report(cloudsar_res)
        table :border => true do
          row :header => true, :color => 'green' do
            column 'Cloud Settings', :width => 15
            column 'Type', :width => 7
            column 'Image', :width => 8
            column 'Flavor', :width => 8
            column 'Created At', :width => 25, :align => 'left'
          end
          cloudsar_res.each  do |cloudsar_res_one|
            row do
              column cloudsar_res_one.name              
              column cloudsar_res_one.spec[:type_name]
              column cloudsar_res_one.spec[:flavor]
              column cloudsar_res_one.spec[:image]
              column cloudsar_res_one.created_at
            end               
          end     
        end
      end
      
    end
  end
end
