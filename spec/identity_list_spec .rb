require 'meggy/pug'
require 'meggy/pug/identity_create'
require 'meggy/config'
require 'yaml'

describe "RSPEC for Identity List" do

  it "Identity create command Success" do
	  @id = Meggy::Pug::IdentityCreate.new
	@id.name_args = ["alrin"]
	@id.run
	#puts @id.to_yaml
  end


  it "Identity create command fail" do
	  @id = Meggy::Pug::IdentityCreate.new
	@id.name_args = ""
	@id.run
	#puts @id.to_yaml
  end

end
