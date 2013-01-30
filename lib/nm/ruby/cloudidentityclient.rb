#!/usr/bin/ruby

require './embedded_client.rb'

tmp  = EmbeddedClient.new
client = tmp.get_client("cloudidentity")

client.listrealms(:msg => "Howdy megam").each do |resp|
   printf("%-40s: %s\n", resp[:sender], resp[:data][:msg])
end

