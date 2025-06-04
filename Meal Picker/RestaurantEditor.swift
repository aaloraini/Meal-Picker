//
//  RestaurantEditor.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 30/05/2025.
//

import SwiftUI

struct RestaurantEditor: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var restaurants: [Restaurant]
    @State var name: String = ""
    @State var menu: [String: [String]] = [:]
    
    var editingRestaurant: Restaurant?
    
    @State private var newCategoryName = ""
    @State private var newItemName = ""
    @State private var selectedCategory: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(editingRestaurant == nil ? "Add Restaurant" : "Edit Restaurant")
                .font(.title2)
                .bold()
            
            TextField("Restaurant Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Categories")
                        .font(.headline)
                    
                    List {
                        ForEach(menu.keys.sorted(), id: \.self) { category in
                            Text(category)
                                .onTapGesture {
                                    selectedCategory = category
                                }
                                .background(selectedCategory == category ? Color.blue.opacity(0.3) : Color.clear)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let key = menu.keys.sorted()[index]
                                menu.removeValue(forKey: key)
                                if selectedCategory == key {
                                    selectedCategory = nil
                                }
                            }
                        }
                    }
                    HStack {
                        TextField("New Category", text: $newCategoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Add") {
                            let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            if menu[trimmed] == nil {
                                menu[trimmed] = []
                                selectedCategory = trimmed
                                newCategoryName = ""
                            }
                        }
                    }
                }
                .frame(width: 150)
                
                VStack(alignment: .leading) {
                    Text("Items")
                        .font(.headline)
                    
                    if let selected = selectedCategory, let items = menu[selected] {
                        List {
                            ForEach(items, id: \.self) { item in
                                Text(item)
                            }
                            .onDelete { indexSet in
                                guard let selected = selectedCategory else { return }
                                for index in indexSet {
                                    menu[selected]?.remove(at: index)
                                }
                            }
                        }
                        
                        HStack {
                            TextField("New Item", text: $newItemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Add") {
                                let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty, let selected = selectedCategory else { return }
                                menu[selected]?.append(trimmed)
                                newItemName = ""
                            }
                        }
                    } else {
                        Text("Select a category to add items")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .frame(minWidth: 200)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button(editingRestaurant == nil ? "Add" : "Save") {
                    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty else { return }
                    
                    let restaurant = Restaurant(
                        id: editingRestaurant?.id ?? UUID(),
                        name: trimmedName,
                        menu: menu
                    )
                    
                    if let editing = editingRestaurant {
                        if let index = restaurants.firstIndex(where: { $0.id == editing.id }) {
                            restaurants[index] = restaurant
                        }
                    } else {
                        restaurants.append(restaurant)
                    }
                    
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .onAppear {
            if let editing = editingRestaurant {
                name = editing.name
                menu = editing.menu
                selectedCategory = menu.keys.first
            } else {
                menu = [:]
                selectedCategory = nil
            }
        }
        .frame(width: 450, height: 400)
    }
}
