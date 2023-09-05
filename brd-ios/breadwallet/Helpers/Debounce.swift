// 
//  Debounce.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/09/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class Debounce<T: Equatable> {
    private init() {}
    
    static func input(_ input: T,
                      comparedAgainst current: @escaping @autoclosure () -> (T),
                      perform: @escaping (T) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.short.rawValue) {
            if input == current() { perform(input) }
        }
    }
}
