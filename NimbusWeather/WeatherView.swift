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
            Spacer()
            //while weatherviewmodel is fetching cloud coverage
            if viewModel.isLoading {
                ProgressView("Loading Cloud Coverage...")
                    .font(.title2)
            } else if let errorMessage = viewModel.errorMessage { //Error Message, TODO replace with upside down nim or weird nim pic
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry Fetch") {
                        viewModel.requestLocationAndFetchCloudCoverage()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let cloudCoverage = viewModel.cloudCoverage {//once loading is done
                
                let cloudCoverageInt = Int(cloudCoverage*100)
                // Display cloud coverage as a percentage
                Text("Cloud Coverage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text(String(format: "%.0f%%", cloudCoverage * 100))
                    .font(.system(size: 80, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                
                GeometryReader{ geometry in
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        ForEach(0..<cloudCoverageInt, id: \.self) {_ in
                                Image("nimbusPics")
                                .resizable()
                                .scaledToFit()//Maintain aspect ratio
                                .frame(width:75, height: 75)
                                .position(
                                    //Randomly position each image within the screen box
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                            //Trying animation or rotation?
                                .rotationEffect(.degrees(Double.random(in: 0...360)))
                                .opacity(Double.random(in: 0.6...1.0))
                        }
                        
                    }
                    
                }
                // Change Icon based on coverage
//                Image("nimbusPics")//getCloudIcon(for: cloudCoverage))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 120, height: 120)
//                    //.foregroundColor(.gray)
//                    .opacity(0.8)
//                    .padding(.top, 20)

            } else {
                Text("Cloud Coverage will appear here.")
                    .font(.headline)
                    .padding(.bottom, 20)
                Button("Get Cloud Coverage") {
                    viewModel.requestLocationAndFetchCloudCoverage()
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }//End of VStack
        .padding()
        .onAppear {
            // Fetch weather directly when the view appears (add location request after)
            viewModel.requestLocationAndFetchCloudCoverage()
        }
    }// End of body

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
            return "cloud.heavyrain.fill"
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

