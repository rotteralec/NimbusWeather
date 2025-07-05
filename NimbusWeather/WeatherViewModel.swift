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
    @Published var cloudCoverage: Double? // Will be 0.0 to 1.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()

    // Hardcoded location for Cloud Coverage (42.53, -83.42) TO CHANGE TO LOCATION REQUEST
    private let fixedLocation = CLLocation(latitude: 42.53, longitude: -83.42)

    //CLLocationmanagerdelegate override
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced //For weather, the reduced accuracy is all that is needed
    }
    
    
    //CALL FOLLOWING FUNCTION INSTEAD OF FETCHCLOUDCOVERAGE
    func requestLocationAndFetchCloudCoverage() {
        isLoading = true
        errorMessage = nil
        cloudCoverage = nil //clear previous data
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation() //Request one time location
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services in settings to use app"
            isLoading = false
        @unknown default:
            errorMessage = "An unknown error occured weith location services. Please restart app and try again."
            isLoading = false
        }
    }
    
    //CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways { //Check that location authorization has already occured
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted { //if user clicks out of the location request window or presses cancel
            errorMessage = "Location access denied. Please enable location services in settings to use app."
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorMessage = "Could not retrieve current location."
            isLoading = false
            return
        }
        fetchCloudCoverage(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to get location: \(error.localizedDescription)"
        isLoading = false
        print("Location Error: \(error.localizedDescription)")
    }
    
    func fetchCloudCoverage(for cloudLocation: CLLocation) {
        isLoading = true
        errorMessage = nil
        cloudCoverage = nil // Clear previous data

        Task {
            do {
                // Fetch only current weather to get cloudCover for the fixed location
                let currentWeather = try await weatherService.weather(for: cloudLocation, including: .current)

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








