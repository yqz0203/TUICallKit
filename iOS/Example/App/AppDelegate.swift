//
//  AppDelegate.swift
//  TUICallKitApp
//
//  Created by adams on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import UserNotifications
import ImSDK_Plus
import TIMPush
import PushKit
import TUIVoIPExtension

#if canImport(TUICallKit_Swift)
import TUICallKit_Swift
#elseif canImport(TUICallKit)
import TUICallKit
#endif

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

/// You need to register a developer certificate with Apple, download and generate the certificate (P12 file) in their developer accounts, and upload the generated P12 file to the Tencent certificate console.
/// The console will automatically generate a certificate ID and pass it to the `businessID` parameter.
#if DEBUG
let business_id: Int32 = 47213
#else
let business_id: Int32 = 47212
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var voipRegistry: PKPushRegistry?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self, selector: #selector(configIfLoggedIn(_:)),
                                               name: Notification.Name("TUILoginSuccessNotification"),
                                               object: nil)
        
        // 配置 PushKit for VoIP
        setupPushKit()
        
        // 上报证书 ID
        TUIVoIPExtension.setCertificateID(1234)
        
        return true
    }
    
    func setupPushKit() {
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    @objc func configIfLoggedIn(_ notification: Notification) {
        DispatchQueue.main.async {
            TUICallKit.createInstance().enableFloatWindow(enable: SettingsConfig.share.floatWindow)
#if canImport(TUICallKit_Swift)
            TUICallKit.createInstance().enableVirtualBackground(enable: SettingsConfig.share.enableVirtualBackground)
            TUICallKit.createInstance().enableIncomingBanner(enable: SettingsConfig.share.enableIncomingBanner)
#endif
        }
    }
}

// MARK: - Configuration Apple Push Notification Service (APNs)

extension AppDelegate: TIMPushDelegate {
    func businessID() -> Int32 {
        return business_id;
    }
    
    //    func applicationGroupID() -> String {
    //        return "";
    //    }
    //
    //    func onRemoteNotificationReceived(_ notice: String?) -> Bool {
    //
    //    }
}

// MARK: - PushKit VoIP Push Configuration

extension AppDelegate: PKPushRegistryDelegate {
    // VoIP Token 注册成功
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP Push Token: \(token)")
        
        // 将 VoIP token 注册到腾讯云 IM
        let data = pushCredentials.token
//        TIMPush.sharedInstance()?.updateVoIPToken(data)
    }
    
    // VoIP Token 注册失败
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("VoIP Push Token invalidated")
    }
    
    // 收到 VoIP 推送
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received VoIP Push: \(payload.dictionaryPayload)")
        
        // 处理 VoIP 推送，通知 TIMPush 处理
        if let payloadDict = payload.dictionaryPayload as? [String: Any] {
//            TIMPush.sharedInstance()?.handleVoIPNotification(payloadDict)
        }
        
        completion()
    }
}
