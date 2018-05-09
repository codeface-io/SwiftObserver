 Pod::Spec.new do |s|
    
    # meta infos
    s.name             = "SwiftObserver"
    s.version          = "1.1.0"
    s.summary          = "A Reactive Swift Toolbox"
    s.description      = "A Sweet Little 'Use and Forget' Toolbox for Reactive Swift Programming"
    s.homepage         = "http://flowtoolz.com"
    s.license          = 'MIT'
    s.author           = { "Flowtoolz" => "contact@flowtoolz.com" }
    s.source           = {  :git => "https://github.com/flowtoolz/SwiftObserver.git",
                            :tag => s.version.to_s }
    
    # compiler requirements
    s.requires_arc = true
    s.swift_version = '4.0'
    
    # minimum platform SDKs
    s.platforms = {:ios => "9.0", :osx => "10.10", :tvos => "9.0"}

    # minimum deployment targets
    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '9.0'

    # sorces
    s.source_files = 'Code/**/*.swift'

    # dependencies
    s.dependency 'SwiftyToolz', '1.0.0'
end
