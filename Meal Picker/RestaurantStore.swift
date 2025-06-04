//
//  RestaurantStore.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 30/05/2025.
//

import Foundation

class RestaurantStore {
    static let shared = RestaurantStore()
    private let key = "savedRestaurants"

    private let defaultRestaurants: [Restaurant] = [
        Restaurant(name: "McDonald's", menu: [
            "Burger": ["Big Mac", "Quarter Pounder", "McDouble"],
            "Drink": ["Coke", "Sprite", "Fanta"]
        ]),
        Restaurant(name: "Burger King", menu: [
            "Burger": ["Whopper", "Cheeseburger", "Double Stacker"],
            "Drink": ["Pepsi", "Root Beer", "Water"]
        ])
    ]

    func load() -> [Restaurant] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Restaurant].self, from: data) else {
            return defaultRestaurants
        }
        return decoded
    }

    func save(_ restaurants: [Restaurant]) {
        if let data = try? JSONEncoder().encode(restaurants) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func resetToDefault() -> [Restaurant] {
        UserDefaults.standard.removeObject(forKey: key)
        return defaultRestaurants
    }
}
