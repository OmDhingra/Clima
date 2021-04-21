//
//  WeatherManager.swift
//  Clima
//
//  Created by Nitin Dhingra on 14/10/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager , weather: WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=437bad89240512742f70bb52078ed7fe&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    
    func performRequest(urlString : String) {
        //Create URL
        if let url = URL(string: urlString) {
            
            //Create Url session
            let session = URLSession(configuration: .default)
            //Give session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error as! Error)
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather : weather)
                    }
                }
            }
        
        //Start task
            task.resume()
    }
        
}
    func parseJSON(weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            let temp = decodedData.main.temp
            let description = decodedData.weather[0].description
            let id = decodedData.weather[0].id
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityname: name, temperature: temp)
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
}
    

    }


