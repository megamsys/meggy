require 'meggy/meg'
require 'meggy/config'
require 'yaml'

describe "CSAR:Create" do

  it "CSAR Create success" do
	  @id = Meggy::Meg::CSARCreate.new
	  @id.name_args = ["redis", "redismeggy.megam.co", "iaas-default", "github.com"]
	  @id.run
	  puts "SUCCESS"
  end


  it "CSAR Create failure" do
    @id = Meggy::Meg::CSARCreate.new
	  @id.name_args = ""
	  @id.run
	  puts "FAIL"
  end

end
