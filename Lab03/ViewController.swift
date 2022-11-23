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
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var locLabel: UILabel!
    
    @IBOutlet weak var day_Label: UILabel!
    
    @IBOutlet weak var night_label: UILabel!
    
    var searchLocationText: String = ""
    
    var results:[WeatherConditionsModel] = []
    
    var weatherResponseGlobal : WeatherResponse? = nil
    
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
                            self.results = response
                        }
                        return
                    }
                }
            }.resume()
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
        if flag {
            DispatchQueue.main.async {
                self.locLabel.text = weatherResp.location.name
                
                self.tempLabel.text = "\(weatherResp.current.temp_c) C°"
            }
        }else {
            DispatchQueue.main.async {
                self.locLabel.text = weatherResp.location.name
                
                self.tempLabel.text = "\(weatherResp.current.temp_f) F°"
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
   
