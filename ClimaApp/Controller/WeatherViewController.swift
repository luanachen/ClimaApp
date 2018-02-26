//
//  WeatherViewController.swift
//  ClimaApp
//
//  Created by Luana on 26/02/18.
//  Copyright © 2018 lccj. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    // MARK: - Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    
    // MARK: - Outlets
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var imgClima: UIImageView!
    @IBOutlet weak var labelCity: UILabel!
    
    // MARK: - Instance Variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    // MARK: - ViewCicle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    // MARK: - Actions
    @IBAction func celsosButton(_ sender: UIButton) {
        
        labelTemperature.text = "\(weatherDataModel.celsosTemp)℃"
    }
    
    @IBAction func farenButton(_ sender: UIButton) {
        
        labelTemperature.text = "\(weatherDataModel.farenTemp)℉"
    }
    
    // MARK: - Networking
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                
                print("got the datas")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.labelCity.text = "Connection Issues"
            }
        }
    }
    
    // MARK: - JSON Parsing
    func updateWeatherData(json : JSON) {
        
        if let tempResult = json["main"]["temp"].int {
            
            weatherDataModel.temperature = tempResult // in kelvin
            weatherDataModel.celsosTemp = Int(Double(weatherDataModel.temperature) - 273.15)
            weatherDataModel.farenTemp = Int(Double(weatherDataModel.temperature) * 9/5 - 459.67)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        }
        else {
            labelCity.text = "Weather Unavailable"
        }
    }
    
    // MARK: - UI Updates
    func updateUIWithWeatherData() {
        
        labelCity.text = weatherDataModel.city
        labelTemperature.text = "\(weatherDataModel.celsosTemp)"
        imgClima.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destionationVC = segue.destination as! ChangeCityViewController
            
            destionationVC.delegate = self
        }
    }
    
}

// MARK: - Extension CLLocationManagerDelegate
extension WeatherViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1] // get the last location
        
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
        labelCity.text = "Location Unavailable"
    }
    
}

// MARK: - Extension ChangeCityDelegate
extension WeatherViewController : ChangeCityDelegate {
    
    func userEnteredANewCityName(city: String) {
        
        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
}

