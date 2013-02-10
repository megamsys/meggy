#
# License:: Apache License, Version 2.0
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

require 'meggy/pug'
require 'meggy/app'
require 'mixlib/log'

#Pug : The maa CLI interface which is used for cloud instrumenting cloud infrastructure provisioned by
#CHEF.
#
class Meggy::App::Pug < Meggy::App

  NO_COMMAND_GIVEN = "You need to pass a sub-command (e.g., pug SUB-COMMAND)\n"

  banner "Usage: pug sub-command (options)"
  
  #We need to debate why and where will each of these common options be used.
  option :config_file,
    :short => "-c CONFIG",
    :long => "--config CONFIG",
    :description => "The configuration file to use",
    :proc => lambda { |path| File.expand_path(path, Dir.pwd) }

  verbosity_level = 0
  option :verbosity,
    :short => '-V',
    :long => '--verbose',
    :description => "More verbose output. Use twice for max verbosity",
    :proc => Proc.new { verbosity_level += 1},
    :default => 0

  option :color,
    :long         => '--[no-]color',
    :boolean      => true,
    :default      => true,
    :description  => "Use colored output, defaults to enabled"

  option :enviroment,
    :short        => "-E ENVIRONMENT",
    :long         => "--environment ENVIRONMENT",
    :description  => "Set the Meggy environment"

  option :editor,
    :short        => "-e EDITOR",
    :long         => "--editor EDITOR",
    :description  => "Set the editor to use for interactive commands",
    :default      => ENV['EDITOR']

  option :disable_editing,
    :short        => "-d",
    :long         => "--disable-editing",
    :description  => "Do not open EDITOR, just accept the data as is",
    :boolean      => true,
    :defaut       => false

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :exit         => 0

  option :yes,
    :short => "-y",
    :long => "--yes",
    :description => "Say yes to all prompts for confirmation"

  option :defaults,
    :long => "--defaults",
    :description => "Accept default values for all questions"

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show meggy version",
    :boolean      => true,
    :proc         => lambda {|v| puts "Meggy: #{::Meggy::VERSION}"},
    :exit         => 0
  # Run the "pug app". Let it roam and stay by our side.[Go pug, come back for us].
  # The first thing run does is it parses the options. Once the first level of parsing is done,
  # ie the help, no_command, sub_command entry is verified it proceeds to call 
  # Meggy_Pug with the user entered options and arguments (ARGV)
  def run
    Mixlib::Log::Formatter.show_time = false
    validate_and_parse_options
    quiet_traps
    # As you see here the run method is a self method (static), hence the initialize in 
    #Meggy_Pug doesn't get called yet during the below invocation.
    Meggy::Pug.run(ARGV, options) 
    exit 0
  end

  private

  ##Traps are being set for the following when an application starts.
  ##SIGINT        2       Term    Interrupt from keyboard
  ##SIGQUIT       3       Core    Quit from keyboard
  def quiet_traps
    trap("TERM") do
      exit 1
    end

    trap("INT") do
      exit 2
    end
  end

  # A check is performed to see of the command is entered, if a sub command exists, # 
  # a version request or a help request.
  def validate_and_parse_options
    # Checking ARGV validity *before* parse_options because parse_options
    # mangles ARGV in some situations
    if no_command_given?
      print_help_and_exit(1, NO_COMMAND_GIVEN)
    elsif no_subcommand_given?
      if (want_help? || want_version?)
        print_help_and_exit
      else
        print_help_and_exit(2, NO_COMMAND_GIVEN)
      end
    end
  end

  def no_subcommand_given?
    ARGV[0] =~ /^-/
  end

  def no_command_given?
    ARGV.empty?
  end

  def want_help?
    ARGV[0] =~ /^(--help|-h)$/
  end

  def want_version?
    ARGV[0] =~ /^(--version|-v)$/
  end
  
  # Print the help message with the exit code.  If no command is given, then a fatal message is printed.
  # The options are parsed by calling the parse_options present in the mixlib cli as extended by the super class app.
  # A error gets caught and results in an ugly stack trace, which probably needs to be shown in an elegant way.
  # The stacK should be logged using the debug_stacktrace method in the super class.
  # The static method list_commands print the help of all the available commands.
  def print_help_and_exit(exitcode=1, fatal_message=nil)

    Meggy::Log.error(fatal_message) if fatal_message

    begin
      self.parse_options
    rescue OptionParser::InvalidOption => e
      puts "#{e}\n"
    end
    puts self.opt_parser
    Meggy::Pug.list_commands

    exit exitcode
  end

end
