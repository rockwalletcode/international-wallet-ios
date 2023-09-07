//
//  BRUserAgentHeaderGenerator.swift
//  breadwallet
//
//  Created by Ray Vander Veen on 2019-01-16.
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//

import UIKit

public class BRUserAgentHeaderGenerator {
    
    /**
     *  Returns a string to be used as the User-Agent HTTP header value in requests to the BRD back end.
     *
     *  The server will focus on the app version string, in this case 3070390, which represents 3.7.0 (390).
     */
    static let userAgentHeader: String = {
        let appName = appNameString()
        let appVersion = brdAppVersionString()
        let darwinVersion = darwinVersionString()
        let cfNetworkVersion = cfNetworkVersionString()
        
        let header = userAgentHeaderString(appName: appName,
                                           appVersion: appVersion,
                                           darwinVersion: darwinVersion,
                                           cfNetworkVersion: cfNetworkVersion)
        return header
    }()
    
    static func userAgentHeaderString(appName: String,
                                      appVersion: String,
                                      darwinVersion: String,
                                      cfNetworkVersion: String) -> String {
        return "\(appName)/\(appVersion) \(cfNetworkVersion) \(darwinVersion)"
    }
    
    static func brdAppVersionString() -> String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String,
              let build = info["CFBundleVersion"] as? String,
              let majorString = version.components(separatedBy: ".").first,
              let minorString = version.components(separatedBy: ".").dropFirst().first,
              let engineeringString = version.components(separatedBy: ".").last,
              let majorVersion = Int(majorString),
              let minorVersion = Int(minorString),
              let engineeringVersion = Int(engineeringString),
              let buildVersion = Int(build.components(separatedBy: ".").joined(separator: "")) else { return "null_version" }
        
        return String(format: "%d%02d%02d%05d", majorVersion, minorVersion, engineeringVersion, buildVersion)
    }
    
    private static func appNameString() -> String {
        return "rwintl"
    }
    
    private static func cfNetworkVersionString() -> String {
        guard let info = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary as NSDictionary?,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "null_CFNetwork"
        }
        
        return "CFNetwork/\(version)"
    }
    
    private static func darwinVersionString() -> String {
        var sysinfo = utsname()
        
        uname(&sysinfo)
        
        guard var version = String(bytes: Data(bytes: &sysinfo.release,
                                               count: Int(_SYS_NAMELEN)),
                                   encoding: .ascii) else {
            return "null_Darwin"
        }
        
        version = version.trimmingCharacters(in: .controlCharacters)
        
        return "Darwin/\(version)"
    }
}
