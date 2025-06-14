//
//  Restaurant.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 30/05/2025.
//

import Foundation

struct Restaurant: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var menu: [String: [String]] // category: [items]
    
    func randomMeal() -> [String: String] {
        var result: [String: String] = [:]
        for (category, items) in menu {
            if let randomItem = items.randomElement() {
                result[category] = randomItem
            }
        }
        return result
    }
}
