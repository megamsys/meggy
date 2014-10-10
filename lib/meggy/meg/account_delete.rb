require 'meggy/meg'
require 'megam/core/server_api'

class Meggy
  class Meg
    class AccountDelete < Meg

      banner "meg account delete (options)"
      def run
        if name_args.length < 1
          show_usage
          text.fatal("You must supply an email to delete")
          exit 42
        end

        text.msg("The following email will be deleted:")
        text.msg("")
        text.msg(text.list(identities_to_delete.keys.sort, :columns_down))
        text.msg("")
        text.confirm("Are you sure you want to delete this email ?")

      end

    end
  end
end
