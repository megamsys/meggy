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

require 'meggy/core/log'
require 'mixlib/config'

class Meggy
  class Config
    extend(Mixlib::Config)
    def self.inspect
      configuration.inspect
    end

    def self.add_formatter(name, file_path=nil)
      formatters << [name, file_path]
    end

    def self.formatters
      @formatters ||= []
    end

    # The number of times the client should retry when registering with the server
    client_registration_retries 5

    # Valid log_levels are:
    # * :debug
    # * :info
    # * :warn
    # * :fatal
    # These work as you'd expect. There is also a special `:auto` setting.
    # When set to :auto, Meggy will auto adjust the log verbosity based on
    # context. When a tty is available (usually becase the user is running meggy
    # in a console), the log level is set to :warn, and output formatters are
    # used as the primary mode of output. When a tty is not available, the
    # logger is the primary mode of output, and the log level is set to :info
    log_level :auto

    http_retry_count 5
    http_retry_delay 5
    interval nil
    json_attribs nil
    log_location STDOUT
    # toggle info level log items that can create a lot of output
    verbose_logging true
    node_name nil

    pid_file nil

    meggy_server_url   "http://localhost:4000"
    registration_url  "http://localhost:4000"

    rest_timeout 300
    run_command_stderr_timeout 120
    run_command_stdout_timeout 120

    # Set these to enable SSL authentication / mutual-authentication
    # with the server
    ssl_client_cert nil
    ssl_client_key nil
    ssl_verify_mode :verify_none
    ssl_ca_path nil
    ssl_ca_file nil

    # Sets the version of the signed header authentication protocol to use (see
    # the 'mixlib-authorization' project for more detail). Currently, versions
    # 1.0 and 1.1 are available; however, the meggy-server must first be
    # upgraded to support version 1.1 before clients can begin using it.
    #
    # Version 1.1 of the protocol is required when using a `node_name` greater
    # than ~90 bytes (~90 ascii characters), so meggy-client will automatically
    # switch to using version 1.1 when `node_name` is too large for the 1.0
    # protocol. If you intend to use large node names, ensure that your server
    # supports version 1.1. Automatic detection of large node names means that
    # users will generally not need to manually configure this.
    #
    # In the future, this configuration option may be replaced with an
    # automatic negotiation scheme.
    authentication_protocol_version "1.0"

    # This key will be used to sign requests to the Meggy server. This location
    # must be writable by Meggy during initial setup when generating a client
    # identity on the server.
    #
    # The meggy-server will look up the public key for the client using the
    # `node_name` of the client.
    client_key platform_specific_path("/etc/meggy/client.pem")

    # If there is no file in the location given by `client_key`, meggy-client
    # will temporarily use the "validator" identity to generate one. If the
    # `client_key` is not present and the `validation_key` is also not present,
    # meggy-client will not be able to authenticate to the server.
    #
    # The `validation_key` is never used if the `client_key` exists.
    validation_key platform_specific_path("/etc/meggy/validation.pem")
    validation_client_name "meggy-validator"

    # Server Signing CA
    #
    # In truth, these don't even have to change
    signing_ca_cert "/var/meggy/ca/cert.pem"
    signing_ca_key "/var/meggy/ca/key.pem"
    signing_ca_user nil
    signing_ca_group nil
    signing_ca_country "US"
    signing_ca_state "Washington"
    signing_ca_location "Seattle"
    signing_ca_org "Meggy User"
    signing_ca_domain "opensource.opscode.com"
    signing_ca_email "opensource-cert@opscode.com"

    # Arbitrary pug configuration data
    pug Hash.new

  end
end
