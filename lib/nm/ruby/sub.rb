require 'stomp'
require './ironfist_common'

#
# The current require dance for different Ruby versions.
# Change this to suit your requirements.
#
# == Stomp 1.1 - Ironfist Subscriber
#
# Purpose: to demonstrate a connect and disconnect sequence using Stomp 1.1
# with the Stomp#Client interface.
#
class IronfistSubscriber
  include Ironfist
  # Initialize.
  def initialize
    @ironinit = Ironfist::Init.new
  end

  # Run example.
  def run
    #
    # Get a connection
    # ================
    #
    client = @ironinit.get_client
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

    puts "Subscribing to #{@ironinit.topicname}"

    client.subscribe(@ironinit.topicname) do |msg|
      puts msg.to_s
      puts "----------------"
    end

    loop do
      sleep(1)
      puts "."
    end
    #
    # Finally close
    # =============
    #
    client.close # Business as usual, just like 1.0
    puts "Client close complete"
  end
end

#
e = IronfistSubscriber.new
e.run

