#!/usr/bin/ruby


require 'mcollective'


include MCollective::RPC

mc = rpcclient("cloudidentity")

mc.listrealms(:msg => "Howdy megam") .each do |resp|
   printf("%-40s: %s\n", resp[:sender], resp[:data][:msg])
end


