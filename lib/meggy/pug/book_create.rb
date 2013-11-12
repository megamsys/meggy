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
    :short => "-a APP",
    :long => "--app APP",
    :description => "The application type to use [java,rails,play,akka,nodejs]",
    :required => true    

    option :scm,
    :short => "-s GITREPOS",
    :long => "--scm GITREPOS",
    :description => "The source control management repository to use: eg:[https://github.com/username/yourepos.git]",
    :required => true 
        
    option :domain,
    :short => "-D DOMAIN",
    :long => "--domain DOMAIN",
    :description => "The domain name to use. [eg: pogo.com]",
    :default => "megam.co"
    
    option :crosscloud,
    :short => "-r CROSSCLOUDNAME",
    :long => "--crosscloud CROSSCLOUDNAME",
    :description => "The cross cloud setting to use.",
    :default => "iaas-default"
    
    option :noofinstances,
    :short => "-i NOOFINSTANCES",
    :long => "--instance NOOFINSTANCES",
    :description => "No on instances.",
    :default => 1
    
      banner "pug book create (options)"
      
      def run           
            app_name = config[:appname] 
            domain   = generate_domain+"."+config[:domain]             
            cc   = config[:crosscloud]   
            scm   = config[:scm]
            noi = config[:noofinstances].to_i
            
        if app_name.nil?
          show_usage
          text.fatal("You must specify an book name")
          exit 1
        else
            
            options = mk_node(app_name, domain, cc, scm, noi)
            text.info("start")
            begin
                Megam::Config[:email] = "#{ENV['MEGAM_API_EMAIL']}"
                Megam::Config[:api_key] = "#{ENV['MEGAM_API_KEY']}"
                @excon_res = Megam::Node.create(options) 
             for i in 0..(noi-1)
                ress = @excon_res.data[:body][i].some_msg
                text.info(ress[:msg])
                text.info(ress[:links])         
            end
            #rescue other errors like connection refused by megam_play     
            rescue Megam::API::Errors::ErrorWithResponse => ewr   
               for i in 0..(noi-1)   
                 res = ewr.response.data[:body][i].some_msg
                 text.error(res[:msg])
                 text.msg("#{text.color("Retry Again", :white, :bold)}")
                 text.info(res[:links])
                 end                                              
           end
        end       
      end
      
      def mk_node(app_name, domain, cc, scm, noi)
      
      @com = {
"systemprovider" => {
"provider" => {
"prov" => "chef"
}
},
"compute" => {
"cctype" => "ec2",
"cc" => {
"groups" => "megam",
"image" => "ami-d783cd85",
"flavor" => "t1.micro"
},
"access" => {
"ssh_key" => "megam_ec2",
"identity_file" => "~/.ssh/megam_ec2.pem",
"ssh_user" => "ubuntu"
}
},
"cloudtool" => {
"chef" => {
"command" => "knife",
"plugin" => "ec2 server create", #ec2 server delete or create
"run_list" => "role[opendj]",
"name" => "-N TestOverAll"
}
}
}
    
        node_hash = {
          "node_name" => domain,
  "node_type" => "BOLT",
  "req_type" => "create",
  "noofinstances" => noi,
          "command" => @com,
          "predefs" => {"name" => app_name, "scm" => scm,
            "db" => "postgres@postgresql1.megam.com/morning.megam.co", "war" => "", "queue" => "queue@queue1", "runtime_exec" => "sudo start rails"},
  "appdefns" => {"timetokill" => "0", "metered" => "megam", "logging" => "megam", "runtime_exec" => "runtime_execTOM"},
  "boltdefns" => {"username" => "tom", "apikey" => "123456", "store_name" => "tom_db", "url" => "", "prime" => "", "timetokill" => "", "metered" => "", "logging" => "", "runtime_exec" => ""},
  "appreq" => {},
  "boltreq" => {}
    }
node_hash
end

def generate_domain
  book_name = /\w+/.gen
  book_name.downcase
end

    end
  end
end
