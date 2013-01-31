class MyConfig
  extend(Mixlib::Config)

  log_level   :info
  config_file "default.rb"
end

class MyCLI
  def run(argv=ARGV)
    parse_options(argv)
    MyConfig.merge!(config)
  end
end

c = MyCLI.new
# ARGV = [ '-l', 'debug' ]
c.run
MyConfig[:log_level] # :debug
