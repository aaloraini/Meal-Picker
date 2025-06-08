//
//  ContentView.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 30/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var restaurants: [Restaurant] = RestaurantStore.shared.load()
    @State private var selectedRestaurantID: UUID?
    @State private var randomMeal: [String: String] = [:]
    @State private var showEditor = false
    @State private var isResetting = false
    @State private var editorRestaurant: Restaurant? = nil
    
    private var selectedRestaurant: Restaurant? {
        restaurants.first { $0.id == selectedRestaurantID }
    }
    
    // Define our category order
    private let categoryOrder = ["Main Dish", "Side Dish", "Extra", "Drink"]
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Restaurants List (1/3 width)
            VStack(alignment: .leading, spacing: 0) {
                Text("Restaurants")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                Divider()
                
                List(selection: $selectedRestaurantID) {
                    ForEach(restaurants) { restaurant in
                        Text(restaurant.name)
                            .tag(restaurant.id)
                            .padding(.vertical, 8)
                            .padding(.leading, 8)
                    }
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                // Action buttons at bottom of restaurants list
                VStack(spacing: 12) {
                    Button {
                        editorRestaurant = nil
                        showEditor = true
                    } label: {
                        Label("Add Restaurant", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    HStack {
                        Button {
                            editorRestaurant = selectedRestaurant
                            showEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(selectedRestaurant == nil)
                        .buttonStyle(SecondaryButtonStyle())
                        
                        if let selected = selectedRestaurant {
                            Button(role: .destructive) {
                                if let index = restaurants.firstIndex(where: { $0.id == selected.id }) {
                                    restaurants.remove(at: index)
                                    selectedRestaurantID = restaurants.first?.id
                                    randomMeal = [:]
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }
                    
                    Button(role: .destructive) {
                        isResetting = true
                    } label: {
                        Label("Reset to Default", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(12)
                .background(Color(.windowBackgroundColor))
            }
            .frame(width: 220)
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // Middle Panel: Menu Details
            VStack(alignment: .leading, spacing: 0) {
                if let selected = selectedRestaurant {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(selected.name)
                            .font(.title)
                            .bold()
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                        
                        Divider()
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(categoryOrder, id: \.self) { category in
                                    if let items = selected.menu[category] {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(category)
                                                    .font(.headline)
                                                    .foregroundColor(categoryColor(for: category))
                                                    .padding(.bottom, 4)
                                                
                                                Spacer()
                                                
                                                Text("\(items.count) items")
                                                    .foregroundColor(.secondary)
                                                    .font(.subheadline)
                                            }
                                            
                                            ForEach(items, id: \.self) { item in
                                                Text("• \(item)")
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 8)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.windowBackgroundColor))
                                        )
                                        .padding(.horizontal, 8)
                                    }
                                }
                                
                                ForEach(selected.menu.keys.sorted().filter { !categoryOrder.contains($0) }, id: \.self) { category in
                                    if let items = selected.menu[category] {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(category)
                                                    .font(.headline)
                                                    .foregroundColor(categoryColor(for: category))
                                                    .padding(.bottom, 4)
                                                
                                                Spacer()
                                                
                                                Text("\(items.count) items")
                                                    .foregroundColor(.secondary)
                                                    .font(.subheadline)
                                            }
                                            
                                            ForEach(items, id: \.self) { item in
                                                Text("• \(item)")
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 8)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.windowBackgroundColor))
                                        )
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("Select a restaurant")
                            .font(.title2)
                            .padding(.bottom, 8)
                        Text("Choose a restaurant from the list to view its menu")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity)
            
            Divider()
            
            // Right Panel: Meal Picker
            VStack(alignment: .leading, spacing: 0) {
                Text("Meal Picker")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                Divider()
                
                if let selected = selectedRestaurant {
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            VStack(spacing: 16) {
                                Spacer()
                                
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(red: 0, green: 0.3, blue: 0.7))
                                    .frame(width: 60, height: 60)
                                
                                Text("Ready to pick your meal?")
                                    .font(.title2)
                                    .fixedSize(horizontal: true, vertical: false)
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        randomMeal = selected.randomMeal()
                                    }
                                }) {
                                    Text("Pick Random Meal")
                                        .font(.headline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .fixedSize(horizontal: true, vertical: false)
                                
                                Spacer()
                            }
                            .frame(height: geometry.size.height * 0.6)
                            .frame(maxWidth: .infinity)
                            VStack {
                                if !randomMeal.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(categoryOrder, id: \.self) { category in
                                            if let item = randomMeal[category] {
                                                HStack(alignment: .top) {
                                                    Text(category)
                                                        .font(.headline)
                                                        .foregroundColor(categoryColor(for: category))
                                                        .frame(width: 100, alignment: .leading)
                                                    Text(item)
                                                        .font(.body)
                                                }
                                            }
                                        }
                                        
                                        ForEach(randomMeal.keys.sorted().filter { !categoryOrder.contains($0) }, id: \.self) { category in
                                            if let item = randomMeal[category] {
                                                HStack(alignment: .top) {
                                                    Text(category)
                                                        .font(.headline)
                                                        .foregroundColor(categoryColor(for: category))
                                                        .frame(width: 100, alignment: .leading)
                                                    Text(item)
                                                        .font(.body)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal, 16)
                                    .transition(.opacity)
                                } else {
                                    Text("")
                                        .frame(height: 0)
                                }
                            }
                            .frame(height: geometry.size.height * 0.4)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                        Text("Select a restaurant first")
                            .font(.title3)
                        Text("Choose a restaurant from the list to start picking meals")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 280)
            .background(Color(.controlBackgroundColor))
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showEditor) {
            RestaurantEditor(restaurants: $restaurants, editingRestaurant: editorRestaurant)
        }
        .alert("Reset Restaurants?", isPresented: $isResetting) {
            Button("Reset", role: .destructive) {
                restaurants = RestaurantStore.shared.resetToDefault()
                selectedRestaurantID = restaurants.first?.id
                randomMeal = [:]
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove all custom restaurants and restore the original list.")
        }
        .onAppear {
            if restaurants.isEmpty {
                restaurants = RestaurantStore.shared.resetToDefault()
            }
            selectedRestaurantID = nil
        }
        .onChange(of: restaurants) { _, _ in
            RestaurantStore.shared.save(restaurants)
            if let selectedID = selectedRestaurantID,
               !restaurants.contains(where: { $0.id == selectedID }) {
                selectedRestaurantID = restaurants.first?.id
            }
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Main Dish":
            return Color(red: 0.0, green: 0.3, blue: 0.7)
        case "Side Dish":
            return Color(red: 0.0, green: 0.5, blue: 0.2)
        case "Drink":
            return Color(red: 0.8, green: 0.4, blue: 0.0)
        case "Extra":
            return Color(red: 0.5, green: 0.0, blue: 0.5)
        default:
            return Color(red: 0.3, green: 0.3, blue: 0.3)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
