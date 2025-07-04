//
//  ContentView.swift
//  NimbusWeather
//
//  Created by Al Rotter on 7/2/25.
//


import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Weather...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Retry") {
                    viewModel.requestLocationFetchWeather()
                }
            } else if let weather = viewModel.weather {
                VStack(spacing: 20) {
                    Text("Current Weather")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    Image(systemName: weather.currentWeather.symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        WeatherInfoRow(label: "Temperature", value: weather.currentWeather.temperature.formatted())
                        WeatherInfoRow(label: "Feels Like", value: weather.currentWeather.apparentTemperature.formatted())
                        WeatherInfoRow(label: "Condition", value: weather.currentWeather.condition.description)
                        WeatherInfoRow(label: "Cloud Coverage", value: String(format: "%.0f%%", weather.currentWeather.cloudCover * 100))
                        WeatherInfoRow(label: "Humidity", value: weather.currentWeather.humidity.formatted(.percent))
                        WeatherInfoRow(label: "Wind Speed", value: weather.currentWeather.wind.speed.formatted())
                        WeatherInfoRow(label: "Wind Direction", value: weather.currentWeather.wind.compassDirection.description)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .shadow(radius: 5)
            } else {
                Text("Tap 'Get Weather' to fetch current conditions.")
                    .font(.headline)
                Button("Get Weather") {
                    viewModel.requestLocationFetchWeather()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            viewModel.requestLocationFetchWeather()
        }
    }
}

// Helper View for displaying weather info rows
struct WeatherInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
//struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//}

#Preview {
    WeatherView()
        
}
