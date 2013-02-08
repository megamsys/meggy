class Meggy
  ## expands the current directory of where the nm file executes and figures out the expanded 
  ## directory
  MEGGY_ROOT = File.dirname(File.expand_path(File.dirname(__FILE__)))
  VERSION = '0.1'
end