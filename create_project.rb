require 'xcodeproj'

project_path = 'KidsMoney.xcodeproj'
project = Xcodeproj::Project.new(project_path)

target = project.new_target(:application, 'KidsMoney', :ios, '16.0')

group = project.main_group.new_group('KidsMoney', 'Allowance')
models = group.new_group('Models', 'Models')
viewmodels = group.new_group('ViewModels', 'ViewModels')
views = group.new_group('Views', 'Views')
resources = group.new_group('Resources', 'Resources')

[
  'Allowance/AllowanceApp.swift',
  'Allowance/Models/Models.swift',
  'Allowance/ViewModels/AllowanceStore.swift',
  'Allowance/Views/ContentView.swift',
  'Allowance/Views/ChildSelectionView.swift',
  'Allowance/Views/DashboardView.swift',
  'Allowance/Views/SettingsView.swift',
  'Allowance/Views/ChoreManagementView.swift',
  'Allowance/Views/SpendView.swift',
  'Allowance/Views/HistoryView.swift'
].each do |path|
  ref = case
        when path.include?('/Models/') then models.new_file(File.basename(path))
        when path.include?('/ViewModels/') then viewmodels.new_file(File.basename(path))
        when path.include?('/Views/') then views.new_file(File.basename(path))
        else group.new_file(File.basename(path))
        end
  target.add_file_references([ref])
end

assets_ref = resources.new_file('Assets.xcassets')
target.resources_build_phase.add_file_reference(assets_ref)

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.keitane.allowance'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Kids Money'
  config.build_settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
end

project.save
puts "Created #{project_path}"
