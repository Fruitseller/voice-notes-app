//
//  Item.swift
//  voice-notes-app
//
//  Created by Piotr Private Großmann on 01.01.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
