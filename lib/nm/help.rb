class Help
 def list
puts "Megam Usage"
puts "ruby mycli.rb sub-command (options)"
		puts "\nSUB-COMMANDS : "
		puts "login [options]		Login"
		puts "identity_create [options]	Create Identity"
		puts "\n"

		puts "\nOPTIONS : "
		puts "--username 	UserName"
		puts "--password 	Password"
		puts "--identity_name	Name of the Identity"
		puts "\n"

 end
end