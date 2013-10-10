require 'meggy/pug'

class Meggy
  class Pug
    class AccountList < Pug


      option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true

      banner "pug account list (options)"
        
      def run
        puts "Accounts Listed"
      end

    end
  end
end

