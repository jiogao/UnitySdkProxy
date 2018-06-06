#!/usr/bin/ruby

require File.expand_path('../XcodeAutoSet', __FILE__)
include XcodeAutoSet

p 'ARGV:'
ARGV.each do |parameter|
    puts parameter
end

projectPath = ARGV[0]    # 工程的全路径
sdkName = ARGV[1]    #sdk名

puts 'projectPath: ' + projectPath
puts 'sdkName: ' + sdkName

srcArray = Array.[](
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/QKUnityBridge',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/SdkProxy',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/Utility',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/SdkProxy_channel/' + sdkName,
	'QKSdkProxy/SdkProxy_channel'),
	)

frameworkArray = Array.[](
	"AdSupport",
	"AudioToolbox",
	"UIKit"
	)

systemTbdsArray = Array.[]("stdc++.6.0.9")

obj = AutoSet.new(projectPath, srcArray, frameworkArray, systemTbdsArray)
obj.start()
