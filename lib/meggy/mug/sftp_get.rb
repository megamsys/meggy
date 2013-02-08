require 'net/sftp'
#http://net-ssh.rubyforge.org/sftp/v2/api/

def run(args)
  Net::SFTP.start('host', 'username', :password => 'password') do |sftp|

    # download a file or directory from the remote host
    sftp.download!("/path/to/remote", "/path/to/local")

    # grab data off the remote host directly to a buffer
    data = sftp.download!("/path/to/remote")

    # open and read from a pseudo-IO for a remote file
    sftp.file.open("/path/to/remote", "r") do |f|
      puts f.gets
    end

    # create a directory
    sftp.mkdir! "/path/to/directory"

    # list the entries in a directory
    sftp.dir.foreach("/path/to/directory") do |entry|
      puts entry.longname
    end
  end
  end
