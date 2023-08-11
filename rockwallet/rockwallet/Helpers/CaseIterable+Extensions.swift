// 
//  CaseIterable+Extensions.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 24/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

protocol CaseIterableDefaultsLast: Decodable & CaseIterable & RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsLast {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
