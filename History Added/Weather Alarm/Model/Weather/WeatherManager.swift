//
//  WeatherManager.swift
//  Weather Alarm
//
//  Created by Yuan Li on 17/5/21.
//

//
//  WeatherAPI.swift
//  Weather Alarm
//
//  Created by Allegra Lonard on 14/5/21.
//

import Foundation
import CoreLocation

//For manage weather API
class WeatherManager {
    
    //set up API URL
    static let shared = WeatherManager()
    let queryURL = "https://api.openweathermap.org/data/2.5/onecall?lat=60.99&lon=30.0&appid=8c677148620116087ba0926e83f4425a"
    let URL_API_KEY = "8c677148620116087ba0926e83f4425a"
    var URL_LATITUDE = "60.99"
    var URL_LONGITUDE = "30.0"
    var URL_GET_ONE_CALL = ""
    let URL_BASE = "https://api.openweathermap.org/data/2.5"
    let session = URLSession(configuration: .default)
    
    //set up API URL
    func buildURL() -> String {
        URL_GET_ONE_CALL = "/onecall?lat=" + URL_LATITUDE + "&lon=" + URL_LONGITUDE + "&units=metric" + "&appid=" + URL_API_KEY
        return URL_BASE + URL_GET_ONE_CALL
    }
    
    //URL elements
    func setLatitude(_ latitude: String) {
        URL_LATITUDE = latitude
    }
    
    func setLatitude(_ latitude: Double) {
        setLatitude(String(latitude))
    }
    
    func setLongitude(_ longitude: String) {
        URL_LONGITUDE = longitude
    }
    
    func setLongitude(_ longitude: Double) {
        setLongitude(String(longitude))
    }
    
    func getWeather(onSuccess: @escaping (WeatherData) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: buildURL()) else {
            onError("Error building URL")
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid data or response")
                    return
                }
                
                do {
                    if response.statusCode == 200 {
                        let items = try JSONDecoder().decode(WeatherData.self, from: data)
                        onSuccess(items)
                    } else {
                        onError("Response wasn't 200. It was: " + "\n\(response.statusCode)")
                    }
                } catch {
                    onError(error.localizedDescription)
                }
            }
            
        }
        task.resume()
    }
}
