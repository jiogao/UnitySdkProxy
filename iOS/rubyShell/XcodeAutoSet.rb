#xcodeproj文档: https://www.rubydoc.info/gems/xcodeproj/Xcodeproj

#require 'xcodeproj'
#require 'set'
require 'cocoapods'
require "fileutils"
require 'find'

class XcodeAutoSet

    def initialize(path, sdkn)
        @project_path = path
        @sdk_name = sdkn

        @root_dir = File.dirname(@project_path)
        puts 'root_dir: ' + @root_dir
    end

    def start()
        @project = Xcodeproj::Project.open(@project_path)

        # # 1、显示所有的target
        # project.targets.each do |target|
        #   puts target.name
        # end

        sdk_path = copySdkFiles()
        sdk_proxy_path = copySdkProxyFiles()

        #工程设置
        target = @project.targets.first

        xcode_group_readd(target, sdk_path)
        xcode_group_readd(target, sdk_proxy_path)

        xcode_set_build_settings(target)
        xcode_add_frameworks(target)

        @project.save
        puts '文件添加完成'
    end

    #拷贝sdk相关文件
    def copySdkFiles()
        src_path = 'SdkLibs'
        src_path = File::expand_path(src_path, @root_dir)
        org_src_path = File.expand_path('../../../../SdkLibs', __FILE__)
        puts 'copySdkFiles: ' + src_path
        if File.exist?(src_path) then
            FileUtils.rm_rf(src_path)
        end
        FileUtils.mkdir_p(src_path)

        target_sdk_path = File::expand_path(@sdk_name, src_path)
        org_sdk_path = File.expand_path(@sdk_name, org_src_path)
        FileUtils.cp_r(org_sdk_path, target_sdk_path)

        return src_path
    end

    #拷贝sdk接入代码
    def copySdkProxyFiles()
        src_path = 'QKSdkProxy'
        src_path = File::expand_path(src_path, @root_dir)
        org_src_path = File.expand_path('../../QKSdkProxy', __FILE__)
        puts 'copySdkProxyFiles: ' + org_src_path
        if File.exist?(src_path) then
            FileUtils.rm_rf(src_path)
        end
        FileUtils.mkdir_p(src_path, )


        channel_dir = File.expand_path('SdkProxy_channel', src_path)
        org_channel_dir = File.expand_path('SdkProxy_channel', org_src_path)
        target_sdk_path = File::expand_path(@sdk_name, channel_dir)
        org_sdk_path = File.expand_path(@sdk_name, org_channel_dir)
        # p target_sdk_path
        # p org_sdk_path
        FileUtils.mkdir_p(channel_dir)
        FileUtils.cp_r(org_sdk_path, target_sdk_path)

        Dir.foreach(org_src_path) do |subItem|
            if !subItem.start_with?('.') and subItem !="." and subItem !=".." and subItem != 'SdkProxy_channel'
                target_sdk_path = File::expand_path(subItem, src_path)
                org_sdk_path = File.expand_path(subItem, org_src_path)
                FileUtils.cp_r(org_sdk_path, target_sdk_path)
            end
        end

        return src_path
    end

    #工程设置中重新添加一个文件夹
    def xcode_group_readd(target, path)
        p 'xcode_group_readd: ' + path
        main_group = @project.main_group
        basename = File::basename(path)
        group = main_group.find_subpath(basename, false)
        if group != nil then
            xcode_group_clear(group)
        else
            group = main_group.new_group(basename, basename)
        end

        # group.set_source_tree('SOURCE_ROOT')

        xcode_group_add_all_children(target, path, group)
    end

    #工程设置中删除文件夹中的引用
    def xcode_group_clear(group)
        for file_ref_temp in group.recursive_children
            # p file_ref_temp
            if file_ref_temp.is_a? Xcodeproj::Project::Object::PBXGroup then
                # xcode_group_clear_recursive(file_ref_temp)
            elsif file_ref_temp.is_a? Xcodeproj::Project::Object::PBXFileReference then
                file_ref_temp.remove_from_project
                # p 'delete reference ' + file_ref_temp.path
            end
        end
        group.clear
    end

    #为文件夹中的所有文件添加引用
    def xcode_group_add_all_children(target, path, group)
        Dir.foreach(path) do |subItem|
            if !subItem.start_with?('.') and subItem !="." and subItem !=".." then
                fullSubItem = File.expand_path(subItem, path)
                if File.directory? fullSubItem and !subItem.end_with?('.bundle')
                    sub_group = group.new_group(subItem, subItem)
                    xcode_group_add_all_children(target, fullSubItem, sub_group)
                else
                    file_ref = group.new_reference(subItem)
                    # p 'add reference ' + file_ref.path
                    if !subItem.end_with?('.h')
                        target.add_file_references([file_ref])
                        #为所有.a和.framework 设置 force_load
                        if subItem.end_with?('.a') or subItem.end_with?('.framework')
                            relatively_path = fullSubItem[@root_dir.length, fullSubItem.length - @root_dir.length]
                            xcode_set_build_libfiles_settings(target, relatively_path)
                        end
                    end
                end
            end
        end
    end

    #Other Linker Flags 设置
    def xcode_set_build_libfiles_settings(target, relatively_path)
        configurations = target.build_configurations
        configurations.each do |configuration|
            # puts configuration
            #Other Linker Flags
            other_Linker_Flags = configuration.build_settings['OTHER_LDFLAGS']
            flag_str = '$(PROJECT_DIR)' + relatively_path
            if relatively_path.end_with?('.framework')
               fileName = File::basename(relatively_path, '.framework')
               flag_str = flag_str + '/' + fileName
            end
            flag_str = '"' + flag_str + '"'#加双引号避免路径包含特殊字符导致错误

            # p configuration.name + ' => Other Linker Flags: ' + flag_str
            isAdded = false
            other_Linker_Flags.each do |item|
                if item == flag_str
                    isAdded = true
                end
            end
            if !isAdded
                other_Linker_Flags.push('-force_load', flag_str)
            end

            library_search_paths = configuration.build_settings['LIBRARY_SEARCH_PATHS']
            
            dir_path = File.dirname(relatively_path)
            #$(PROJECT_DIR) #$(SRCROOT)
            str = '"$(PROJECT_DIR)' + dir_path + '"'
            add_unique_items(library_search_paths, str)
        end
    end

    #编译设置
    def xcode_set_build_settings(target)
        configurations = target.build_configurations
        configurations.each do |configuration|
            # puts configuration
            # configuration.build_settings.each do |setting|
            #    puts setting
            # end

            #Enable Bitcode
            configuration.build_settings['ENABLE_BITCODE'] = 'NO'

            #$(SRCROOT) 和 $(SRCROOT)/Libraries 带有双引号会导致找不到库文件， 原因不明
            library_search_paths = configuration.build_settings['LIBRARY_SEARCH_PATHS']
            add_unique_items(library_search_paths, '$(SRCROOT)')
            add_unique_items(library_search_paths, '$(SRCROOT)/Libraries')
            # $(PROJECT_DIR)/SdkLibs/okwan
        end
    end

    #添加不重复项
    def add_unique_items(array, str)
        isAdded = false
        array.each do |item|
            if item == str
                isAdded = true
            end
        end
        if !isAdded
            array.push(str)
        end
    end

    #引用库
    def xcode_add_frameworks(target)
        # main_group = @project.main_group
        # group = main_group.find_subpath('Frameworks', true)
        # p group.source_tree

        frameworks_build_phases = target.frameworks_build_phases
        # p 'frameworks_build_phases'
        # p frameworks_build_phases.files
        # p frameworks_build_phases.files_references 
        # frameworks_build_phases.add_file_reference()

        framework_list = ["AdSupport", "AudioToolbox", "UIKit"]
        for lib_name in framework_list
            lib_name_with_suffix = lib_name + '.framework'
            isAdded = false
            for ref in frameworks_build_phases.files_references
                if ref != nil and lib_name_with_suffix == ref.name
                    isAdded = true
                end
            end
            if !isAdded
                puts 'add + ' + lib_name
                list = target.add_system_framework(lib_name)
                # for ref in list
                #     p ref,ref.path,ref.source_tree
                #     # ref.set_source_tree('SOURCE_ROOT')
                # end
            end
            # for ref in frameworks_build_phases.files_references
            #     p ref,ref.path,ref.source_tree
            # end
        end

        target.add_system_library("stdc++")
    end

end
