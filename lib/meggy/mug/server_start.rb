#http://fog.io/compute/
#http://fog.io/dns/
# create a connection
connection = Fog::Compute.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key    => YOUR_AWS_SECRET_ACCESS_KEY
})

#the addresses may be moved to Route53. Need to set it up. So the associate address will be smooth.
dns = Fog::DNS.new({
  :provider               => 'AWS',
  :aws_access_key_id      => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key  => YOUR_AWS_SECRET_ACCESS_KEY
})

#https://github.com/fog/fog/tree/master/lib/fog/aws/requests/compute
# have some default instance id's for chef, zoo,our[megam.co.in], ironfist (or) the user needs to enter it'
connection.start_instances(instance_id)

#use preconfigured addresses for chef, zoo, our, ironfist. We may move it to config.rb.
#associate-address of the running instance to something.
server = connection.servers.create(:image_id => 'ami-1234567', :flavor_id =>  'm1.large')

# wait for it to be ready to do stuff
server.wait_for { print "."; ready? }

puts "Public IP Address: #{server.ip_address}"
puts "Private IP Address: #{server.private_ip_address}"
