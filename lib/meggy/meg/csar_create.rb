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
    class CsarCreate < Meg
          include CommandLineReporter


     #attr_accessor :name_args

    deps do
      #We'll include our API client as the dependency.
    end
    
  option :yamldir,
    :short => "-d Yaml directory to load from",
    :long => "--yamldir YAMLDIRECTORY",
    :description => "Yaml directory to load from, appends to the YAMLFILENAME.",
    :on => :head

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

    banner "meg csar create YAMLFILENAME [options]"

    def run
        yaml_dir =  config[:yamldir].nil? ?  File.dirname(__FILE__) : config[:yamldir]
        yaml_filename = @name_args[0]
        if yaml_filename.nil?   
          text.fatal("You must specify a File Name")
          show_usage
          exit 1  
        end
         @csar_file =  File.expand_path(File.join(yaml_dir,"#{yaml_filename}"))
        if !File.exists?(@csar_file) 
            text.fatal("File not found " + "#{text.color("#{@csar_file}", :yellow, :bold)}")
            show_usage
            exit 1
       else
            begin
               Megam::Config[:email] = Meggy::Config[:email]
               Megam::Config[:api_key] = Meggy::Config[:api_key]  
                                         
               YAML.load_file("#{@csar_file}")   
               yamlstr = IO.read(@csar_file)
               @excon_res = Megam::CSAR.create({"yamldata" => yamlstr})
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
