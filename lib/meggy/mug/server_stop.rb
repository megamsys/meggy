#http://fog.io/compute/
#http://fog.io/dns/
# create a connection
connection = Fog::Compute.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key    => YOUR_AWS_SECRET_ACCESS_KEY
})


#https://github.com/fog/fog/tree/master/lib/fog/aws/requests/compute
# have some default instance id's for chef, zoo,our[megam.co.in], ironfist (or) the user needs to enter it'
#use preconfigured addresses for chef, zoo, our, ironfist. We may move it to config.rb.
connection.stop_instances(instance_id)

###########################################################################
# Get a list our running servers and destroy them
# This is dangerous. As it deletes the instance itself. CAUTION
###########################################################################
connection.servers.select {|server| server.ready? && server.destroy}
###########################################################################
# Get a list our running servers and destroy only those not in a LIST.
# example skip chef, zoo, our, ironfist
# This is dangerous. As it deletes the instance itself. CAUTION
###########################################################################
connection.servers.select {|server| server.ready? && server.destroy}
###########################################################################
