require 'meggy/pug'
require 'meggy/pug/account_create'
require 'meggy/config'
require 'yaml'

def read_config_file(file)
  #puts "Test-read config"
  Meggy::Config.from_file(file)
rescue SyntaxError => e
  @text.error "You have invalid ruby syntax in your config file #{file}"
  @text.info(text.color(e.message, :red))
  if file_line = e.message[/#{Regexp.escape(file)}:[\d]+/]
    line = file_line[/:([\d]+)$/, 1].to_i
    highlight_config_error(file, line)
  end
  exit 1
rescue Exception => e
  @text.error "You have an error in your config file #{file}"
  @text.info "#{e.class.name}: #{e.message}"
  filtered_trace = e.backtrace.grep(/#{Regexp.escape(file)}/)
  filtered_trace.each {|line| text.msg(" " + text.color(line, :red))}
  if !filtered_trace.empty?
    line_nr = filtered_trace.first[/#{Regexp.escape(file)}:([\d]+)/, 1]
    highlight_config_error(file, line_nr.to_i)
  end

  exit 1
  end

def locate_config_file
  if ENV['HOME']
    user_config_file =  File.expand_path(File.join(ENV['HOME'], '.meggy', 'pug.rb'))
  end
  puts "Config File"
  puts user_config_file
  if File.exist?(user_config_file)
    read_config_file(user_config_file)
  end
end

describe "RSPEC for config" do
  @id = Meggy::Pug::AccountCreate.new
  @test = Meggy::Pug.find_subcommands_via_dirglob
  @test1 = Meggy::Pug.new
  @test.each do |data|
    puts data
  end
  locate_config_file
  acc_name = Meggy::Config[:node_name]
  @id.name_args = acc_name
  it "should return node name" do
Meggy::Config[:node_name].should == "alrin"
  end
  it "should return node name fail" do
   puts "Node name : "+Meggy::Config[:node_name]
	Meggy::Config[:node_name].should_not == "alrin"
  end

end
