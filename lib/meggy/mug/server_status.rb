require 'rubygems'
require 'fog'

#http://fog.io/compute/
# create a connection
connection = Fog::Compute.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => YOUR_AWS_ACCESS_KEY_ID,
  :aws_secret_access_key    => YOUR_AWS_SECRET_ACCESS_KEY
})

# Get a list of all the running servers/instances
instance_list = connection.servers.all

num_instances = instance_list.length
puts "We have " + num_instances.to_s()  + " servers"

# Print out a table of instances with choice columns
instance_list.table([:id, :flavor_id, :ip_address, :private_ip_address, :image_id ])

###################################################################
# Get a list of our images
###################################################################
my_images_raw = connection.describe_images('Owner' => 'self')
my_images = my_images_raw.body["imagesSet"]

puts "\n###################################################################################"
puts "Following images are available for deployment"
puts "\nImage ID\tArch\t\tImage Location"

#  List image ID, architecture and location
for key in 0...my_images.length
  print my_images[key]["imageId"], "\t" , my_images[key]["architecture"] , "\t\t" , my_images[key]["imageLocation"],  "\n";
end

###########################################################################
# Get a list our running servers and show their status.
# skip chef, zoo, our, ironfist
###########################################################################
connection.servers.select {|server| server.ready? && {do server.something_by_describing_instances_ofthat_server}
###########################################################################
