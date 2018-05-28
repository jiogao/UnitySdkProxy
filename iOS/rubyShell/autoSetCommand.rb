require File.expand_path('../XcodeAutoSet', __FILE__)

p 'ARGV:'
ARGV.each do |parameter|
    puts parameter
end

project_path = ARGV[0]    # 工程的全路径
sdk_name = ARGV[1]    #sdk名

# puts 'project_path: ' + project_path
# puts 'sdk_name: ' + sdk_name

obj = XcodeAutoSet.new(project_path, sdk_name)
obj.start()
