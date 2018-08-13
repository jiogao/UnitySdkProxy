#!/usr/bin/ruby

# xcodeproj文档: https://www.rubydoc.info/gems/xcodeproj/Xcodeproj
# https://github.com/CocoaPods/Xcodeproj

# require 'xcodeproj'
# require 'set'
require 'cocoapods'
require "fileutils"
require 'find'

#https://github.com/typedef/Xcodeproj/commit/925280230c8d591d9b3e02ed9d1b0438b8d1e413
#  add tbd type 
#
#
module XcodeAutoSet
    #注意：版本更新之后路径可能会有变化，如果系统库引用失败可以手动引用之后参考应用路径改写此处路径

    def add_system_tbds(project, target, names)
        Array(names).each do |name|
            #path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib/#{name}.tbd"
            path = "usr/lib/lib#{name}.tbd"
            files = project.frameworks_group.files
            unless reference = files.find { |ref| ref.path == path }
                reference = project.frameworks_group.new_file(path, :sdk_root)
            end
            target.frameworks_build_phase.add_file_reference(reference, true)
            reference
        end
    end
    # alias_method :add_system_tbds, :add_system_tbd

    #直接使用add_system_framework路径不对, target.add_system_framework(lib_name)
    def add_system_framework(project, target, names)
        Array(names).each do |name|
            path = "System/Library/Frameworks/#{name}.framework"
            files = project.frameworks_group.files
            unless reference = files.find { |ref| ref.path == path }
                reference = project.frameworks_group.new_file(path, :sdk_root)
            end
            target.frameworks_build_phase.add_file_reference(reference, true)
            reference
        end
    end

    class AutoSet

        def initialize(projectPath, productBundleIdentifier, copyArray, frameworkArray, systemTbdsArray, embedFrameworkArray = nil)
            @projectPath = projectPath
            @productBundleIdentifier = productBundleIdentifier
            @copyArray = copyArray
            @frameworkArray = frameworkArray
            @systemTbdsArray = systemTbdsArray
            @embedFrameworkArray = embedFrameworkArray

            @rootDir = File.dirname(@projectPath)
            puts 'rootDir: ' + @rootDir
        end

        def start()
            @project = Xcodeproj::Project.open(@projectPath)
            #统一放在固定文件夹
            dstRootDir = 'XcodeAutoSet'

            # # 1、显示所有的target
            # project.targets.each do |target|
            #   puts target.name
            # end
            target = @project.targets.first

            #删除旧文件
            fullDstRootDir = File::expand_path(dstRootDir, @rootDir)

            if File.exist?(fullDstRootDir) then
                FileUtils.rm_rf(fullDstRootDir)
            end

            if @copyArray != nil
                for copyPath in @copyArray
                    copyFiles(copyPath, fullDstRootDir)
                end
            end

            xcode_group_readd(target, fullDstRootDir)

            #工程设置

            xcode_set_build_settings(target)
            xcode_add_frameworks(target)

            @project.save
            puts '文件添加完成'
        end

        def copyFiles(srcPath, dstPath)
            FileUtils.mkdir_p(dstPath)
            FileUtils.cp_r(srcPath, dstPath)
        end

        #工程设置中重新添加一个文件夹
        def xcode_group_readd(target, path)
            p 'xcode_group_readd: ' + path
            main_group = @project.main_group
            basename = File::basename(path)
            group = main_group.find_subpath(basename, false)
            if group != nil then
                xcode_group_clear(target, group)
            else
                group = main_group.new_group(basename, basename)
            end

            # group.set_source_tree('SOURCE_ROOT')

            xcode_group_add_all_children(target, path, group)
        end

        #工程设置中删除文件夹中的引用
        def xcode_group_clear(target, group)

            # Embed Frameworks 列表
            embed_frameworks_phases = get_embed_frameworks_phases(target)

            for file_ref_temp in group.recursive_children
                # p file_ref_temp
                if file_ref_temp.is_a? Xcodeproj::Project::Object::PBXGroup then
                    # xcode_group_clear_recursive(file_ref_temp)
                    # p file_ref_temp
                elsif file_ref_temp.is_a? Xcodeproj::Project::Object::PBXFileReference then
                    if file_ref_temp.path.end_with?('.m') or file_ref_temp.path.end_with?('.mm') \
                        or file_ref_temp.path.end_with?('.c') or file_ref_temp.path.end_with?('.cpp')
                        # 编译文件列表
                        target.source_build_phase.remove_file_reference(file_ref_temp)
                    elsif file_ref_temp.path.end_with?('.a') or file_ref_temp.path.end_with?('.framework')
                        # 库文件列表
                        target.frameworks_build_phases.remove_file_reference(file_ref_temp)
                        if embed_frameworks_phases != nil
                            embed_frameworks_phases.remove_file_reference(file_ref_temp)
                        end
                    else
                        # 资源文件列表
                        target.resources_build_phase.remove_file_reference(file_ref_temp)
                    end
                    file_ref_temp.remove_from_project
                    # p 'delete reference ' + file_ref_temp.path
                end
            end
            group.clear
        end

        #为文件夹中的所有文件添加引用
        def xcode_group_add_all_children(target, path, group)

            # Embed Frameworks 列表
            embed_frameworks_phases = get_embed_frameworks_phases(target)

            Dir.foreach(path) do |subItem|
                if !subItem.start_with?('.') and subItem !="." and subItem !=".." then
                    fullSubItem = File.expand_path(subItem, path)
                    # .bundle 和 .framework 是文件夹
                    if File.directory? fullSubItem and !subItem.end_with?('.bundle') and !subItem.end_with?('.framework')
                        sub_group = group.new_group(subItem, subItem)
                        xcode_group_add_all_children(target, fullSubItem, sub_group)
                    else
                        file_ref = group.new_reference(subItem)
                        # p 'add reference ' + file_ref.path
                        if !subItem.end_with?('.h')
                            if subItem.end_with?('.m') or subItem.end_with?('.mm') \
                                or subItem.end_with?('.c') or subItem.end_with?('.cpp')
                                # 编译文件列表
                                # target.add_file_references([file_ref])
                                target.source_build_phase.add_file_reference(file_ref)
                            elsif subItem.end_with?('.a') or subItem.end_with?('.framework')
                                # 库文件列表
                                # 动态 framework 需要添加到 Embed Frameworks
                                if @embedFrameworkArray!= nil
                                    isNeedEmbed = false
                                    for item in @embedFrameworkArray
                                        if subItem.end_with?(item)
                                            isNeedEmbed = true
                                            break
                                        end
                                    end
                                    if isNeedEmbed
                                        puts '库文件列表', file_ref.path
                                        build_file = embed_frameworks_phases.add_file_reference(file_ref)
                                        if build_file != nil
                                            settings = build_file.settings
                                            if settings == nil
                                                build_file.settings = Hash.new
                                                settings = build_file.settings
                                            end
                                            settings['ATTRIBUTES'] = ['CodeSignOnCopy', 'RemoveHeadersOnCopy', ]
                                        end
                                    end
                                end

                                target.frameworks_build_phases.add_file_reference(file_ref)

                                # 为所有.a和.framework 设置 force_load
                                relatively_path = fullSubItem[@rootDir.length, fullSubItem.length - @rootDir.length]
                                xcode_set_build_libfiles_settings(target, relatively_path)
                            else
                                # 资源文件列表
                                # target.add_resources([file_ref])
                                target.resources_build_phase.add_file_reference(file_ref)
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
                search_paths_settings = nil
                if relatively_path.end_with?('.framework')
                    fileName = File::basename(relatively_path, '.framework')
                    flag_str = flag_str + '/' + fileName
                    search_paths_settings = reset_setting_to_array(configuration.build_settings, 'FRAMEWORK_SEARCH_PATHS')
                else
                    search_paths_settings = reset_setting_to_array(configuration.build_settings, 'LIBRARY_SEARCH_PATHS')
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

                dir_path = File.dirname(relatively_path)
                str = '$(PROJECT_DIR)' + dir_path
                add_unique_items(search_paths_settings, str)
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
                configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = @productBundleIdentifier

                #$(SRCROOT) 和 $(SRCROOT)/Libraries 带有双引号会导致找不到库文件， 原因不明
                library_search_paths = reset_setting_to_array(configuration.build_settings, 'LIBRARY_SEARCH_PATHS')

                add_unique_items(library_search_paths, '$(SRCROOT)')
                add_unique_items(library_search_paths, '$(SRCROOT)/Libraries')
                # $(PROJECT_DIR)/SdkLibs/okwan
            end
        end

        #把configuration中的指定条目扩展为array, 再添加不重复项
        def reset_setting_to_array(build_settings, key)
            setting = build_settings[key]
            if setting == nil or setting.is_a? String
                build_settings[key] = Array.new
                if setting.is_a? String
                    build_settings[key].push(setting)
                end
                setting = build_settings[key]
            end
            return setting
        end

        # 获取或新建 Embed Frameworks 列表
        def get_embed_frameworks_phases(target)
            embed_frameworks_phases = nil
            puts target.copy_files_build_phases[0].class
            for item in target.copy_files_build_phases
                if 'Embed Frameworks' == item.name
                    embed_frameworks_phases = item
                end
            end
            if embed_frameworks_phases == nil
                embed_frameworks_phases = target.new_copy_files_build_phase('Embed Frameworks')
                puts 'get_embed_frameworks_phasesget_embed_frameworks_phasesget_embed_frameworks_phasesget_embed_frameworks_phases'
                puts embed_frameworks_phases.dst_subfolder_spec.class
                embed_frameworks_phases.dst_subfolder_spec = '10' #意义未知, 根据手动添加引用时的工程文件设置, 默认为7会报错
            end
            return embed_frameworks_phases
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

            if @frameworkArray != nil
                for lib_name in @frameworkArray
                    # lib_name_with_suffix = lib_name + '.framework'
                    # isAdded = false
                    # for ref in frameworks_build_phases.files_references
                    #     if ref != nil and lib_name_with_suffix == ref.name
                    #         isAdded = true
                    #     end
                    # end
                    # if !isAdded
                        
                    # end
                    # puts 'add + ' + lib_name

                    # list = target.add_system_framework(lib_name)
                    list = add_system_framework(@project, target, lib_name)
                end
            end

            if @systemTbdsArray != nil
                for lib_name in @systemTbdsArray
                    # lib_name_with_suffix = 'lib' + lib_name + '.tbd'
                    # isAdded = false
                    # for ref in frameworks_build_phases.files_references
                    #     if ref != nil and lib_name_with_suffix == ref.name
                    #         isAdded = true
                    #     end
                    # end
                    # if !isAdded
                        
                    # end
                    # target.add_system_library("stdc++")
                    add_system_tbds(@project, target, lib_name)
                end
            end

            # for ref in frameworks_build_phases.files_references
            #     p 'refref:'
            #     # p ref
            #     p ref,ref.path,ref.source_tree
            # end
        end
    end
end
