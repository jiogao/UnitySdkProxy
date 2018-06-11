# UnitySdkProxy iOS

功能: 一键添加指定文件到xcode工程，添加文件引用，并为. a和.framework自动设置force_load 等参数, 并打包导出ipa 到 xcode工程目录下的 build/export 文件夹中

依赖： ruby; cocoapods

<path>/autobuild.shell <xcodeProjectPath> <ExportOptionsPlistPath> <InfoExtraPlistPath>

exp:
./autobuild.shell ../../QKSdkProxy_ios/Unity-iPhone.xcodeproj ./ExportOptions.plist ./InfoExtra.plist

可选参数 -unbuild : 只添加文件,不编译打包

1.在ExportOptions.plist中设置:

    版本号(version).
    
    包号(buildVersion).
    
    app显示名称(bundleDisplayName).
    
    编译目标target(scheme).
    
    打包方法/method(configuration) # 可选类型: app-store, ad-hoc, enterprise, development.
    
    证书类型(CODE_SIGN_IDENTITY) # 发布: iPhone Distribution, 开发: iPhone Developer.
    
    开发者ID(DEVELOPMENT_TEAM) # 登录开发者账号查看,也可以在相应的Provisioning Profile签名文件的信息中找到.
    
    包名(PRODUCT_BUNDLE_IDENTIFIER) #如 com.yourcompany.appname.
    
    签名标识(PROVISIONING_PROFILE_SPECIFIER) #在 Provisioning Profile 的文件信息中可以看到,如 com.yourcompany.appname.dev.
    
    签名文件UUID(PROVISIONING_PROFILE) #可选,如果不填可能会使用当前签名标识中最新的签名文件, 在 Provisioning Profile 的文件信息中可以看到,如 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
    
    需要拷贝的文件路径列表(srcArray).
    
    需要添加的系统framework名列表(frameworkArray).
    
    需要添加的系统库tdb名列表(systemTbdsArray).
    
2.支持在InfoExtra.plist中添加额外的Info.plist条目

3.
