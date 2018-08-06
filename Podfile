# Uncomment this line to define a global platform for your project
# Platform must be `:ios`, `:osx`, `:tvos`, or `:watchos`
#platform :ios, '8.0'
platform :osx, '10.10'
# Uncomment this line if you're using Swift
use_frameworks!

inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

def normal
    #pod 'MBProgressHUD', '~> 1.1.0'
    #pod 'AFNetworking', '~> 3.0'
    #pod 'Reachability', '~> 3.2'
    #pod 'JLExtension','~> 0.1.6'
    pod 'Alamofire', '~> 4.7'
end

def mqtt
	pod 'MQTTClient'
    #pod 'CocoaMQTT'
end

def socket
    #pod 'CocoaAsyncSocket'
end

def protobuf
    #pod 'Protobuf', '~> 3.5.0'
end

def other
    #pod 'Popover.OC' # 菜单弹窗
    #pod 'MJRefresh'
    #pod 'SDWebImage', '~> 4.0'
    #pod 'BmobSDK' # 后端云SDK
end

target 'JLMQTTnet' do
	normal
	mqtt
    socket
    protobuf
    other
end
