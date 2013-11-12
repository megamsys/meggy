require 'meggy/pug'
require 'meggy/pug/book_create'
require 'meggy/config'
require 'yaml'

describe "Book:Create" do

  it "Book Create command success" do
	  @id = Meggy::Pug::BookCreate.new
	@id.name_args = ["redis", "redismeggy.megam.co", "iaas-default", "github.com"]
	@id.run
	#puts @id.to_yaml
	puts "SUCCESS"
  end


  it "Book:Create" do
	  @id = Meggy::Pug::BookCreate.new
	@id.name_args = ""
	@id.run
	puts "FAIL"
	#puts @id.to_yaml
  end

end
