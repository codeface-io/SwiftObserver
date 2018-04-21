 Pod::Spec.new do |s|
    
    # meta infos
    s.name             = "Flowtoolz"
    s.version          = "0.2.0"
    s.summary          = "A collection of re-usable Swift code"
    s.description      = "A collection of re-usable Swift code"
    s.homepage         = "https://flowtoolz.com"
    s.license          = 'commercial'
    s.author           = { "Flowtoolz" => "contact@flowtoolz.com" }
    s.source           = {  :git => "https://github.com/flowtoolz/Flowtoolz.git",
                            :tag => s.version.to_s }
    
    # to be sure
    s.requires_arc = true
    
    # minimum platform SDKs
    s.platforms = {:ios => "9.0", :osx => "10.10", :tvos => "9.0"}

    # minimum deployment targets
    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '9.0'
    
    # swift
    s.subspec 'Swift' do |ss|
        ss.source_files = 'Code/swift/**/*.swift'
    end
    
    # foundation
    s.subspec 'Foundation' do |ss|
        ss.source_files = 'Code/foundation/**/*.swift'
        ss.dependency 'ReachabilitySwift', '3'
    end
    
    # ui
    s.subspec 'UI' do |ss|
        ss.ios.source_files = 'Code/uikit/**/*.swift'
        ss.tvos.source_files = 'Code/uikit/**/*.swift'
        ss.osx.source_files = 'Code/appkit/**/*.swift'
        ss.dependency 'PureLayout', '3.0.2'
    end

end
