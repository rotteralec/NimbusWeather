//
//  ContentView.swift
//  NimbusWeather
//
//  Created by Al Rotter on 7/2/25.
//



import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            Spacer() // Pushes content towards the center/top

            if viewModel.isLoading {
                ProgressView("Loading Cloud Coverage...")
                    .font(.title2)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry Fetch") { // Changed text from "Retry" to clarify
                        viewModel.fetchCloudCoverage()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let cloudCoverage = viewModel.cloudCoverage {
                // Display cloud coverage as a percentage
                Text("Cloud Coverage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text(String(format: "%.0f%%", cloudCoverage * 100))
                    .font(.system(size: 80, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)

                // Optional: Add a subtle icon based on coverage
                Image(systemName: getCloudIcon(for: cloudCoverage))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .opacity(0.8)
                    .padding(.top, 20)

            } else {
                Text("Cloud Coverage will appear here.")
                    .font(.headline)
                    .padding(.bottom, 20)
                Button("Get Cloud Coverage") {
                    viewModel.fetchCloudCoverage()
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer() // Pushes content towards the center/bottom
        }
        .padding()
        .onAppear {
            // Fetch weather directly when the view appears (no location request needed)
            viewModel.fetchCloudCoverage()
        }
    }

    // Helper function to get an SF Symbol based on cloud coverage
    private func getCloudIcon(for coverage: Double) -> String {
        switch coverage {
        case 0.0..<0.15: // 0-14%
            return "sun.max.fill"
        case 0.15..<0.40: // 15-39%
            return "cloud.sun.fill"
        case 0.40..<0.70: // 40-69%
            return "cloud.fill"
        default: // 70-100%
            return "cloud.heavyrain.fill" // Or just "cloud.fill" if you prefer
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

