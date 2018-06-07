#!/usr/bin/ruby

#xcodeproj文档: https://www.rubydoc.info/gems/xcodeproj/Xcodeproj
#https://github.com/typedef/Xcodeproj

#require 'xcodeproj'
#require 'set'
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

    class CopyInfo
        def initialize(srcPath, dstPath)
            @srcPath = srcPath
            @dstPath = dstPath
        end

        def getSrcPath()
            return @srcPath
        end

        def getDstPath()
            return @dstPath
        end
    end

    class AutoSet

        def initialize(projectPath, copyArray, systemFrameworkArray, systemTbdsArray, product_bundle_identifier)
            @projectPath = projectPath
            @copyArray = copyArray
            @systemFrameworkArray = systemFrameworkArray
            @systemTbdsArray = systemTbdsArray
            @product_bundle_identifier = product_bundle_identifier

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

            for copyInfo in @copyArray
                autoSetDstPath = File::expand_path(copyInfo.getDstPath(), fullDstRootDir)
                copyFiles(copyInfo.getSrcPath(), autoSetDstPath)
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
                            #为所有.a和.framework 设置 force_load
                            if subItem.end_with?('.m') or subItem.end_with?('.mm') \
                                or subItem.end_with?('.c') or subItem.end_with?('.cpp')
                                #编译文件
                                target.add_file_references([file_ref])
                            elsif subItem.end_with?('.a') or subItem.end_with?('.framework')
                                #库文件
                                target.frameworks_build_phases.add_file_reference(file_ref)
                                relatively_path = fullSubItem[@rootDir.length, fullSubItem.length - @rootDir.length]
                                xcode_set_build_libfiles_settings(target, relatively_path)
                            else
                                #资源文件
                                target.add_resources([file_ref])
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
                str = '$(PROJECT_DIR)' + dir_path
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
                configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = @product_bundle_identifier

                #$(SRCROOT) 和 $(SRCROOT)/Libraries 带有双引号会导致找不到库文件， 原因不明
                library_search_paths = configuration.build_settings['LIBRARY_SEARCH_PATHS']
                if library_search_paths == nil or library_search_paths.is_a? String
                    configuration.build_settings['LIBRARY_SEARCH_PATHS'] = Array.new
                    if library_search_paths.is_a? String
                        configuration.build_settings['LIBRARY_SEARCH_PATHS'].push(library_search_paths)
                    end
                    library_search_paths = configuration.build_settings['LIBRARY_SEARCH_PATHS']
                end
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

            for lib_name in @systemFrameworkArray
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

            # for ref in frameworks_build_phases.files_references
            #     p 'refref:'
            #     # p ref
            #     p ref,ref.path,ref.source_tree
            # end
        end
    end
end
