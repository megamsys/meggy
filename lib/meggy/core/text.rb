#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'rubygems'

class Meggy
  class Text

    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdin
    attr_reader :config
    
    def initialize(stdout, stderr, stdin, config)
      @stdout, @stderr, @stdin, @config = stdout, stderr, stdin, config
    end

    def highline
      @highline ||= begin
      require 'highline'
      HighLine.new
      end
    end

    # Prints a message to stdout. Aliased as +info+ for compatibility with
    # the logger API.

    def msg(message)
      stdout.puts message
    end

    alias :info :msg

    # Prints a msg to stderr. Used for warn, error, and fatal.
    def err(message)
      stderr.puts message
    end

    # Print a warning message
    def warn(message)
      err("#{color('WARNING:', :yellow, :bold)} #{message}")
    end

    # Print an error message
    def error(message)
      err("#{color('ERROR:', :red, :bold)} #{message}")
    end

    # Print a message describing a fatal error.
    def fatal(message)
      err("#{color('FATAL:', :red, :bold)} #{message}")
    end

    def color(string, *colors)
      if color?
        highline.color(string, *colors)
      else
      string
      end
    end

    # Should colored output be used? For output to a terminal, this is
    # determined by the value of `config[:color]`. When output is not to a
    # terminal, colored output is never used
    def color?
      ##Chef::Config[:color] && stdout.tty? && !Chef::Platform.windows?
      :red
    end

    def ask(*args, &block)
      highline.ask(*args, &block)
    end

    def list(*args)
      highline.list(*args)
    end

    # Formats +data+ using the configured presenter and outputs the result
    # via +msg+. Formatting can be customized by configuring a different
    # presenter. See +use_presenter+
    def output(data)
      msg @presenter.format(data)
    end

    def ask_question(question, opts={})
      question = question + "[#{opts[:default]}] " if opts[:default]

      if opts[:default] and config[:defaults]
        opts[:default]
      else
        stdout.print question
        a = stdin.readline.strip

        if opts[:default]
          a.empty? ? opts[:default] : a
        else
        a
        end
      end
    end

    def pretty_print(data)
      stdout.puts data
    end
  end
end
