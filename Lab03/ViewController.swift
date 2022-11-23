//
//  ViewController.swift
//  Lab03
//
//  Created by Rajdeep Singh on 2022-11-20.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var dayImageView: UIImageView!
    
    @IBOutlet weak var nightImageView: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locLabel: UILabel!
    
    @IBOutlet weak var day_Label: UILabel!
    
    @IBOutlet weak var night_label: UILabel!
    
    @IBOutlet weak var swith: UISwitch!
    
    var searchLocationText: String = ""
    
    var copyArr:[WeatherConditionsModel] = []
    
    var weatherResponseGlobal : WeatherResponse? = nil
    
    private let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        swith.isEnabled = false
        
        displayWeatherImage(code: 0);
        displayDayNightImage()
        loadWeatherCondition()

        locationManager.delegate = self
        self.searchTextField.delegate = self

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocationText = searchTextField.text!
        loadWeather(search: searchLocationText)
        self.view.endEditing(true)

            return true
        }
    
    private func displayWeatherImage(code: Int) {
        let config = UIImage.SymbolConfiguration (paletteColors: [
            .systemYellow,
            .systemGray4, .systemYellow
        ])
        weatherConditionImage.preferredSymbolConfiguration=config
        
        print(code)
        
        switch code {
        case 0:
            self.weatherConditionImage.image = UIImage(systemName:"exclamationmark.triangle")
            
        case 1000:
            weatherConditionImage.image = UIImage (systemName: "sun.max")
        case 1003:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.circle.fill")
        case 1006:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun")
        case 1009:
            weatherConditionImage.image = UIImage (systemName: "cloud")
        case 1030:
            weatherConditionImage.image = UIImage (systemName: "smoke.fill")
        case 1063:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.circle")
        case 1066:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow")
        case 1069:
            weatherConditionImage.image = UIImage (systemName: "cloud.sleet")
        case 1072:
            weatherConditionImage.image = UIImage (systemName: "cloud.drizzle.circle.fill")
        case 1087:
            weatherConditionImage.image = UIImage (systemName: "cloud.bolt.rain")
        case 1114:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow")
        case 1117:
            weatherConditionImage.image = UIImage (systemName: "cloud.rain.circle")
        case 1135:
            weatherConditionImage.image = UIImage (systemName: "cloud.fog")
        case 1147:
            weatherConditionImage.image = UIImage (systemName: "cloud.fog")
        case 1150:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.fill")
        case 1153:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.fill")
        case 1168:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow.circle")
        case 1183:
            weatherConditionImage.image = UIImage (systemName: "cloud.rain")
        case 1189 | 1192 | 1195 :
            weatherConditionImage.image = UIImage (systemName: "cloud.rain.circle.fill")
            
        default:
            print("No Data Found")
            self.weatherConditionImage.image = UIImage (systemName: "exclamationmark.trianglel")
        }
        
        
    }
    
    private func displayDayNightImage() {
        let configDay = UIImage.SymbolConfiguration (paletteColors: [
            .systemYellow,
            .systemGray4,
        ])
        dayImageView.preferredSymbolConfiguration=configDay
        dayImageView.image = UIImage (systemName: "sun.max.circle")
        
        
        let configNight = UIImage.SymbolConfiguration (paletteColors: [
            .systemYellow,
            .systemGray4,
        ])
        nightImageView.preferredSymbolConfiguration=configNight
        nightImageView.image = UIImage (systemName: "moon.circle")
        
    }
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func onSearchedTapped(_ sender: UIButton) {
        searchLocationText = searchTextField.text!
        loadWeather(search: searchLocationText)
    }
    
    @IBAction func onSwitchToggle(_ sender: UISwitch) {
            
        if sender.isOn {
            displayData(weatherResp: self.weatherResponseGlobal!,flag: true)
        } else {
            displayData(weatherResp: self.weatherResponseGlobal!,flag: false)
        }
    }
    
    func loadWeatherCondition() {
            guard let url = URL(string: "https://www.weatherapi.com/docs/weather_conditions.json") else {
                print("Invalid URL")
                return
            }
            let request = URLRequest(url: url)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let response = try? JSONDecoder().decode([WeatherConditionsModel].self, from: data) {
                        DispatchQueue.main.async {
                            self.copyArr = response
                        }
                        return
                    }
                }
            }.resume()
        }
    
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Got location")
        
        if let location = locations.last {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print ("LatLng: (\(latitude),\(longitude))")
            searchLocationText = "\(latitude),\(longitude)"
            loadWeather(search: searchLocationText)
            
        }
        
    }

        func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
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
                
                self.weatherResponseGlobal = weatherResponse
                self.displayData(weatherResp: self.weatherResponseGlobal!, flag: true)
                
            }
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    func displayData(weatherResp: WeatherResponse, flag: Bool)  {

        let filtered = self.copyArr.filter{ val in
          return val.code == weatherResp.current.condition.code
        }
        if flag {
            DispatchQueue.main.async {
                self.swith.isEnabled = true
                self.locLabel.text = weatherResp.location.name
                
                self.tempLabel.text = "\(weatherResp.current.temp_c) C°"
                                
                if filtered.count > 0 {
                    self.day_Label.text = "Day: \(filtered[0].day)"
                    self.night_label.text = "Night: \(filtered[0].night)"
                    self.displayWeatherImage(code: weatherResp.current.condition.code)
                }
                
            }
        }else {
            DispatchQueue.main.async {
                self.swith.isEnabled = true
                self.locLabel.text = weatherResp.location.name
                
                self.tempLabel.text = "\(weatherResp.current.temp_f) F°"
                if filtered.count > 0 {
                    self.day_Label.text = "Day: \(filtered[0].day)"
                    self.night_label.text = "Night: \(filtered[0].night)"
                    self.displayWeatherImage(code: weatherResp.current.condition.code)
                }
            }
        }
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
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherConditionsModel: Codable {
    let code : Int
    let day : String
    let night : String
}
   
