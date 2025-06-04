//
//  ContentView.swift
//  Meal Picker
//
//  Created by Abdulhakim Aloraini on 30/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var restaurants: [Restaurant] = RestaurantStore.shared.load()
    @State private var selectedRestaurant: Restaurant?
    @State private var randomMeal: [String: String] = [:]
    @State private var showEditor = false
    @State private var isResetting = false

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack {
                List(selection: $selectedRestaurant) {
                    ForEach(restaurants) { restaurant in
                        Text(restaurant.name)
                            .tag(restaurant)
                    }
                }
                .frame(minWidth: 200)
                .listStyle(SidebarListStyle())
            }

            Divider()

            // Detail View
            VStack(alignment: .leading, spacing: 16) {
                if let selected = selectedRestaurant {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Menu for \(selected.name)")
                                .font(.title)
                                .bold()

                            // Show full menu
                            ForEach(selected.menu.sorted(by: { $0.key < $1.key }), id: \.key) { category, items in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.green)

                                    ForEach(items, id: \.self) { item in
                                        Text("• \(item)")
                                            .padding(.leading)
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            // Random Meal Section
                            Button("Pick Random Meal") {
                                randomMeal = selected.randomMeal()
                            }
                            .padding()

                            if !randomMeal.isEmpty {
                                Text("Random Meal")
                                    .font(.headline)

                                ForEach(randomMeal.sorted(by: { $0.key < $1.key }), id: \.key) { category, item in
                                    HStack {
                                        Text(category).bold()
                                        Spacer()
                                        Text(item)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Select a restaurant to view its menu")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Bottom Buttons
                HStack {
                    Button {
                        showEditor = true
                    } label: {
                        Label("Add/Edit Restaurant", systemImage: "plus.circle.fill")
                    }

                    if let selected = selectedRestaurant {
                        Button(role: .destructive) {
                            if let index = restaurants.firstIndex(of: selected) {
                                restaurants.remove(at: index)
                                selectedRestaurant = restaurants.first
                                randomMeal = [:]
                                RestaurantStore.shared.save(restaurants)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    Spacer()

                    Button(role: .destructive) {
                        isResetting = true
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .frame(minWidth: 700, minHeight: 500)
        .sheet(isPresented: $showEditor) {
            EditRestaurantsView(restaurants: $restaurants)
        }
        .alert("Reset Restaurants?", isPresented: $isResetting) {
            Button("Reset", role: .destructive) {
                restaurants = RestaurantStore.shared.resetToDefault()
                selectedRestaurant = restaurants.first
                randomMeal = [:]
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove all custom restaurants and restore the original list.")
        }
        .onAppear {
            selectedRestaurant = restaurants.first
        }
    }
}
