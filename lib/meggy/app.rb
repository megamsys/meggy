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

#this is important to have meggy/config, or else
#ruby tries to load the deprecated Config class from ruby lib.
require 'meggy/config'
require 'meggy/core/exceptions'
require 'megam/core/log'
require 'mixlib/cli'
require 'tmpdir'
require 'rbconfig'

class Meggy::App
  include Mixlib::CLI
  def initialize
    super # The super calls the mixlib cli.

    #We'll probably have a JSONclient to formulate a json, and send it out.
    #Let it for now.
    @meggy_client_json = nil

    ##Traps are being set for the following when an application starts.
    ##SIGHUP        1       Term    Hangup detected on controlling terminal
    ##                             or death of controlling process
    ##SIGINT        2       Term    Interrupt from keyboard
    ##SIGQUIT       3       Core    Quit from keyboard
    trap("TERM") do
      Meggy::App.fatal!("SIGTERM received, stopping", 1)
    end

    trap("INT") do
      Meggy::App.fatal!("SIGINT received, stopping", 2)
    end

    trap("QUIT") do
      Meggy::Log.info("SIGQUIT received, call stack:\n  " + caller.join("\n  "))
    end

  end

  ##A few private helper methods being used by the subclasses of app and by app itself.
  ##If you run an application for ever, you might pool all the executions and gather the stacktrace.
  ##There are no long running application currently.
  ##Rightnow the fatal method is used by app internally above.
  private

  class << self
    #The exception in ruby carries the class, message and the trace.
    #http://www.ruby-doc.org/core-1.9.3/Exception.html
    def debug_stacktrace(e)
      message = "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
      meggy_stacktrace_out = "Generated at #{Time.now.to_s}\n"
      meggy_stacktrace_out += message

      #after the message is formulated in the variable meggy_stack_trace_out, its
      #stored in a file named meggy-stacktrace.out
      Meggy::FileCache.store("meggy-stacktrace.out", meggy_stacktrace_out)

      ##The same error is logged in the log file saying, go look at meggy-stacktrace.out for error.
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
