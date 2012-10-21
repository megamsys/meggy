require 'stomp'
require 'ruby-progressbar'
require './ironfist_common'

#
# The current require dance for different Ruby versions.
# Change this to suit your requirements.
## == Stomp 1.1 - Ironfist Publisher
#
# Purpose: to demonstrate a connect and disconnect sequence using Stomp 1.1
# with the Stomp#Client interface.
#
class Pub
  include Ironfist

  # Initialize.
  def initialize
    @ironinit = Ironfist::Init.instance
  end
  # Run example.
  def run
    #
    # Get a connection
    # ================
    #
    client = @ironinit.client
    puts "Client Connect complete"
    #
    # Let's just do some sanity checks, and look around.
    #
    raise "Connection failed!!" unless client.open?
    #
    # Is this really a 1.1 conection? (For clients, 'protocol' is a public method.
    # The value will be '1.0' for those types of connections.)
    #
    # raise "Unexpected protocol level" if client.protocol() != Stomp::SPL_11
    #
    # The broker _could_ have returned an ERROR frame (unlikely).
    # For clients, 'connection_frame' is a public method.
    #
    raise "Connect error: #{client.connection_frame().body}" if client.connection_frame().command == Stomp::CMD_ERROR
    #
    # Examine the CONNECT response (the connection_frame()).
    #
    puts "Connected Headers required to be present:"
    puts "Connect version - \t#{client.connection_frame().headers['version']}"
    puts
    puts "Connected Headers that are optional:"
    puts "Connect server - \t\t#{client.connection_frame().headers['server']}"
    puts "Session ID - \t\t\t#{client.connection_frame().headers['session']}"
    puts "Server requested heartbeats - \t#{client.connection_frame().headers['heart-beat']}"
    
    
    message = "AGENT=MEGAM COMMAND=CREATEREALM MESSAGE={ urls : http://megam.co.in} MSGTIME=00001 REQUESTID=00001"    
  
    ### publish to a topic.    
    pb =  ProgressBar.create(:title => "Published to #{@ironinit.topicreplyname}", :starting_at => 0, :total => 100)
    for i in (1..100)
      client.publish(@ironinit.topicreplyname, "#{i}: #{message}")
      pb.progress += 1
      sleep 0.4      
   end
   pb.finish
            
    #
    # Finally close
    # =============
    #
    client.close # Business as usual, just like 1.0
    puts "Client close complete"
  end
end
#
e = Pub.new
e.run

