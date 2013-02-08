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

class Meggy
  class Pug

    include Mixlib::CLI

    attr_accessor :name_args
    # Configure mixlib-cli to always separate defaults from user-supplied CLI options
    def self.use_separate_defaults?
      true
    end

    def self.reset_subcommands!
      @@subcommands = {}
      @subcommands_by_category = nil
    end

    def self.inherited(subclass)
      unless subclass.unnamed?
        subcommands[subclass.snake_case_name] = subclass
      end
    end
    
    def self.msg(msg="")
      puts msg
    end

    # Explicitly set the category for the current command to +new_category+
    # The category is normally determined from the first word of the command
    # name, but some commands make more sense using two or more words
    # ===Arguments
    # new_category::: A String to set the category to (see examples)
    # ===Examples:
    # Data bag commands would be in the 'data' category by default. To put them
    # in the 'data bag' category:
    #   category('data bag')
    def self.category(new_category)
      @category = new_category
    end

    def self.subcommand_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end

    def self.common_name
      snake_case_name.split('_').join(' ')
    end

    # Does this class have a name? (Classes created via Class.new don't)
    def self.unnamed?
      name.nil? || name.empty?
    end

    #merge the above method into one. screwy the self(static) is playing spoil sport
    #now we need to make all the functions that is called by load_commands as static.
    def self.load_commands
      @commands_loaded ||= file_load_commands
    end

    # Load all the sub-commands
    def self.file_load_commands
      subcommand_files.each { |subcommand| Kernel.load subcommand }
      true
    end

    def self.subcommand_files
      @subcommand_files ||= (find_subcommands_via_dirglob.values).flatten.uniq
    end

    def self.find_subcommands_via_dirglob
      # The "require paths" of the core meggy subcommands bundled with chef
      files = Dir[File.expand_path('../../../pug/*.rb', __FILE__)]
      subcommand_files = {}
      files.each do |meggy_command_file|
        rel_path = meggy_command_file[/#{MEGGY_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
        msg rel_path
        subcommand_files[rel_path] = meggy_command_file
      end
      subcommand_files
    end

    def self.subcommands
      @@subcommands ||= {}
    end

    def self.subcommands_by_category
      unless @subcommands_by_category
        @subcommands_by_category = Hash.new { |hash, key| hash[key] = [] }
        subcommands.each do |snake_cased, klass|
          @subcommands_by_category[klass.subcommand_category] << snake_cased
        end
      end
      @subcommands_by_category
    end

    # Print the list of subcommands knife knows about. If +preferred_category+
    # is given, only subcommands in that category are shown
    def self.list_commands(preferred_category=nil)
      load_commands

      category_desc = preferred_category ? preferred_category + " " : ''
      msg "Available #{category_desc}subcommands: (for details, pug SUB-COMMAND --help)\n\n"

      if preferred_category && subcommands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => subcommands_by_category[preferred_category]}
      else
        commands_to_show = subcommands_by_category
      end

      commands_to_show.sort.each do |category, commands|
        next if category =~ /deprecated/i
        msg "** #{category.upcase} COMMANDS **"
        commands.each do |command|
          msg subcommands[command].banner if subcommands[command]
        end
        msg
      end
    end

    # Run knife for the given +args+ (ARGV), adding +options+ to the list of
    # CLI options that the subcommand knows how to handle.
    # ===Arguments
    # args::: usually ARGV
    # options::: A Mixlib::CLI option parser hash. These +options+ are how
    # subcommands know about global knife CLI options
    def self.run(args, options={})
      load_commands
      subcommand_class = subcommand_class_from(args)
      subcommand_class.options = options.merge!(subcommand_class.options)
      subcommand_class.load_deps
      instance = subcommand_class.new(args)
      instance.configure_chef
      instance.run_with_pretty_exceptions
    end

    def self.guess_category(args)
      category_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }
      category_words.map! {|w| w.split('-')}.flatten!
      matching_category = nil
      while (!matching_category) && (!category_words.empty?)
        candidate_category = category_words.join(' ')
        matching_category = candidate_category if subcommands_by_category.key?(candidate_category)
        matching_category || category_words.pop
      end
      matching_category
    end

    def self.subcommand_class_from(args)
      command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }

      subcommand_class = nil

      while ( !subcommand_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless subcommand_class = subcommands[snake_case_class_name]
        command_words.pop
        end
      end
      # see if we got the command as e.g., knife node-list
      subcommand_class ||= subcommands[args.first.gsub('-', '_')]
      subcommand_class || subcommand_not_found!(args)
    end

    def self.deps(&block)
      @dependency_loader = block
    end

    def self.load_deps
      @dependency_loader && @dependency_loader.call
    end

    private

    OFFICIAL_PLUGINS = %w[ec2 rackspace windows openstack terremark bluebox]

    # :nodoc:
    # Error out and print usage. probably becuase the arguments given by the
    # user could not be resolved to a subcommand.
    def self.subcommand_not_found!(args)
      ui.fatal("Cannot find sub command for: '#{args.join(' ')}'")

      if category_commands = guess_category(args)
        list_commands(category_commands)
      elsif missing_plugin = ( OFFICIAL_PLUGINS.find {|plugin| plugin == args[0]} )
        ui.info("The #{missing_plugin} commands were moved to plugins in Chef 0.10")
        ui.info("You can install the plugin with `(sudo) gem install knife-#{missing_plugin}")
      else
        list_commands
      end

      exit 10
    end

    def self.working_directory
      ENV['PWD'] || Dir.pwd
    end

    public

    # Create a new instance of the current class configured for the given
    # arguments and options
    def initialize(argv=[])
      super() # having to call super in initialize is the most annoying anti-pattern :(

      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      @name_args = parse_options(argv)
      @name_args.delete(command_name_words.join('-'))
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # knife node run_list add requires that we have extra logic to handle
      # the case that command name words could be joined by an underscore :/
      command_name_words = command_name_words.join('_')
      @name_args.reject! { |name_arg| command_name_words == name_arg }

      if config[:help]
        msg opt_parser
        exit 1
      end

      # copy Mixlib::CLI over so that it cab be configured in knife.rb
      # config file
      Chef::Config[:verbosity] = config[:verbosity]
    end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      show_usage
      exit(1)
      end

    def show_usage
      stdout.puts("USAGE: " + self.opt_parser.to_s)
    end

    def run_with_pretty_exceptions
      unless self.respond_to?(:run)
        ui.error "You need to add a #run method to your knife command before you can use it"
      end
      enforce_path_sanity
      run
    rescue Exception => e
      raise if Chef::Config[:verbosity] == 2
      humanize_exception(e)
      exit 100
      end

    def humanize_exception(e)
      case e
      when SystemExit
        raise # make sure exit passes through.
      when Net::HTTPServerException, Net::HTTPFatalError
        humanize_http_exception(e)
      when Errno::ECONNREFUSED, Timeout::Error, Errno::ETIMEDOUT, SocketError
        ui.error "Network Error: #{e.message}"
        ui.info "Check your knife configuration and network settings"
      when NameError, NoMethodError
        ui.error "knife encountered an unexpected error"
        ui.info  "This may be a bug in the '#{self.class.common_name}' knife command or plugin"
        ui.info  "Please collect the output of this command with the `-VV` option before filing a bug report."
        ui.info  "Exception: #{e.class.name}: #{e.message}"
      when Chef::Exceptions::PrivateKeyMissing
        ui.error "Your private key could not be loaded from #{api_key}"
        ui.info  "Check your configuration file and ensure that your private key is readable"
      else
      ui.error "#{e.class.name}: #{e.message}"
      end
    end

  end
end
