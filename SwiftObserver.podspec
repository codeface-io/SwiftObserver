 Pod::Spec.new do |s|
    
    # meta infos
    s.name             = "SwiftObserver"
    s.version          = "6.2.0"
    s.summary          = "Reactive Swift. Minimalist, Readable, Consistent, Unintrusive, Powerful, Safe."
    s.description      = "SwiftObserver is a lightweight framework for reactive Swift. It's a bit unconventional and designed to be readable, easy, flexible, non-intrusive, simple and safe."
    s.homepage         = "http://flowtoolz.com"
    s.license          = 'MIT'
    s.author           = { "Flowtoolz" => "contact@flowtoolz.com" }
    s.source           = {  :git => "https://github.com/flowtoolz/SwiftObserver.git",
                            :tag => s.version.to_s }
    
    # compiler requirements
    s.requires_arc = true
    s.swift_version = '5.1'
    
    # minimum platform SDKs
    s.platforms = {:ios => "9.0", :osx => "10.12", :tvos => "9.0"}

    # minimum deployment targets
    s.ios.deployment_target  = '9.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '9.0'

    # sorces
    s.source_files = 'Code/**/*.swift'

    # dependencies
    s.dependency 'SwiftyToolz', '~> 1.6'
end
