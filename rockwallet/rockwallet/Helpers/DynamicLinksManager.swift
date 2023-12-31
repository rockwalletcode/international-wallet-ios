// 
//  DynamicLinksManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class DynamicLinksManager {
    static var shared = DynamicLinksManager()
    
    var shouldHandleDynamicLink: Bool {
        let type = DynamicLinksManager.shared.dynamicLinkType
        
        return type != nil
    }
    
    enum DynamicLinkType: String {
        case setPassword = "op=password"
        case home
        case profile
        case oauth2 = "oauth2"
        case login = "op=web_login"
    }
    
    var dynamicLinkType: DynamicLinkType?
    var code: String?
    var loginToken: String?
    var email: String?
    var redirectUri: String?
    var urlScope: String?
    var urlParameters: [String: String]?
    
    static func getDynamicLinkType(from url: URL) -> DynamicLinkType? {
        let url = url.absoluteString
        
        if url.contains(DynamicLinkType.setPassword.rawValue) {
            return .setPassword
        } else if url.contains(DynamicLinkType.home.rawValue) {
            return .home
        } else if url.contains(DynamicLinkType.oauth2.rawValue) {
            return .oauth2
        } else if url.contains(DynamicLinkType.profile.rawValue) {
            return .profile
        } else if url.contains(DynamicLinkType.login.rawValue) {
            return .login
        }
        
        return nil
    }
    
    static func handleDynamicLink(dynamicLink: URL?) {
        guard let url = dynamicLink else { return }
        
        let dynamicLinkType = DynamicLinksManager.getDynamicLinkType(from: url)
        
        switch dynamicLinkType {
        case .setPassword:
            handleReSetPassword(with: url)
            
        case .home:
            DynamicLinksManager.shared.dynamicLinkType = .home
            
        case .profile:
            DynamicLinksManager.shared.dynamicLinkType = .profile
            
        case .oauth2:
            handleOauth2Login(with: url)
            
        case .login:
            handleLogin(with: url)
            
        default:
            break
        }
    }
    
    private static func handleReSetPassword(with url: URL) {
        guard let parameters = url.queryParameters,
              let code = parameters["code"],
              let email = parameters["email"] else {
            return
        }
        
        DynamicLinksManager.shared.dynamicLinkType = .setPassword
        DynamicLinksManager.shared.code = code
        DynamicLinksManager.shared.email = email
    }
    
    private static func handleOauth2Login(with url: URL) {
        guard let parameters = url.queryParameters else {
            return
        }
        
        DynamicLinksManager.shared.dynamicLinkType = .oauth2
        DynamicLinksManager.shared.urlParameters = parameters
    }
    
    private static func handleLogin(with url: URL) {
        guard let parameters = url.queryParameters,
              let token = parameters["token"] else {
            return
        }
        
        DynamicLinksManager.shared.dynamicLinkType = .login
        DynamicLinksManager.shared.loginToken = token
    }
}
