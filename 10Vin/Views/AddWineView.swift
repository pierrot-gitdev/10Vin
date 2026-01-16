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
    
    @State private var selectedType: WineType = .red
    @State private var grapeVariety: String = ""
    @State private var domain: String = ""
    @State private var vintage: String = ""
    @State private var region: String = ""
    @State private var tastingNotes: String = ""
    @State private var rating: String = ""
    
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
                        
                        // Cépage
                        FormField(
                            title: "add.wine.grapeVariety".localized,
                            placeholder: "add.wine.grapeVariety.placeholder".localized,
                            text: $grapeVariety
                        )
                        
                        // Domaine
                        FormField(
                            title: "add.wine.domain".localized,
                            placeholder: "add.wine.domain.placeholder".localized,
                            text: $domain
                        )
                        
                        // Millésime
                        FormField(
                            title: "add.wine.vintage".localized,
                            placeholder: "2020",
                            text: $vintage,
                            keyboardType: .numberPad
                        )
                        
                        // Région
                        FormField(
                            title: "add.wine.region".localized,
                            placeholder: "add.wine.region.placeholder".localized,
                            text: $region
                        )
                        
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
                        
                        // Note
                        FormField(
                            title: "add.wine.rating".localized,
                            placeholder: "9.5",
                            text: $rating,
                            keyboardType: .decimalPad
                        )
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
                }
            }
        }
    }
    
    private func saveWine() {
        guard let userId = viewModel.currentUser?.id else { return }
        
        let newWine = Wine(
            type: selectedType,
            grapeVariety: grapeVariety,
            domain: domain,
            vintage: Int(vintage),
            region: region,
            tastingNotes: tastingNotes,
            rating: Double(rating),
            userId: userId
        )
        
        viewModel.addWine(newWine)
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
    AddWineView(viewModel: WineViewModel())
}
