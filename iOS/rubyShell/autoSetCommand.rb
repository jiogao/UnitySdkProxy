#!/usr/bin/ruby

require File.expand_path('../XcodeAutoSet', __FILE__)
include XcodeAutoSet

p 'ARGV:'
ARGV.each do |parameter|
    puts parameter
end

projectPath = ARGV[0]    # 工程的全路径
channelName = ARGV[1]    #sdk名
product_bundle_identifier = ARGV[2]  #bundleId

puts 'projectPath: ' + projectPath
puts 'channelName: ' + channelName

srcArray = Array.[](
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/QKUnityBridge',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/SdkProxy',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/Utility',
	'QKSdkProxy'),
	CopyInfo.new('/Users/Megatron/Documents/work/UnitySdkProxy/iOS/QKSdkProxy/SdkProxy_channel/' + channelName,
	'QKSdkProxy/SdkProxy_channel'),
	)

frameworkArray = Array.[](
	"AdSupport",
	"AudioToolbox",
	"UIKit"
	)

systemTbdsArray = Array.[]("stdc++.6.0.9")

obj = AutoSet.new(projectPath, srcArray, frameworkArray, systemTbdsArray, product_bundle_identifier)
obj.start()
