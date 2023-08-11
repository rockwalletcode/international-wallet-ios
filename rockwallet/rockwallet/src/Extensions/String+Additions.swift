//
//  String+Additions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-12.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import WalletKit

extension String {
    func matches(regularExpression pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidEmailAddress: Bool {
        guard !isEmpty else { return false }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        return matches(regularExpression: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*\\W).{8,}$")
    }

    var sanitized: String {
        return applyingTransform(.toUnicodeName, reverse: false) ?? ""
    }

    func trim(_ string: String) -> String {
        return replacingOccurrences(of: string, with: "")
    }
    
    func toMaxLength(_ length: Int) -> String {
        guard count > length else { return self }
        let lastIndex = index(startIndex, offsetBy: length)
        return String(self[..<lastIndex])
    }

    func truncateMiddle(to length: Int = 10) -> String {
        guard count > length else { return self }

        let headLength = length / 2
        let trailLength = (length - headLength) - 1

        return "\(self.prefix(headLength))…\(self.suffix(trailLength))"
    }
}

// MARK: URL/Query

extension String {
    
    static var urlQuoteCharacterSet: CharacterSet {
        if let cset = (NSMutableCharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as? NSMutableCharacterSet {
            cset.removeCharacters(in: "?=&")
            return cset as CharacterSet
        }
        return NSMutableCharacterSet.urlQueryAllowed as CharacterSet
    }
    
    var urlEscapedString: String {
        return addingPercentEncoding(withAllowedCharacters: String.urlQuoteCharacterSet) ?? ""
    }
    
    // TODO: use URLComponents
    func parseQueryString() -> [String: [String]] {
        var ret = [String: [String]]()
        var strippedString = self
        if String(self[..<self.index(self.startIndex, offsetBy: 1)]) == "?" {
            strippedString = String(self[self.index(self.startIndex, offsetBy: 1)...])
        }
        strippedString = strippedString.replacingOccurrences(of: "+", with: " ")
        strippedString = strippedString.removingPercentEncoding!
        for s in strippedString.components(separatedBy: "&") {
            let kp = s.components(separatedBy: "=")
            if kp.count == 2 {
                if var k = ret[kp[0]] {
                    k.append(kp[1])
                } else {
                    ret[kp[0]] = [kp[1]]
                }
            }
        }
        return ret
    }
}

// MARK: - Hex Conversion

extension String {
    var isValidHexString: Bool {
        return withoutHexPrefix.matches(regularExpression: "^([a-fA-F0-9][a-fA-F0-9])*$")
    }
    
    var hexToData: Data? {
        return CoreCoder.hex.decode(string: self.withoutHexPrefix)
    }
    
    var withoutHexPrefix: String {
        return self.removing(prefix: "0x")
    }
    
    func removing(prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

// MARK: -

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
