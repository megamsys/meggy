require File.expand_path("#{File.dirname(__FILE__)}/../lib/meggy/pug")
require File.expand_path("#{File.dirname(__FILE__)}/../lib/meggy/pug/account_create")
#require 'meggy/pug'
require 'meggy/pug/identity_create'
require 'meggy/config'
require 'yaml'

describe "RSPEC for Identity Creation" do

  it "Identity create command Success" do
	  @id = Meggy::Pug::IdentityCreate.new
	@id.name_args = ["alrin"]
	@id.run
	puts "SUCCESS"
  end


  it "Identity create command fail" do
	  @id = Meggy::Pug::IdentityCreate.new
	@id.name_args = ""
	@id.text.should_receive(:fatal).with("You must specify an account name")
	@id.run.should raise_error()
	puts "FAIL"
  end

end
