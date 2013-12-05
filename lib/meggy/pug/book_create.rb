require 'megam/core/node'
require 'megam/core/config'
require 'megam/core/error'
require "megam/core/text"
require 'megam/api'
require 'randexp'
class Meggy
  class Pug
    class BookCreate < Pug
      #attr_accessor :name_args
    deps do
      #We'll include our API client as the dependency.
      #
    end
    
    
     option :appname,
    :short => "-a APPTYPE",
    :long => "--app APPTYPE",
    :description => "The application type to use [java,rails,play,akka,nodejs]",
    :required => true    

     option :type,
    :short => "-t BOOK_TYPE",
    :long => "--type BOOK_TYPE",
    :description => "Type of your book [APP, BOLT]",
    :required => true    
    
    option :scm,
    :short => "-s GITREPOS",
    :long => "--scm GITREPOS",
    :description => "The source control management repository to use: eg:[https://github.com/username/yourepos.git]",
    :required => true 
        
    option :domain,
    :short => "-d DOMAIN",
    :long => "--domain DOMAIN",
    :description => "The domain name to use. [eg: pogo.com]",
    :default => "megam.co"
    
    option :crosscloud,
    :short => "-r CROSSCLOUDNAME",
    :long => "--crosscloud CROSSCLOUDNAME",
    :description => "The cross cloud setting to use.",
    :default => "sandbox_default"
    
    option :noofinstances,
    :short => "-i NOOFINSTANCES",
    :long => "--instance NOOFINSTANCES",
    :description => "No on instances.",
    :default => 1
    
    
    option :email,
    :short => "-e EMAIL",
    :long => "--email EMAIL",
    :description => "User's Email for which the book is created. [eg: a@b.com]. Default value will be get from conf file.",
    :default => "config[:email]"
    
    option :apikey,
    :short => "-k APIKEY",
    :long => "--apikey APIKEY",
    :description => "Apikey of the given email. [eg: oWEbCrBll4TRCR6MXrdMiw==]",
    :default => "config[:apikey]"
    
      banner "pug book create BOOKNAME [options]"
      
      def run           
            #test book creation
            #./pug book create node -a rails -r sandbox_default -D megam.co -s test -t APP

            
       @book_name = @name_args[0]        
       if @book_name.nil?         
          text.fatal("You must specify a Book Name")
          show_usage
          exit 1        
       else
            
            text.info("start")
            begin
                Megam::Config[:email] = Meggy::Config[:email] 
                Megam::Config[:api_key] = Meggy::Config[:apikey] 
                #Megam::Config[:email] = "#{ENV['MEGAM_API_EMAIL']}"
                #Megam::Config[:api_key] = "#{ENV['MEGAM_API_KEY']}"
                
                excon_predef = Megam::Predef.show(config[:appname])
                @predef=excon_predef.data[:body].lookup(config[:appname])
                puts "===================================> @predef <============================================="
                puts @predef.inspect
                data={:book_name => @book_name, :book_type => config[:type] , :predef_cloud_name => config[:crosscloud], :provider => @predef.provider, :provider_role => @predef.provider_role, :domain_name => '.'+config[:domain], :no_of_instances => config[:noofinstances].to_i, :predef_name => config[:appname], :deps_scm => config[:scm], :deps_war => "#{config[:war]}", :timetokill => "#{Time.now}", :metered => "", :logging => "", :runtime_exec => @predef.runtime_exec}
   
    		node_hash=Megam::MakeNode.create(data, "server", "create")
    		
                @excon_res = Megam::Node.create(node_hash) 


puts "TEST ======================> "
@excon_res.data[:body].each do |res|
	puts res.class
                text.info(res.some_msg[:msg])
                end
        
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
