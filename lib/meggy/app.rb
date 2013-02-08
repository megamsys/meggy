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

require 'pp'
require 'socket'
require 'meggy/core/exceptions'
require 'meggy/core/log'
require 'mixlib/cli'
require 'tmpdir'

class Meggy::App
  include Mixlib::CLI
  
  class Wakeup < Exception
  end

  def initialize
    super

    @meggy_client_json = nil
    trap("TERM") do
      Meggy::App.fatal!("SIGTERM received, stopping", 1)
    end

    trap("INT") do
      Meggy::App.fatal!("SIGINT received, stopping", 2)
    end

    trap("QUIT") do
      Meggy::Log.info("SIGQUIT received, call stack:\n  " + caller.join("\n  "))
    end

    trap("HUP") do
      Meggy::Log.info("SIGHUP received, reconfiguring")
      reconfigure
    end

  # Always switch to a readable directory. Keeps subsequent Dir.chdir() {}
  # from failing due to permissions when launched as a less privileged user.
  end

  
  # Get this party started
  def run
    setup_application
    run_application
  end

  # Parse the configuration file
  def configure_meggy
    parse_options

    begin
      case config[:config_file]
      when /^(http|https):\/\//
        Meggy::REST.new("", nil, nil).fetch(config[:config_file]) { |f| apply_config(f.path) }
      else
      ::File::open(config[:config_file]) { |f| apply_config(f.path) }
      end
    rescue Errno::ENOENT => error
      Meggy::Log.warn("*****************************************")
      Meggy::Log.warn("Did not find config file: #{config[:config_file]}, using command line options.")
      Meggy::Log.warn("*****************************************")

      Meggy::Config.merge!(config)
    rescue Meggy::Exceptions::ConfigurationError => error
      Meggy::Application.fatal!("Error processing config file #{Meggy::Config[:config_file]} with error #{error.message}", 2)
    rescue Exception => error
      Meggy::Application.fatal!("Unknown error processing config file #{Meggy::Config[:config_file]} with error #{error.message}", 2)
    end

  end

  # Initialize and configure the logger.
  # === Loggers and Formatters
  # In Meggy 10.x and previous, the Logger was the primary/only way that Meggy
  # communicated information to the user. In Meggy 10.14, a new system, "output
  # formatters" was added, and in Meggy 11.0+ it is the default when running
  # meggy in a console (detected by `STDOUT.tty?`). Because output formatters
  # are more complex than the logger system and users have less experience with
  # them, the config option `force_logger` is provided to restore the Meggy 10.x
  # behavior.
  #
  # Conversely, for users who want formatter output even when meggy is running
  # unattended, the `force_formatter` option is provided.
  #
  # === Auto Log Level
  # When `log_level` is set to `:auto` (default), the log level will be `:warn`
  # when the primary output mode is an output formatter (see
  # +using_output_formatter?+) and `:info` otherwise.
  #
  # === Automatic STDOUT Logging
  # When `force_logger` is configured (e.g., Meggy 10 mode), a second logger
  # with output on STDOUT is added when running in a console (STDOUT is a tty)
  # and the configured log_location isn't STDOUT. This accounts for the case
  # that a user has configured a log_location in client.rb, but is running
  # meggy-client by hand to troubleshoot a problem.
  def configure_logging
    Meggy::Log.init(Meggy::Config[:log_location])
    if want_additional_logger?
      configure_stdout_logger
    end
    Meggy::Log.level = resolve_log_level
  end

  def configure_stdout_logger
    stdout_logger = Logger.new(STDOUT)
    STDOUT.sync = true
    stdout_logger.formatter = Meggy::Log.logger.formatter
    Meggy::Log.loggers <<  stdout_logger
  end

  # Based on config and whether or not STDOUT is a tty, should we setup a
  # secondary logger for stdout?
  def want_additional_logger?
    ( Meggy::Config[:log_location] != STDOUT ) && STDOUT.tty? && (!Meggy::Config[:daemonize]) && (Meggy::Config[:force_logger])
  end

  # Use of output formatters is assumed if `force_formatter` is set or if
  # `force_logger` is not set and STDOUT is to a console (tty)
  def using_output_formatter?
    Meggy::Config[:force_formatter] || (!Meggy::Config[:force_logger] && STDOUT.tty?)
  end

  def auto_log_level?
    Meggy::Config[:log_level] == :auto
  end

  # if log_level is `:auto`, convert it to :warn (when using output formatter)
  # or :info (no output formatter). See also +using_output_formatter?+
  def resolve_log_level
    if auto_log_level?
      if using_output_formatter?
        :warn
      else
        :info
      end
    else
      Meggy::Config[:log_level]
    end
  end

  # Called prior to starting the application, by the run method
  def setup_application
    raise Meggy::Exceptions::Application, "#{self.to_s}: you must override setup_application"
  end

  # Actually run the application
  def run_application
    raise Meggy::Exceptions::Application, "#{self.to_s}: you must override run_application"
  end

  
  private

  class << self
    def debug_stacktrace(e)
      message = "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
      meggy_stacktrace_out = "Generated at #{Time.now.to_s}\n"
      meggy_stacktrace_out += message

      Meggy::FileCache.store("meggy-stacktrace.out", meggy_stacktrace_out)
      Meggy::Log.fatal("Stacktrace dumped to #{Meggy::FileCache.load("meggy-stacktrace.out", false)}")
      Meggy::Log.debug(message)
      true
    end

    # Log a fatal error message to both STDERR and the Logger, exit the application
    def fatal!(msg, err = -1)
      Meggy::Log.fatal(msg)
      Process.exit err
    end

    def exit!(msg, err = -1)
      Meggy::Log.debug(msg)
      Process.exit err
    end
  end

end
