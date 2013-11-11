require 'meggy/pug'
require 'meggy/pug/book_list'
require 'meggy/config'
require 'yaml'

describe "Book:Show" do

  it "Book:Show" do
	  @id = Meggy::Pug::BookList.new
	@id.name_args = ["alrin"]
	@id.run
	puts "SUCCESS"
  end


  it "Book:Show" do
	@id = Meggy::Pug::BookList.new
	@id.name_args = ""
	@id.text.should_receive(:fatal).with("You must specify an account name")
	@id.run.should raise_error()
  end

end
