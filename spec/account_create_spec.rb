require 'meggy/meg'
require 'meggy/meg/account_create'
require 'meggy/config'
require 'yaml'

describe "Account:Create" do

  it "Account create command Success" do
	  @id = Meggy::Meg::AccountCreate.new
	@id.name_args = ["test@meggy.com"]
	@id.run
	puts "SUCCESS"
  end


  it "Account:Create" do
	  @id = Meggy::Meg::AccountCreate.new
	@id.name_args = ""
	@id.text.should_receive(:fatal).with("You must specify an account name")
	@id.run.should raise_error()
	puts "FAIL"
  end

end
