// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "audio_session", path: "../.packages/audio_session-0.2.4"),
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus-6.1.5"),
        .package(name: "file_picker", path: "../.packages/file_picker-11.0.3"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.15.2"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-16.7.1"),
        .package(name: "flutter_image_compress_common", path: "../.packages/flutter_image_compress_common-1.1.1"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-22.3.1"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+7"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.10.6"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-9.0.1"),
        .package(name: "pdfx", path: "../.packages/pdfx-2.11.0"),
        .package(name: "permission_handler_apple", path: "../.packages/permission_handler_apple-9.6.1"),
        .package(name: "share_plus", path: "../.packages/share_plus-12.0.2"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.7"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.2"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.2"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.11.1"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.5.2"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.25.1"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-image-compress-common", package: "flutter_image_compress_common"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "pdfx", package: "pdfx"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
