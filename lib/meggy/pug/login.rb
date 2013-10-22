require 'meggy/pug'
#require 'meggy/core/text'

class Meggy
  class Pug
    class  Login < Meggy::Pug

      option :username,
    :short => "-u",
    :long => "--username",
    :description => "Enter username"

      option :password,
    :short => "-p",
    :long => "--password",
    :description => "Enter Password"

      banner "pug login (options)"
      def run
        unless name_args.empty?
          show_usage
          text.fatal("There are no subcommands.")
          exit 1
        end
        username            = config[:username] || ask_question("Enter Username: ", :default => "mugshot")
        password = config[:password] || text.ask("Enter Password: ") {|q| q.echo = false}
        text.msg "Username:" + username
        text.msg "Password:" + password
      end

    end
  end
end

