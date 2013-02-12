require 'meggy/pug'

class Meggy
  class Pug
    class IdentityCreate < Pug
      #attr_accessor :name_args
    deps do
      #We'll include our API client as the dependency.
      #
    end


      banner "pug identity create ACCOUNT(options)"
      
      def run

        @account_name = @name_args[0]

        if @account_name.nil?
          show_usage
          text.fatal("You must specify an account name")
          #exit 1
        end
        puts name_args[0]
      end

    end
  end
end
