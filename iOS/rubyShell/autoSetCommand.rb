#!/usr/bin/ruby

require File.expand_path('../XcodeAutoSet', __FILE__)
include XcodeAutoSet

p 'ARGV:'

projectPath = ARGV[0]    # 工程的全路径
productBundleIdentifier = ARGV[1]  #bundleId

srcArray = nil
frameworkArray = nil
systemTbdsArray = nil
embedFrameworkArray = nil

index = 0
ARGV.each do |parameter|
    puts parameter
    if parameter == "-srcArray" and ARGV[index+1] != nil
    	srcArray = ARGV[index+1].split(';')
    end
    if parameter == "-frameworkArray" and ARGV[index+1] != nil
    	frameworkArray = ARGV[index+1].split
    end
    if parameter == "-systemTbdsArray" and ARGV[index+1] != nil
    	systemTbdsArray = ARGV[index+1].split
    end
    if parameter == "-embedFrameworkArray" and ARGV[index+1] != nil
        embedFrameworkArray = ARGV[index+1].split
    end 
    index += 1
end


puts 'projectPath: ' + projectPath
p srcArray
p frameworkArray
p systemTbdsArray
p embedFrameworkArray

obj = AutoSet.new(projectPath, productBundleIdentifier, srcArray, frameworkArray, systemTbdsArray, embedFrameworkArray)
obj.start()
