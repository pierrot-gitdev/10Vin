//
//  AddWineView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct AddWineView: View {
    @ObservedObject var viewModel: WineViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    
    @State private var selectedType: WineType = .red
    @State private var selectedGrapeVariety: String = ""
    @State private var domain: String = ""
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedRegion: String = ""
    @State private var tastingNotes: String = ""
    @State private var rating: Double = 5.0
    
    @State private var showYearPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type de vin
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.type".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(WineType.allCases, id: \.self) { type in
                                    TypeButton(
                                        type: type,
                                        isSelected: selectedType == type
                                    ) {
                                        selectedType = type
                                    }
                                }
                            }
                        }
                        
                        // Cépage (Dropdown)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.grapeVariety".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            Menu {
                                ForEach(FrenchWineData.grapeVarieties, id: \.self) { variety in
                                    Button(variety) {
                                        selectedGrapeVariety = variety
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedGrapeVariety.isEmpty ? "add.wine.grapeVariety.placeholder".localized : selectedGrapeVariety)
                                        .foregroundColor(selectedGrapeVariety.isEmpty ? .gray : WineTheme.darkGray)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(WineTheme.burgundy)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Domaine
                        FormField(
                            title: "add.wine.domain".localized,
                            placeholder: "add.wine.domain.placeholder".localized,
                            text: $domain
                        )
                        
                        // Millésime (Sélecteur d'année)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.vintage".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            Button(action: {
                                withAnimation {
                                    showYearPicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(String(format: "%d", selectedYear))
                                        .foregroundColor(WineTheme.darkGray)
                                        .font(.body)
                                    Spacer()
                                    Image(systemName: showYearPicker ? "chevron.up" : "chevron.down")
                                        .foregroundColor(WineTheme.burgundy)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            if showYearPicker {
                                Picker("", selection: $selectedYear) {
                                    ForEach(FrenchWineData.years, id: \.self) { year in
                                        Text(String(format: "%d", year)).tag(year)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        
                        // Région (Dropdown)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.region".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            Menu {
                                ForEach(FrenchWineData.regions, id: \.self) { region in
                                    Button(region) {
                                        selectedRegion = region
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRegion.isEmpty ? "add.wine.region.placeholder".localized : selectedRegion)
                                        .foregroundColor(selectedRegion.isEmpty ? .gray : WineTheme.darkGray)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(WineTheme.burgundy)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Notes de dégustation
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.tastingNotes".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            TextEditor(text: $tastingNotes)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Note (Incrémenteur)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("add.wine.rating".localized)
                                .font(.headline)
                                .foregroundColor(WineTheme.burgundy)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    if rating > 0 {
                                        rating = max(0, rating - 0.5)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(rating > 0 ? WineTheme.burgundy : .gray)
                                }
                                .disabled(rating <= 0)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(WineTheme.burgundy)
                                    .frame(minWidth: 80)
                                
                                Spacer()
                                
                                Button(action: {
                                    if rating < 10 {
                                        rating = min(10, rating + 0.5)
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(rating < 10 ? WineTheme.burgundy : .gray)
                                }
                                .disabled(rating >= 10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("add.wine.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("add.wine.cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(WineTheme.darkGray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("add.wine.save".localized) {
                        saveWine()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(WineTheme.burgundy)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !domain.isEmpty &&
        !selectedGrapeVariety.isEmpty &&
        !selectedRegion.isEmpty
    }
    
    private func saveWine() {
        guard let userId = viewModel.currentUser?.id else { return }
        
        let newWine = Wine(
            type: selectedType,
            grapeVariety: selectedGrapeVariety,
            domain: domain,
            vintage: selectedYear,
            region: selectedRegion,
            tastingNotes: tastingNotes,
            rating: rating,
            userId: userId
        )
        
        viewModel.addWine(newWine)
        
        // Rediriger vers le feed (index 0)
        selectedTab = 0
        dismiss()
    }
}

struct TypeButton: View {
    let type: WineType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(type.color)
                    .frame(width: 16, height: 16)
                Text(type.displayName.localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? type.color.opacity(0.2) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? type.color : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .foregroundColor(isSelected ? type.color : WineTheme.darkGray)
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(WineTheme.burgundy)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AddWineView(viewModel: WineViewModel(), selectedTab: .constant(0))
}
