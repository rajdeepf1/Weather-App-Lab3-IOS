//
//  ViewController.swift
//  Lab03
//
//  Created by Rajdeep Singh on 2022-11-20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var tempratureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleImageForDemo();
    }
    
    private func displaySampleImageForDemo() {
        let config = UIImage.SymbolConfiguration (paletteColors: [
            .systemRed,
            .systemTeal, .systemYellow
        ])
        weatherConditionImage.preferredSymbolConfiguration=config
        weatherConditionImage.image = UIImage (systemName: "cloud.sun.fill")
    }
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
    }
    
    @IBAction func onSearchedTapped(_ sender: UIButton) {
        print("here")
        
        loadWeather(search: searchTextField.text)
    }
    
    func loadWeather(search: String?) {
        
        
        guard let search = search else {
            return
        }
        // Step 1: Get URL
        guard let url = getURL (query: search) else {
            print ("Could not get URL")
            return
        }
        // Step 2: Create URLSession
        let session = URLSession.shared
        // Step 3: Create task for session
        let dataTask = session.dataTask(with: url) { data, response, error in
            // network call finished
            
            guard error == nil else {
                print ("Received error")
                return
            }
            guard let data = data else
            {
                print ("No data found" )
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.tempratureLabel.text = "\(weatherResponse.current.temp_c)C"
                }
                
            }
            
            
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    private func getURL (query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "c67149dd82f9438e86f31545222111"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        print(url)
        return URL(string: url)
    }
    
    
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode (WeatherResponse.self, from: data)
        } catch {
            print ("Error decoding")
        }
        return weather
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location : Decodable{
    let name: String
}

struct WeatherCondition : Decodable{
    let text: String
    let code: Int
}

struct Weather:Decodable {
    let temp_c: Float
    let condition: WeatherCondition
}

/*
 {
     "location": {
         "name": "London",
         "region": "City of London, Greater London",
         "country": "United Kingdom",
         "lat": 51.52,
         "lon": -0.11,
         "tz_id": "Europe/London",
         "localtime_epoch": 1669052955,
         "localtime": "2022-11-21 17:49"
     },
     "current": {
         "last_updated_epoch": 1669052700,
         "last_updated": "2022-11-21 17:45",
         "temp_c": 9.0,
         "temp_f": 48.2,
         "is_day": 0,
         "condition": {
             "text": "Light rain",
             "icon": "//cdn.weatherapi.com/weather/64x64/night/296.png",
             "code": 1183
         },
         "wind_mph": 21.7,
         "wind_kph": 34.9,
         "wind_degree": 230,
         "wind_dir": "SW",
         "pressure_mb": 982.0,
         "pressure_in": 29.0,
         "precip_mm": 0.7,
         "precip_in": 0.03,
         "humidity": 87,
         "cloud": 100,
         "feelslike_c": 4.9,
         "feelslike_f": 40.7,
         "vis_km": 10.0,
         "vis_miles": 6.0,
         "uv": 1.0,
         "gust_mph": 26.6,
         "gust_kph": 42.8
     }
 }
 
 */



