Pod::Spec.new do |spec|
    spec.name     = "LibToken"
    spec.version  = "2.0.0"
    spec.summary  = "A library for managing 2FA tokens"
    spec.homepage = "https://github.com/OTPio/LibToken"
    spec.license  = "MIT"
    spec.author   = "MatrixSenpai"
    
    spec.swift_versions            = ["5.0"]
    spec.ios.deployment_target     = "12.0"
    spec.osx.deployment_target     = "10.13"
    spec.watchos.deployment_target = "4.0"
    spec.tvos.deployment_target    = "12.0"
    
    spec.source       = { :git => "https://github.com/OTPio/LibToken.git", :tag => spec.version }
    spec.source_files = "Sources/LibToken/**/*.{swift}"
    
    spec.dependency "SwiftBase32", "~> 0.8.0"
end
