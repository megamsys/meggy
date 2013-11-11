require 'meggy/pug'
require 'meggy/pug/book_create'
require 'meggy/config'
require 'yaml'

describe "RSPEC for Identity List" do

  it "Book:Create" do
	  @id = Meggy::Pug::AccountCreate.new
	@id.name_args = ["alrin"]
	@id.run
	#puts @id.to_yaml
  end


  it "Book:Create" do
	  @id = Meggy::Pug::AccountCreate.new
	@id.name_args = ""
	@id.run
	#puts @id.to_yaml
  end

end
