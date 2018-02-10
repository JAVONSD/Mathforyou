platform :ios, '9.0'

inhibit_all_warnings!

target 'Life' do
  use_frameworks!

  # JSON deserialization
  pod 'Argo', '~> 4.0'

  # Color management
  pod 'DynamicColor', '~> 4.0'

  # Date tools
  pod 'DateToolsSwift', '~> 2.0'

  # Material design
  pod 'Material', '~> 2.0'

  # Network wrapper and Rx
  pod 'Moya/RxSwift', '~> 11.0'

  # Database
  pod 'RxRealm', '~> 0.7'

  # Linting
  pod 'SwiftLint'

  target 'LifeTests' do
    inherit! :search_paths
  end

  target 'LifeUITests' do
    inherit! :search_paths
  end

end
