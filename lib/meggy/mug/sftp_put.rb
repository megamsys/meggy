require 'net/sftp'

def run(args)
  Net::SFTP.start('host', 'username', :password => 'password') do |sftp|
    # upload a file or directory to the remote host
    sftp.upload!("/path/to/local", "/path/to/remote")


    # open and write to a pseudo-IO for a remote file
    sftp.file.open("/path/to/remote", "w") do |f|
      f.puts "Hello, world!\n"
    end

    # create a directory
    sftp.mkdir! "/path/to/directory"

    # list the entries in a directory
    sftp.dir.foreach("/path/to/directory") do |entry|
      puts entry.longname
    end
  end
end
