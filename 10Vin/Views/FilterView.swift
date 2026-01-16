//
//  FilterView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: WineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: WineType?
    @State private var selectedGrapeVariety: String?
    @State private var selectedRegion: String?
    
    private var uniqueGrapeVarieties: [String] {
        Array(Set(viewModel.wines.map { $0.grapeVariety })).sorted()
    }
    
    private var uniqueRegions: [String] {
        Array(Set(viewModel.wines.map { $0.region })).sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("filter.type".localized) {
                    Picker("filter.type".localized, selection: $selectedType) {
                        Text("filter.all".localized).tag(nil as WineType?)
                        ForEach(WineType.allCases, id: \.self) { type in
                            Text(type.displayName.localized).tag(type as WineType?)
                        }
                    }
                }
                
                Section("filter.grapeVariety".localized) {
                    Picker("filter.grapeVariety".localized, selection: $selectedGrapeVariety) {
                        Text("filter.all".localized).tag(nil as String?)
                        ForEach(uniqueGrapeVarieties, id: \.self) { variety in
                            Text(variety).tag(variety as String?)
                        }
                    }
                }
                
                Section("filter.region".localized) {
                    Picker("filter.region".localized, selection: $selectedRegion) {
                        Text("filter.all".localized).tag(nil as String?)
                        ForEach(uniqueRegions, id: \.self) { region in
                            Text(region).tag(region as String?)
                        }
                    }
                }
            }
            .navigationTitle("filter.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("filter.reset".localized) {
                        selectedType = nil
                        selectedGrapeVariety = nil
                        selectedRegion = nil
                        applyFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("filter.apply".localized) {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            selectedType = viewModel.selectedWineType
            selectedGrapeVariety = viewModel.selectedGrapeVariety
            selectedRegion = viewModel.selectedRegion
        }
    }
    
    private func applyFilters() {
        viewModel.selectedWineType = selectedType
        viewModel.selectedGrapeVariety = selectedGrapeVariety
        viewModel.selectedRegion = selectedRegion
    }
}

#Preview {
    FilterView(viewModel: WineViewModel())
}
