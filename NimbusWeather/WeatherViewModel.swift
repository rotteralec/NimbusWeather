//
//  WeatherViewModel.swift
//  NimbusWeather
//
//  Created by Al Rotter on 7/2/25.
//




import CoreLocation 
import WeatherKit
import Foundation

class WeatherViewModel: ObservableObject {
    @Published var cloudCoverage: Double? // Will be 0.0 to 1.0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()

    // Hardcoded location for Cloud Coverage (42.53, -83.42) TO CHANGE TO LOCATION REQUEST
    private let fixedLocation = CLLocation(latitude: 42.53, longitude: -83.42)

    func fetchCloudCoverage() {
        isLoading = true
        errorMessage = nil
        cloudCoverage = nil // Clear previous data

        Task {
            do {
                // Fetch only current weather to get cloudCover for the fixed location
                let currentWeather = try await weatherService.weather(for: fixedLocation, including: .current)

                // Ensure updates happen on the main thread
                DispatchQueue.main.async {
                    self.cloudCoverage = currentWeather.cloudCover // This is a Double between 0.0 and 1.0
                    self.isLoading = false
                }
            } catch {
                // Ensure updates happen on the main thread
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
                    self.isLoading = false
                    print("WeatherKit error: \(error.localizedDescription)")
                }
            }
        }
    }
}








