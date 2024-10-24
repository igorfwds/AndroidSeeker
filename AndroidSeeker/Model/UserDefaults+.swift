//
//  UserDefaults+.swift
//  AndroidSeeker
//
//  Created by ifws on 21/10/24.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let isToggled = "isToggled"
    }
    
    var isToggled: Bool {
        get {
            return bool(forKey: Keys.isToggled)
        }
        set {
            set(newValue, forKey: Keys.isToggled)
        }
    }
}
