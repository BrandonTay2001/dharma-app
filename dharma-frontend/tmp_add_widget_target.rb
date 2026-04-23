require 'rubygems'
require 'xcodeproj'

project_path = File.expand_path('dharma.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
app_target = project.targets.find { |target| target.name == 'dharma' }
raise 'App target not found' unless app_target

widget_name = 'dharma-widget-extension'
widget_target = project.targets.find { |target| target.name == widget_name }

unless widget_target
    widget_target = project.new_target(:app_extension, widget_name, :ios, '26.2')
end

widget_target.build_configurations.each do |config|
    settings = config.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'xyz.618263.dharma.dharma-widget-extension'
    settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    settings['INFOPLIST_FILE'] = 'dharma-widget-extension/Info.plist'
    settings['CODE_SIGN_ENTITLEMENTS'] = 'dharma-widget-extension/dharma-widget-extension.entitlements'
    settings['CODE_SIGN_STYLE'] = 'Automatic'
    settings['DEVELOPMENT_TEAM'] = '96ZFT3PD83'
    settings['CURRENT_PROJECT_VERSION'] = '1'
    settings['MARKETING_VERSION'] = '1.0'
    settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
    settings['IPHONEOS_DEPLOYMENT_TARGET'] = '26.2'
    settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
    settings['TARGETED_DEVICE_FAMILY'] = '1'
    settings['SKIP_INSTALL'] = 'YES'
    settings['SWIFT_VERSION'] = '5.0'
    settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
    settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

main_group = project.main_group
widget_group = main_group.find_subpath(widget_name, true)
widget_group.path = widget_name
widget_group.set_source_tree('<group>')

{
    'DailyVerseWidget.swift' => :source,
    'dharma_widget_extension.swift' => :source,
    'Info.plist' => :other,
    'dharma-widget-extension.entitlements' => :other,
}.each do |file_name, kind|
    file_ref = widget_group.files.find { |file| file.path == file_name } || widget_group.new_file(file_name)
    next unless kind == :source

    unless widget_target.source_build_phase.files_references.include?(file_ref)
        widget_target.add_file_references([file_ref])
    end
end

embed_phase = app_target.copy_files_build_phases.find { |phase| phase.name == 'Embed App Extensions' } || app_target.new_copy_files_build_phase('Embed App Extensions')
embed_phase.symbol_dst_subfolder_spec = :plug_ins
product_ref = widget_target.product_reference

unless embed_phase.files_references.include?(product_ref)
    build_file = embed_phase.add_file_reference(product_ref)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy', 'CodeSignOnCopy'] }
end

unless app_target.dependencies.any? { |dependency| dependency.target == widget_target }
    app_target.add_dependency(widget_target)
end

project.save
