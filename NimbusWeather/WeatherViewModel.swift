//
//  WeatherViewModel.swift
//  NimbusWeather
//
//  Created by Al Rotter on 7/2/25.
//


import CoreLocation
import WeatherKit
import Foundation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather? //Not Initializing
    @Published var isLoading = false
    @Published var errorMessage: String? //Not Initializing
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    
    func requestLocationFetchWeather() {
        isLoading = true
        errorMessage = nil
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services in settings to use this app."
            isLoading = false
        @unknown default:
            errorMessage = "An unknown error occured with location services."
            isLoading = false
            
        }
    }
    
    // CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation() //Request location once authorization is granted
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            errorMessage = "Location access denied. Please enable location services in settings to use this app."
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorMessage = "Could not get current location."
            isLoading = false
            return
        }
        fetchWeather(for: location)
    }
    
    
    //WeatherKit
    
    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                //Fetch current weather, daily forcasts and wind
                // Fetch current weather, daily forecasts, and wind
                
                let currentWeather = try await weatherService.weather(for: location)
//                let (currentWeather, dailyForecast, wind) = try await weatherService.weather(
//                    for: location,
//                    including: .current, .daily(.days(1)), .wind
//                )
                
                //Exctract relevant info here
                //TODO: create a struct to hold below data
                DispatchQueue.main.async {
                    self.weather = currentWeather
                    //TODO: This is where I need to put cloud coverage access
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)."
                    self.isLoading = false
                    print("WeatherKit error: \(error.localizedDescription).")
                }
            }
        }
    }
    
}
