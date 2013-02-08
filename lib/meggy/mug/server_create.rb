#http://fog.io/compute/
#http://fog.io/dns/
# create a connection
connection = Fog::Compute.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key    => YOUR_AWS_SECRET_ACCESS_KEY
})

dns = Fog::DNS.new({
  :provider               => 'AWS',
  :aws_access_key_id      => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key  => YOUR_AWS_SECRET_ACCESS_KEY
})

zone = @dns.zones.create(
  :domain => 'example.com',
  :email  => 'admin@example.com'
)

#https://github.com/fog/fog/tree/master/lib/fog/aws/requests/compute

server = connection.servers.create(:image_id => 'ami-1234567',
 :flavor_id =>  'm1.large')

# wait for it to be ready to do stuff
server.wait_for { print "."; ready? }

puts "Public IP Address: #{server.ip_address}"
puts "Private IP Address: #{server.private_ip_address}"
