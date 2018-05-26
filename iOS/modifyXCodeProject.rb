#require 'xcodeproj'
#require 'set'
require 'cocoapods'

ARGV.each do |parameter|
    puts parameter
end

project_path = ARGV[0]    # 工程的全路径
sdk_name = ARGV[1]    #sdk名
project = Xcodeproj::Project.open(project_path)

# 1、显示所有的target
project.targets.each do |target|
  puts target.name
end

# 增加新的文件到工程中
target = project.targets.first

#project.main_group.delete
group = project.main_group.find_subpath(File.join('testXcodeproj','newGroup'), true)
group.set_source_tree('SOURCE_ROOT')

#设置 'Other Linker Flags'
puts 'configurations'
configurations = target.build_configurations
configurations.each do |configuration|
    puts 'configuration ======== '
    puts configuration
#    configuration.build_settings.each do |setting|
#        puts setting
#    end

#   'Other Linker Flags'
    other_Linker_Flags = configuration.build_settings['OTHER_LDFLAGS']
#    puts other_Linker_Flags
    other_Linker_Flags.each do |flags|
        puts flags
    end
    other_Linker_Flags.push('-force_load',
                            '"$(PROJECT_DIR)/ExtraLibs/SDK/libkaixinwanSDKa.a"')
end



#
## 获取全部的文件引用
#file_ref_list = target.source_build_phase.files_references
#
## 设置文件引用是否存在标识
#file_ref_mark = false
#
## 检测需要添加的文件是否存在
#for file_ref_temp in file_ref_list
#    puts file_ref_temp.path.to_s
#    if file_ref_temp.path.to_s.end_with?('ViewController1.m') then
#        file_ref_mark = true
#    end
#end
#
#if !file_ref_mark then
#    file_ref = group.new_reference('ViewController1.h文件路径')
#    target.add_file_references([file_ref])
#    else
#    puts '文件引用已存在'
#end
#
#if !file_ref_mark then
#    file_ref = group.new_reference('ViewController1.m文件路径')
#    target.add_file_references([file_ref])
#    else
#    puts '文件引用已存在'
#end
project.save
#puts '文件添加完成'
