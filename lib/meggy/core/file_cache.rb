require 'fileutils'

class Meggy::FileCache
  def store
    file_path_array = File.split(path)
    file_name = file_path_array.pop
    cache_path = create_cache_path(File.join(file_path_array))
    File.open(File.join(cache_path, file_name), "w", perm) do |io|
      io.print(contents)
    end
  end
end