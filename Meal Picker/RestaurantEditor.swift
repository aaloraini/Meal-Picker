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
    @State private var name: String = ""
    @State private var menu: [String: [String]] = [:]
    var editingRestaurant: Restaurant?
    
    @State private var newCategoryName = ""
    @State private var newItemName = ""
    @State private var selectedCategory: String?
    
    // Default categories
    private let defaultCategories = ["Main Dish", "Side Dish", "Extra", "Drink"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(editingRestaurant == nil ? "Add Restaurant" : "Edit Restaurant")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)
            
            TextField("Restaurant Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
                .padding(.vertical, 8)
            
            HStack(alignment: .top, spacing: 20) {
                // Categories Section
                VStack(alignment: .leading) {
                    Text("Categories")
                        .font(.headline)
                    
                    List(selection: $selectedCategory) {
                        ForEach(menu.keys.sorted(), id: \.self) { category in
                            HStack {
                                Text(category)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    deleteCategory(category)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .tag(category as String?)
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.2), width: 1)
                    
                    HStack {
                        TextField("New Category", text: $newCategoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button {
                            addNewCategory()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .frame(width: 180)
                
                // Items Section
                VStack(alignment: .leading) {
                    Text("Items")
                        .font(.headline)
                    
                    if let selected = selectedCategory, let items = menu[selected] {
                        List {
                            ForEach(items, id: \.self) { item in
                                HStack {
                                    Text(item)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button {
                                        deleteItem(item, from: selected)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete { indices in
                                deleteItems(at: indices, from: selected)
                            }
                        }
                        .frame(height: 200)
                        .border(Color.gray.opacity(0.2), width: 1)
                        
                        HStack {
                            TextField("New Item", text: $newItemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button {
                                addNewItem(to: selected)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Text("Select a category to add items")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .keyboardShortcut(.escape)
                
                Button(editingRestaurant == nil ? "Add" : "Save") {
                    saveRestaurant()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || menu.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 450)
        .onAppear {
            if let editing = editingRestaurant {
                name = editing.name
                menu = editing.menu
                selectedCategory = menu.keys.first
            } else {
                // Pre-add default categories for new restaurants
                for category in defaultCategories {
                    if menu[category] == nil {
                        menu[category] = []
                    }
                }
                selectedCategory = defaultCategories.first
            }
        }
    }
    
    private func addNewCategory() {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if menu[trimmed] == nil {
            menu[trimmed] = []
            selectedCategory = trimmed
            newCategoryName = ""
        }
    }
    
    private func deleteCategory(_ category: String) {
        menu.removeValue(forKey: category)
        if selectedCategory == category {
            selectedCategory = menu.keys.first
        }
    }
    
    private func addNewItem(to category: String) {
        let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        menu[category]?.append(trimmed)
        newItemName = ""
    }
    
    private func deleteItem(_ item: String, from category: String) {
        if let index = menu[category]?.firstIndex(of: item) {
            menu[category]?.remove(at: index)
        }
    }
    
    private func deleteItems(at indices: IndexSet, from category: String) {
        menu[category]?.remove(atOffsets: indices)
    }
    
    private func saveRestaurant() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Filter out empty categories
        let filteredMenu = menu.filter { !$0.value.isEmpty }
        
        let restaurant = Restaurant(
            id: editingRestaurant?.id ?? UUID(),
            name: trimmedName,
            menu: filteredMenu
        )
        
        if let index = restaurants.firstIndex(where: { $0.id == editingRestaurant?.id }) {
            restaurants[index] = restaurant
        } else {
            restaurants.append(restaurant)
        }
    }
}
