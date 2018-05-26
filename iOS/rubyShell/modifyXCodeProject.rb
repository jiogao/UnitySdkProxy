#require 'xcodeproj'
#require 'set'
require 'cocoapods'
require File.expand_path('../tools', __FILE__)

ARGV.each do |parameter|
    puts parameter
end

project_path = ARGV[0]    # 工程的全路径
sdk_name = ARGV[1]    #sdk名

# puts 'project_path: ' + project_path
# puts 'sdk_name: ' + sdk_name

obj = ProjectControl.new(project_path, sdk_name)
obj.start()
