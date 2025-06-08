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
            "Main Dish": ["Big Mac", "McChicken", "Ayam Goreng McD (Spicy)", "Ayam Goreng McD (Regular)", "Spicy Chicken McDeluxe", "GCB (Grilled Chicken Burger)", "Filet-O-Fish", "Double Cheeseburger", "Nasi Lemak McD", "Bubur Ayam McD"],
            "Side Dish": ["French Fries", "Apple Pie", "McNuggets (6 pcs)", "McNuggets (9 pcs)", "Corn Cup", "Hash Browns"],
            "Drink": ["Coca-Cola", "Iced Milo", "Iced Lemon Tea", "Iced Latte", "Hot Coffee", "Orange Juice"],
            "Extra": ["Oreo McFlurry", "Sundae (Chocolate)", "Sundae (Strawberry)", "Cendol Sundae", "Banana Pie", "Lychee Pie"]
        ]),
        Restaurant(name: "Burger King", menu: [
            "Main Dish": ["Whopper", "Whopper Jr.", "Double Whopper", "Mushroom Swiss (Single)", "Mushroom Swiss (Double)", "Tendergrill Chicken", "Tendercrisp Chicken", "Long Chicken", "Fish N' Crisp", "Cheeseburger", "Double Cheeseburger"],
            "Side Dish": ["Fries", "Onion Rings", "Cheesy Fries", "Chicken Nuggets (6 pcs)", "Chicken Nuggets (9 pcs)"],
            "Drink": ["Coca-Cola", "Iced Lemon Tea", "Iced Milo", "Hot Coffee", "Orange Juice"],
            "Extra": ["Soft Serve Cone", "Vanilla Shake", "Chocolate Shake", "Sundae", "Apple Pie"]
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
