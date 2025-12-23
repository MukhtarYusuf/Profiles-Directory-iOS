// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProfilesDirectory",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ProfilesDirectory",
            targets: ["ProfilesDirectory"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.1.0"),
        .package(url: "https://github.com/keitaoouchi/MarkdownView.git", from: "1.9.1"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit.git", from: "4.0.0"),
        .package(url: "https://github.com/timbersoftware/SwiftUIRefresh", from: "0.0.3"),
//        .package(url: "https://dyscan@github.com/Dyneti/dyscan-ios-distribution.git", from: "1.2.6"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
//        .package(url: "https://github.com/paywith/mrewards-api-ios", branch: "main"),
//        .package(url: "https://github.com/Wootric/WootricSDK-iOS", from: "0.27.0")
        
        // TODO: Uncomment when we update min iOS version
        /*
         .package(url: "https://github.com/AndreaMiotto/PartialSheet", from: "2.0.0"),
         .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI", from: "3.0.0"),
         */
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ProfilesDirectory",
            dependencies: [
                "KeychainAccess",
                "MarkdownView",
                "PhoneNumberKit",
                "SwiftUIRefresh",
//                .product(name: "DyScan", package: "dyscan-ios-distribution"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
//                .product(name: "mRewardsAPI", package: "mrewards-api-ios"),
//                .product(name: "WootricSDK", package: "WootricSDK-iOS")
                
                // TODO: Uncomment when we update min iOS version
                /*
                 "PartialSheet",
                 "SDWebImageSwiftUI"
                 */
            ],
            path: "MukFinalProject/MukfinalProject/Views"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
