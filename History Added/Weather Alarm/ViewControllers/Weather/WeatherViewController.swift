//
//  WeatherViewController.swift
//  Weather Alarm
//
//  Created by Allegra Lonard on 14/5/21.
//

import UIKit
import MapKit


class WeatherViewController: UIViewController, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    // For daily and hourly weather, LableA* refers the lables on the top, LableB* refers the labels on the buttom
    @IBOutlet weak var labelA1: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var labelB1: UILabel!
    
    @IBOutlet weak var labelA2: UILabel!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var labelB2: UILabel!
    
    @IBOutlet weak var labelA3: UILabel!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var labelB3: UILabel!
    
    @IBOutlet weak var labelA4: UILabel!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var labelB4: UILabel!
    
    @IBOutlet weak var labelA5: UILabel!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var labelB5: UILabel!
    
    @IBOutlet weak var timeDateSwitch: UISegmentedControl!
    
    var city = ""
    var weatherResult: WeatherData?
    var locationManger: CLLocationManager!
    var currentlocation: CLLocation?
    var temp = 0.0
    var condition: String = ""
    var humidity = 0
    var feelsLike = 0.0
    var uvIndex = 0.0
    
    //retrive system icons
    let clear = UIImage(systemName: "sun.max")
    let rain = UIImage(systemName: "cloud.rain")
    let thunderstorm = UIImage(systemName: "cloud.bolt")
    let drizzle = UIImage(systemName: "cloud.drizzle")
    let snow = UIImage(systemName: "snow")
    let cloud = UIImage(systemName: "cloud")
    let fog = UIImage(systemName: "cloud.fog")
    let defaultPic = UIImage(systemName: "globe")
    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocation()
        getWeather()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.layoutIfNeeded()
    }
    
    //get current tempture for display on tempLabel, description(for update weatherImage)
    func getWeather() {
        WeatherManager.shared.getWeather(onSuccess: { (result) in
            self.weatherResult = result
            self.weatherResult?.sortDailyArray()
            self.weatherResult?.sortHourlyArray()
            self.temp = self.weatherResult!.current.temp
            self.condition = self.weatherResult!.current.weather[0].main
            self.humidity = self.weatherResult!.current.humidity
            self.feelsLike = self.weatherResult!.current.feels_like
            self.uvIndex = self.weatherResult!.current.uvi
            //use user defaults save data
            self.userDefaults.setValue(self.condition, forKey: "condition")
            
            self.tempLabel.text = "\(String(Int(self.temp)))°"
            if let table = self.children.first as? WeatherDetailTableViewController {
                table.humidityDetailLabel.text = String(Int(self.humidity))
                table.feelsLikeDetailLabel.text = String(Int(self.feelsLike))
                table.uvIndexDetailLabel.text = String(Int(self.uvIndex))
            }
            //update weather image according to the weather
            switch self.condition {
            case _ where self.condition == "Thunderstorm":
                self.weatherImage.image = self.thunderstorm
            case _ where self.condition == "Drizzle":
                self.weatherImage.image = self.drizzle
            case _ where self.condition == "Rain":
                self.weatherImage.image = self.rain
            case _ where self.condition == "Snow":
                self.weatherImage.image = self.snow
            case _ where self.condition == "Clouds":
                self.weatherImage.image = self.cloud
            case _ where self.condition == "Clear":
                self.weatherImage.image = self.clear
            case _ where self.condition == "Mist" || self.condition == "Smoke" || self.condition == "Haze" || self.condition == "Dust" || self.condition == "Fog" || self.condition == "Sand" || self.condition == "Ash" || self.condition == "Squall" || self.condition == "Tornado":
                self.weatherImage.image = self.fog
            default:
                self.weatherImage.image = self.defaultPic
            }
            self.updateHourlyWeather(hourly: self.weatherResult!.hourly)
            
        }) { (errorMessage) in
            debugPrint(errorMessage)
        }
    }
    
    //get system location, the respons time is very slow tho
    func getLocation() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
            // fixed slow response time problem with below code
            locationManger.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            self.currentlocation = location
            
            let latitude: Double = self.currentlocation!.coordinate.latitude
            let longitude: Double = self.currentlocation!.coordinate.longitude
            
            WeatherManager.shared.setLatitude(latitude)
            WeatherManager.shared.setLongitude(longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        if let city = placemark.locality {
                            self.city = city
                        }
                        self.cityLable.text = self.city
                    }
                }
            }
            getWeather()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    @IBAction func refreshPage(_ sender: UIButton) {
        getLocation()
        cityLable.text = city
        tempLabel.text = "\(String(Int(temp)))°"
        guard let weatherResult = weatherResult else {
            return
        }
        switch condition {
        case _ where condition == "Thunderstorm":
            weatherImage.image = thunderstorm
        case _ where condition == "Drizzle":
            weatherImage.image = drizzle
        case _ where condition == "Rain":
            weatherImage.image = rain
        case _ where condition == "Snow":
            weatherImage.image = snow
        case _ where condition == "Clouds":
            weatherImage.image = cloud
        case _ where condition == "Clear":
            weatherImage.image = clear
        case _ where condition == "Mist" || condition == "Smoke" || condition == "Haze" || condition == "Dust" || condition == "Fog" || condition == "Sand" || condition == "Ash" || condition == "Squall" || condition == "Tornado":
            weatherImage.image = fog
        default:
            weatherImage.image = defaultPic
        }
        updateHourlyWeather(hourly: weatherResult.hourly)
        
        if let table = self.children.first as? WeatherDetailTableViewController {
            table.humidityDetailLabel.text = String(Int(humidity))
            table.feelsLikeDetailLabel.text = String(Int(feelsLike))
            table.uvIndexDetailLabel.text = String(Int(uvIndex))
        }
    }
    
    //option to show weekly weather or hourly
    @IBAction func swithToWeekily(_ sender: UISegmentedControl) {
        
        guard let weatherResult = weatherResult else {
            return
        }
        if timeDateSwitch.selectedSegmentIndex == 0{
            updateHourlyWeather(hourly: weatherResult.hourly)
        } else if timeDateSwitch.selectedSegmentIndex == 1{
            updateDailyWeather(daily: weatherResult.daily)
        }
    }
    
    func updateHourlyWeather(hourly: [Hourly]){
        
        let labelA = [labelA1, labelA2, labelA3, labelA4, labelA5]
        let images = [image1, image2, image3, image4, image5]
        let labelB = [labelB1, labelB2, labelB3, labelB4, labelB5]
        
        for i in 0...4 {
            let hour = hourly[i + 1]
            let date = Date(timeIntervalSince1970: Double(hour.dt))
            let hourString = Date.getHourFrom(date: date)
            let weatherTemperature = hour.temp
            let condition = hour.weather[0].main
            print(condition)
            labelA[i]?.text = hourString
            labelB[i]?.text = "\(Int(weatherTemperature.rounded()))°C"
            switch condition {
            case _ where condition == "Thunderstorm":
                images[i]?.image = thunderstorm
            case _ where condition == "Drizzle":
                images[i]?.image = drizzle
            case _ where condition == "Rain":
                images[i]?.image = rain
            case _ where condition == "Snow":
                images[i]?.image = snow
            case _ where condition == "Clouds":
                images[i]?.image = cloud
            case _ where condition == "Clear":
                images[i]?.image = clear
            case _ where condition == "Mist" || condition == "Smoke" || condition == "Haze" || condition == "Dust" || condition == "Fog" || condition == "Sand" || condition == "Ash" || condition == "Squall" || condition == "Tornado":
                images[i]?.image = fog
            default:
                images[i]?.image = defaultPic
            }
        }
    }
    
    func updateDailyWeather(daily: [Daily]){
        
        let labelA = [labelA1, labelA2, labelA3, labelA4, labelA5]
        let images = [image1, image2, image3, image4, image5]
        let labelB = [labelB1, labelB2, labelB3, labelB4, labelB5]
        
        for i in 0...4 {
            
            let day = daily[i + 2]
            let date = Date(timeIntervalSince1970: Double(day.dt))
            let dayString = Date.getDayOfWeekFrom(date: date)
            let weatherTemperature = day.temp.day
            let condition = day.weather[0].main
            
            
            labelA[i]?.text = dayString
            labelB[i]?.text = "\(Int(weatherTemperature.rounded()))°C"
            switch condition {
            case _ where condition == "Thunderstorm":
                images[i]?.image = thunderstorm
            case _ where condition == "Drizzle":
                images[i]?.image = drizzle
            case _ where condition == "Rain":
                images[i]?.image = rain
            case _ where condition == "Snow":
                images[i]?.image = snow
            case _ where condition == "Clouds":
                images[i]?.image = cloud
            case _ where condition == "Mist" || condition == "Smoke" || condition == "Haze" || condition == "Dust" || condition == "Fog" || condition == "Sand" || condition == "Ash" || condition == "Squall" || condition == "Tornado":
                images[i]?.image = fog
            case _ where condition == "Clear":
                images[i]?.image = clear
            default:
                images[i]?.image = defaultPic
            }
        }
    }
    
}
