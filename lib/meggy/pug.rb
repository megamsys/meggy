#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'meggy/version'
require 'mixlib/cli'
require 'pp'
require 'meggy/core/text'
require 'net/http'

class Meggy
  class Pug
   
    #include(a_module) is called inside a class, and adds module methods as instance methods.
    #extend(a_module) adds all module methods to the instance it is called on.
    include Mixlib::CLI
   
    #attr_accessors are setters/getters in ruby.  The arguments are filtered and available for use
    #to subclasses.
    attr_accessor :name_args
    #text is used to print stuff in the terminal (message, log, info, warn etc.)
    attr_accessor :text
    
    def self.text
      @text ||= Meggy::Text.new(STDOUT, STDERR, STDIN, {})
    end
    
    # I don't think we need this method. Will remove it later.
    # We need to just call text.msg
    def self.msg(msg="")
      text.msg(msg)
    end
    
    # Configure mixlib-cli to always separate defaults from user-supplied CLI options
    # Override this method that exits in mixlib-cli. As per doc in mixlib-cli
    # When this setting is set to +true+, default values supplied to the
    # mixlib-cli DSL will be stored in a separate Hash
    def self.use_separate_defaults?
      true
    end

    # Not used anywhere. It is used for rspec testing.
    # If you invoked and reset_subcommands array then, call
    # load_commands to load it back.
    def self.reset_subcommands!
      @@subcommands = {}
      @subcommands_by_category = nil
    end

    # As per the ruby doc, Callback(which in case is inherited) invoked whenever a
    # subclass of the current class is created. http://www.ruby-doc.org/core-1.9.3/Class.html
    def self.inherited(subclass)
      unless subclass.unnamed?
        subcommands[subclass.snake_case_name] = subclass
      end
    end
    
    # Does this class have a name? (Classes created via Class.new don't)
    def self.unnamed?
      name.nil? || name.empty?
    end

    
    # Explicitly set the category for the current command to +new_category+
    # The category is normally determined from the first word of the command
    # name, but some commands make more sense using two or more words
    # ===Arguments
    # new_category::: A String to set the category to (see examples)
    # ===Examples:
    # Species Alien commands would be in the 'species' category by default. To put them
    # in the 'species alien' category:
    #   category('species alien')
    def self.category(new_category)
      @category = new_category
    end

    # The category is normally determined from the first word of the command
    # name, but some commands make more sense using two or more words
    # ===Examples:
    # identity_create commands would be in the 'identity' category by default.
    def self.subcommand_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.common_name
      snake_case_name.split('_').join(' ')
    end

    #snake_case is the practice of writing compound words or phrases in which the elements are separated with one
    #underscore character (_) and no spaces, with each element's initial letter usually lowercased within the compound
    #and the first letter either upper or lower case—as in "foo_bar", "Hello_world"
    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end
  
    ## Let us say the string input was IdentityList
    ## read through each of the expression to see how the output is arrived at identity_list
    def self.convert_to_snake_case(str, namespace=nil)
      str = str.dup # clone the string, => IdentityList
      str.sub!(/^#{namespace}(\:\:)?/, '') if namespace # => IdentityList, remove the namespace if one was provided.
      str.gsub!(/[A-Z]/) {|s| "_" + s} # => _Identity_List, include the _
      str.downcase! # => _identity_list 
      str.sub!(/^\_/, "") # => identity_list, remove the starting _
      str
    end

    #merge the above method into one. screwy the self(static) is playing spoil sport
    #now we need to make all the functions that is called by load_commands as static.
    #we load all the files under an application, if its pug then the ruby files under
    #lib/meggy/pub/*.rb are loaded. We don't look for the gem files currently.
    def self.load_commands
      @commands_loaded ||= file_load_commands
    end

    # Load all the sub-commands by calling subcommand_files, and executes them in the ruby kernel.
    #http://www.ruby-doc.org/core-1.9.3/Kernel.html#method-i-load
    def self.file_load_commands
      subcommand_files.each { |subcommand| Kernel.load subcommand }
      true
    end
    
    #Lists all the subcommand .rb files under the MEGGYROOT/lib/meggy/<app>*.rb
    #using a helper
    def self.subcommand_files
      @subcommand_files ||= (find_subcommands_via_dirglob.values).flatten.uniq
    end

    #Lists all the subcommand .rb files under the MEGGYROOT/lib/meggy/<app>*.rb
    def self.find_subcommands_via_dirglob
      # The "require paths" of the core meggy subcommands bundled with meggy
      #  __FILE__ points to ~meggy/lib/meggy/pug.rb
      # Grab the directory of pug command files.
      files = Dir[File.expand_path('../pug/*.rb', __FILE__)] #
      subcommand_files = {}
      # Under each of the meggy/pug directory, Grab the *.rb files.
      # subcommand_files stores it in a hash 
      # eg: {"meggy/pug/identity_list"=>"/home/ram/code/megam/workspace/meggy/lib/meggy/pug/identity_list.rb"}
      files.each do |meggy_command_file|
        rel_path = meggy_command_file[/#{MEGGY_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
        subcommand_files[rel_path] = meggy_command_file
      end
      subcommand_files
    end

    def self.subcommands
      @@subcommands ||= {}
    end

    #sends out a subcommand and its category. The sample shows for category identity, help, list
    #{"identity"=>["identity_list", "identity_create", "identity_delete"], "help"=>["help"], "login"=>["login"]}
    def self.subcommands_by_category
      unless @subcommands_by_category
        @subcommands_by_category = Hash.new { |hash, key| hash[key] = [] } # create a new hash, with empty keys.
        subcommands.each do |snake_cased, klass|   # for each of the subcommands loaded,
          @subcommands_by_category[klass.subcommand_category] << snake_cased # mutation of key identity, eg: {"identity"=>["identity_list"]}
        end
      end
      @subcommands_by_category
    end

    # Print the list of subcommands pug knows about. If +preferred_category+
    # is given, only subcommands in that category are shown
    def self.list_commands(preferred_category=nil)
      load_commands  # load the commands.
      category_desc = preferred_category ? preferred_category + " " : ''
      msg "Available #{category_desc}subcommands: (for details, pug SUB-COMMAND --help)\n\n"
      
      #If the preferred category is "identity" then all the subcommands pertaining to that are shown.
      if preferred_category && subcommands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => subcommands_by_category[preferred_category]}
      else
        commands_to_show = subcommands_by_category
      end
      
      #show the commands, by calling their banner.
      commands_to_show.sort.each do |category, commands|
        next if category =~ /deprecated/i
        msg "** #{category.upcase} COMMANDS **"
        commands.each do |command|
          msg subcommands[command].banner if subcommands[command]
        end
        msg
      end
    end

    # Run pug for the given +args+ (ARGV), adding +options+ to the list of
    # CLI options that the subcommand knows how to handle.
    # ===Arguments
    # args::: usually ARGV
    # options::: A Mixlib::CLI option parser hash. These +options+ are how
    # subcommands know about global pug CLI options
    def self.run(args, options={})
      load_commands # load all subcommands in meggy/pug/*.rb in separated categories.
      subcommand_class = subcommand_class_from(args) # figure out the subcommand class from args.
      subcommand_class.options = options.merge!(subcommand_class.options) # merge both the options in app::pug into this one.
      subcommand_class.load_deps #if there is a deps block inside the subcommand class load them.
      # Time to get started, instantiate the subcommand class. This calls the initialize of Meggy::Pug.
      instance = subcommand_class.new(args) 
      # configure your meggy
      instance.configure_meggy
      # run your subcommand class.
      instance.run_with_pretty_exceptions
    end
    
    # If the subcommand class can't be located, try and see if you have something.
    # arguments =1. ["identito", "create"] in this case  no match will be found for category identito
    #            2. ["identity", "show"] in this case a matching category will be found.
    def self.guess_category(args)
      category_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ } # ["identito", "create"]
      category_words.map! {|w| w.split('-')}.flatten!
      matching_category = nil
      while (!matching_category) && (!category_words.empty?)
        candidate_category = category_words.join(' ') # identito create
        # subcommand matching category is performed for identito create
        matching_category = candidate_category if subcommands_by_category.key?(candidate_category) 
        matching_category || category_words.pop        
      end
      matching_category
    end
    
    # The is pretty much the same functional behaviour as guess_category, just that
    # from the argumentes, the subcommand_class is figured out. 
    # if it doesn't exists then subcommand_not_found is called.
    def self.subcommand_class_from(args)
      command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }
      subcommand_class = nil
      while ( !subcommand_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless subcommand_class = subcommands[snake_case_class_name]
        command_words.pop
        end
      end
      # see if we got the command as e.g., pug node-list
      subcommand_class ||= subcommands[args.first.gsub('-', '_')]
      subcommand_class || subcommand_not_found!(args)
    end
  
    # A block that may exist in subcommand classes eg: identity_create may have a block 
    # deps
    #   require "xyz"
    # end
    # If so, then that block will be loaded when the subcommand is loaded.
    def self.deps(&block)
      @dependency_loader = block
    end
    
    # loads the block of deps, as set by the deps block in each of the subcommand.
    # 
    def self.load_deps
      @dependency_loader && @dependency_loader.call
    end

    private

    # :nodoc:
    # Error out and print usage. probably becuase the arguments given by the
    # user could not be resolved to a subcommand.
    def self.subcommand_not_found!(args)
      text.fatal("Cannot find sub command for: '#{args.join(' ')}'")
      
      # if the category can't be guessed then print
      # all of the commands
      if category_commands = guess_category(args) 
        list_commands(category_commands)
      else
        list_commands
      end

      exit 10
    end

    def self.working_directory
      ENV['PWD'] || Dir.pwd
    end

    def self.reset_config_path!
      @@meggy_config_dir = nil
    end

    reset_config_path!

    public

    # Create a new instance of the current class configured for the given
    # arguments and options
    def initialize(argv=[])
      super() 
      @text = Text.new(STDOUT, STDERR, STDIN, config)
      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      
      @name_args = parse_options(argv)

      @name_args.delete(command_name_words.join('-'))
      
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # pug node run_list add requires that we have extra logic to handle
      # the case that command name words could be joined by an underscore :/
      command_name_words = command_name_words.join('_')
      @name_args.reject! { |name_arg| command_name_words == name_arg }
      if config[:help]
        msg opt_parser
        exit 1
      end

    # copy Mixlib::CLI over so that it cab be configured in pug.rb
    # config file
     Meggy::Config[:verbosity] = config[:verbosity]
    end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      show_usage
      exit(1)
      end

    # Returns a subset of the Meggy::Config[:pug] Hash that is relevant to the
    # currently executing pug command. This is used by #configure_meggy to
    # apply settings from pug.rb to the +config+ hash.
    def config_file_settings
      config_file_settings = {}
      self.class.options.keys.each do |key|
        config_file_settings[key] = Meggy::Config[:pug][key] if Meggy::Config[:pug].has_key?(key)
      end
      config_file_settings
    end

    def locate_config_file
      # Look for $HOME/.meggy/pug.rb
      if ENV['HOME']
        user_config_file =  File.expand_path(File.join(ENV['HOME'], '.meggy', 'pug.rb'))
      end

      if File.exist?(user_config_file)
        config[:config_file] = user_config_file
      end
    end

    # Apply Config in this order:
    # defaults from mixlib-cli
    # settings from config file, via Meggy::Config[:pug]
    # config from command line
    def merge_configs
      # Apply config file settings on top of mixlib-cli defaults
      combined_config = default_config.merge(config_file_settings)
      # Apply user-supplied options on top of the above combination
      combined_config = combined_config.merge(config)
      # replace the config hash from mixlib-cli with our own.
      # Need to use the mutate-in-place #replace method instead of assigning to
      # the instance variable because other code may have a reference to the
      # original config hash object.
      config.replace(combined_config)
    end

    # Catch-all method that does any massaging needed for various config
    # components, such as expanding file paths and converting verbosity level
    # into log level.
    def apply_computed_config
      Meggy::Config[:color] = config[:color]

      case Meggy::Config[:verbosity]
      when 0, nil
        Meggy::Config[:log_level] = :error
      when 1
        Meggy::Config[:log_level] = :info
      else
      Meggy::Config[:log_level] = :debug
      end

      Meggy::Config[:node_name] = config[:node_name] if config[:node_name]
      Meggy::Config[:client_key] = config[:client_key] if config[:client_key]
      Meggy::Config[:meggy_server_url] = config[:meggy_server_url] if config[:meggy_server_url]

      # Expand a relative path from the config directory. Config from command
      # line should already be expanded, and absolute paths will be unchanged.
      if Meggy::Config[:client_key] && config[:config_file]
        Meggy::Config[:client_key] = File.expand_path(Meggy::Config[:client_key], File.dirname(config[:config_file]))
      end

      Mixlib::Log::Formatter.show_time = false
      Meggy::Log.init(Meggy::Config[:log_location])
      Meggy::Log.level(Meggy::Config[:log_level] || :error)

      if Meggy::Config[:node_name] && Meggy::Config[:node_name].bytesize > 90
        # node names > 90 bytes only work with authentication protocol >= 1.1
        # see discussion in config.rb.
        Meggy::Config[:authentication_protocol_version] = "1.1"
      end
    end

    # configure meggy, to startwith locate the config file under .meggy/pug.rb
    # Once located, read the pug.rb config file. parse them, and report any ruby syntax errors.
    # if not merge then inside Meggy::Config object.
    def configure_meggy
      unless config[:config_file]
        locate_config_file
      end
      # Don't try to load a pug.rb if it doesn't exist.
      if config[:config_file]
        Meggy::Log.debug("Using configuration from #{config[:config_file]}")
        read_config_file(config[:config_file])
      else
      # ...but do log a message if no config was found.
        Meggy::Config[:color] = config[:color]
        text.warn("No pug configuration file found")
      end

      merge_configs
      apply_computed_config
    end
    
    # reads all the config from the .meggy/pug.rb and stores it inside Meggy::Config
    def read_config_file(file)
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



      #ERROR: You have invalid ruby syntax in your config file /home/ram/.meggy/pug.rb
      #/home/ram/.meggy/pug.rb:9: syntax error, unexpected '='
      #pug[:username] > = "admin"
      #                  ^
      # # /home/ram/.meggy/pug.rb
      #  8: meggy_server_url          'http://localhost:6167'
      #  9: pug[:username] > = "admin"
      # 10: pug[:password] = "team4dog"
      # Line 9 is marked in red, and the 3rd line where the error is show is highlighted in red.
      #This is in case of a ruby parse error.
    def highlight_config_error(file, line)
      config_file_lines = []

      # A file line is split into the line number (index) and the line content. 
      # The line number is converted to string (to_s), right justified 3 characters with a colon, and its trimmed (chomp) 
      
      IO.readlines(file).each_with_index {|l, i| config_file_lines << "#{(i + 1).to_s.rjust(3)}: #{l.chomp}"}
      # mark the appropriate line with a red color, if its just one line, then mark the zeroth line.
      # if not get the range (deducting 2), and mark the second line.
      if line == 1
        lines = config_file_lines[0..3]
        lines[0] = text.color(lines[0], :red)
      else
        lines = config_file_lines[Range.new(line - 2, line)]
        lines[1] = text.color(lines[1], :red)
      end
      text.msg ""
      # print the name of the file in white
      text.msg text.color(" # #{file}", :white)
      # print the rest of the line.
      lines.each {|l| text.msg(l)}
      text.msg ""
    end

    def show_usage
      text.stdout.puts("USAGE: " + self.opt_parser.to_s)
    end

    
     #As per the ruby doc, 
     #Returns true if obj responds to the given method. 
     #Private methods are included in the search only if the optional second parameter evaluates to true. 
     #http://www.ruby-doc.org/core-1.9.3/Object.html#method-i-respond_to-3F
     #in this case we verify if the subcommand class has a run method.
    def run_with_pretty_exceptions
      unless self.respond_to?(:run)
        text.error "You need to add a #run method to your pug command before you can use it"
      end
      run
    rescue Exception => e
      raise if Meggy::Config[:verbosity] == 2
      humanize_exception(e)
      exit 100
      end
    
    #report the exceptions in a usable format for the user.
    def humanize_exception(e)
      case e
      when SystemExit
        raise # make sure exit passes through.
      when Net::HTTPServerException, Net::HTTPFatalError
        humanize_http_exception(e)
      when Errno::ECONNREFUSED, Timeout::Error, Errno::ETIMEDOUT, SocketError
        text.error "Network Error: #{e.message}"
        text.info "Check your pug configuration and network settings"
      when NameError, NoMethodError
        text.error "pug encountered an unexpected error"
        text.info  "This may be a bug in the '#{self.class.common_name}' pug command or plugin"
        text.info  "Please collect the output of this command with the `-VV` option before filing a bug report."
        text.info  "Exception: #{e.class.name}: #{e.message}"
      when Meggy::Exceptions::PrivateKeyMissing
        text.error "Your private key could not be loaded from #{api_key}"
        text.info  "Check your configuration file and ensure that your private key is readable"
      else
      text.error "#{e.class.name}: #{e.message}"
      end
    end

  end
end
