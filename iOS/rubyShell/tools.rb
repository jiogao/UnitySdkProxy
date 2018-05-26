require 'cocoapods'
require "fileutils"
require 'find'

class ProjectControl

    def initialize(path, sdkn)
        @project_path = path
        @sdk_name = sdkn

        @root_dir = File.dirname(@project_path)
        puts 'root_dir: ' + @root_dir
    end

    def start()
        @project = Xcodeproj::Project.open(@project_path)

        copySdkFiles()
        copySdkProxyFiles()

        @project.save
        puts '文件添加完成'
    end

    #拷贝sdk相关文件
    def copySdkFiles()
        src_path = 'SdkLibs'
        src_path = File::expand_path(src_path, @root_dir)
        org_src_path = File.expand_path('../../../../SdkLibs', __FILE__)
        # puts 'src_path: ' + src_path
        if File.exist?(src_path) then
            FileUtils.rm_rf(src_path)
        end
        FileUtils.mkdir_p(src_path)

        target_sdk_path = File::expand_path(@sdk_name, src_path)
        org_sdk_path = File.expand_path(@sdk_name, org_src_path)
        FileUtils.cp_r(org_sdk_path, target_sdk_path)

        setProject(src_path)
    end

    def copySdkProxyFiles()
        src_path = 'QKSdkProxy'
        src_path = File::expand_path(src_path, @root_dir)
        org_src_path = File.expand_path('../../QKSdkProxy', __FILE__)
        puts 'org_src_path: ' + org_src_path
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

        setProject(src_path)
    end

    #工程设置
    def setProject(src_path)
        

        # # 1、显示所有的target
        # project.targets.each do |target|
        #   puts target.name
        # end

        target = @project.targets.first

        xcode_group_readd(target, @project.main_group, src_path)

    end

    #删除文件夹中的引用
    def xcode_group_clear(group)
        for file_ref_temp in group.recursive_children
            # p file_ref_temp
            if file_ref_temp.is_a? Xcodeproj::Project::Object::PBXGroup then
                # xcode_group_clear_recursive(file_ref_temp)
            elsif file_ref_temp.is_a? Xcodeproj::Project::Object::PBXFileReference then
                file_ref_temp.remove_from_project
                p 'delete reference ' + file_ref_temp.path
            end
        end
        group.clear
    end

    # 重新添加一个文件夹
    def xcode_group_readd(target, main_group, path)
        basename = File::basename(path)
        group = main_group.find_subpath(basename, false)
        if group != nil then
            xcode_group_clear(group)
        else
            group = main_group.new_group(basename, basename)
        end

        # group.set_source_tree('SOURCE_ROOT')

        xcode_group_add_all_children(path, target, group)
    end

    # 为文件夹中的所有文件添加引用
    def xcode_group_add_all_children(path, target, main_group)
        Dir.foreach(path) do |subItem|
            if !subItem.start_with?('.') and subItem !="." and subItem !=".." then
                fullSubItem = File.expand_path(subItem, path)
                if File.directory? fullSubItem and !subItem.end_with?('.bundle')
                    group = main_group.new_group(subItem, subItem)
                    xcode_group_add_all_children(fullSubItem, target, group)
                else
                    file_ref = main_group.new_reference(subItem)
                    p 'add reference ' + file_ref.path
                    if !subItem.end_with?('.h')
                        target.add_file_references([file_ref])
                        if subItem.end_with?('.a') or subItem.end_with?('.framework')
                            relatively_path = fullSubItem[@root_dir.length, fullSubItem.length - @root_dir.length]
                            xcode_set_other_linker_flags(relatively_path, target)
                        end
                    end
                end
            end
        end
    end

    #设置 'Other Linker Flags'
    def xcode_set_other_linker_flags(relatively_path, target)
        # puts 'configurations'
        configurations = target.build_configurations
        configurations.each do |configuration|
            # puts 'configuration ======== '
            # puts configuration
            # configuration.build_settings.each do |setting|
            #    puts setting
            # end

            # 'Other Linker Flags'
            other_Linker_Flags = configuration.build_settings['OTHER_LDFLAGS']
            # puts other_Linker_Flags
            flag_str = '$(PROJECT_DIR)' + relatively_path
            if relatively_path.end_with?('.framework')
               fileName = File::basename(relatively_path, '.framework')
               flag_str = flag_str + '/' + fileName
            end
            flag_str = '"' + flag_str + '"'

            p configuration.name + ' => Other Linker Flags: ' + flag_str
            isAdded = false
            other_Linker_Flags.each do |flag|
                if flag == flag_str
                    isAdded = true
                end
            end
            if !isAdded
                other_Linker_Flags.push('-force_load', flag_str)
            end
        end
    end

end
