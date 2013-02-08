server_url "www.gmail.com"
username "thomasalrin"
password "password"


def load!
  self.parse_options
  unless self.config[:domain] && self.config[:room] && (self.config[:username] || self.config[:api_key])
    raise "Missing parameters - please run 'nm --help' for help" 
  end
end
