//
//  EditRestaurantsView.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 03/06/2025.
//

import SwiftUI

struct EditRestaurantsView: View {
    @Binding var restaurants: [Restaurant]
    @Environment(\.dismiss) var dismiss
    @State private var newRestaurantName = ""
    @State private var newMenu: [String: String] = [
        "Main Dish": "",
        "Side Dish": "",
        "Drink": "",
        "Dessert": ""
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Add New Restaurant")
                .font(.title2)

            TextField("Restaurant Name", text: $newRestaurantName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            ForEach(newMenu.keys.sorted(), id: \.self) { category in
                TextField(category, text: Binding(
                    get: { newMenu[category] ?? "" },
                    set: { newMenu[category] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Save") {
                    let cleanedMenu = newMenu.mapValues { $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    let newRestaurant = Restaurant(name: newRestaurantName, menu: cleanedMenu)
                    restaurants.append(newRestaurant)
                    RestaurantStore.shared.save(restaurants)
                    dismiss()
                }
                .disabled(newRestaurantName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
