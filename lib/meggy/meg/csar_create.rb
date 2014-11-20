require 'megam/core/server_api'
require 'megam/core/config'
require 'megam/core/error'
require "megam/core/text"
require 'megam/api'
require 'meggy/meg'

class Meggy
  class Meg
    class CSARCreate < Meg

     #attr_accessor :name_args

    deps do
      #We'll include our API client as the dependency.
    end



     option :csarfile,
    :short => "-f TOSCA Yaml file",
    :long => "--file TOSCA Yaml file",
    :description => "CSAR TOSCA Yaml file.",
    :default => 1

      option :email,
    :short => "-e EMAIL",
    :long => "--email EMAIL",
    :description => "User's Email for which the book is created. [eg: a@b.com]. Default value will be get from conf file.",
    :default => Meggy::Config[:email]

      option :apikey,
    :short => "-k APIKEY",
    :long => "--apikey APIKEY",
    :description => "Apikey of the given email. [eg: oWEbCrBll4TRCR6MXrdMiw==]",
    :default => Meggy::Config[:apikey]

      banner "meg csar create YAMLFILENAME [options]"

      def run
        @file_name = @name_args[0]
        if @file_name.nil?
          text.fatal("You must specify a File Name")
          show_usage
          exit 1
       else
            begin
                Megam::Config[:email] = Meggy::Config[:email]
                Megam::Config[:api_key] = Meggy::Config[:apikey]

                data={:book_name => @book_name}

                @excon_res = Megam::CSAR.create(node_hash)
                @excon_res.data[:body].each do |res|
                text.info(res.some_msg[:msg])
            end

            #rescue other errors like connection refused by megam_play
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
    end
  end
end
