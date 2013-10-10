require 'meggy/pug'

class Meggy
  class Pug
    class BookList < Pug


      option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true

      banner "pug book list (options)"
        
      def run
        puts "Identity Listed"
      end

    end
  end
end

