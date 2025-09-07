//
//  Item.swift
//  eTix
//
//  Created by Tonidjoe on 07/09/2025.
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
