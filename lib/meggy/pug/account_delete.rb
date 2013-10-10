require 'meggy/pug'

class Meggy
  class Pug
    class AccountDelete < Pug

      banner "pug account delete (options)"
      def run
        puts "Action : IdentityDelete entry"
        if name_args.length < 1
          show_usage
          text.fatal("You must supply a regular expression to match the results against")
          exit 42
        end

        #     all_identities = Meggy::ApiClient.list

        #     matcher = /#{name_args[0]}/
        #     identities_to_delete = {}
        #     all_identities.each do |name, identity|
        #       next unless name =~ matcher
        #       identities_to_delete[identity.name] = identity
        #     end

        #     if identities_to_delete.empty?
        #       ui.info "No identities match the expression /#{name_args[0]}/"
        #       exit 0
        #     end

        text.msg("The following identities will be deleted:")
        text.msg("")
        text.msg(text.list(identities_to_delete.keys.sort, :columns_down))
        text.msg("")
        text.confirm("Are you sure you want to delete these identities")

        identities_to_delete.sort.each do |name, identity|
          identity.destroy
          text.msg("Deleted identity #{name}")
        end
      end

    end
  end
end

