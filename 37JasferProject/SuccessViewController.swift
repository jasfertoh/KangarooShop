//
//  SuccessViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 8/11/21.
//

import UIKit
import CoreLocation
import CoreData

class SuccessViewController: UIViewController {
    
    var addressList = [Address]()
    var currentTemperature: String? = nil
    var currentDescription: String? = nil
    var currentDeliveryMethod: String? = nil
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    let apiKey = "6a41f9f75a78a130cc8d6a222f0245ba"
    
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var acknowledgeBtn: UIButton!
    @IBOutlet weak var deliveryMethod: UILabel!
    @IBOutlet weak var deliveryAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = app.persistentContainer.viewContext
        acknowledgeBtn.layer.cornerRadius = 6
        acknowledgeBtn.isEnabled = false
        checkUserAddress()
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func acknowledgePressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
    
    func checkUserAddress() {
        // get the default user address and pass it to the get coordinates function
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("No user found.")
            } else {
                for item in data {
                    let decoder = JSONDecoder()
                    let decodedItem = try decoder.decode([Address].self, from: item.address!)
                    addressList = decodedItem
                    for i in 0..<addressList.count {
                        for (key, value) in addressList[i].addressList {
                            if value {
                                userAddress.text = "\(key)"
                                getCoordinates(address: key)
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getCoordinates(address: String) { // get postal code from the default address provided
        let shortAdd = address.split(separator: "\n")[2]
        let postalCode = shortAdd.split(separator: " ")[1]
        let oneMapURL = URL(string: "https://developers.onemap.sg/commonapi/search?searchVal=\(postalCode)&returnGeom=Y&getAddrDetails=Y&pageNum=1")
        guard let url = oneMapURL else {
            print(oneMapURL)
            return
        } // get the coordinates from the postal code.
        let firstTask = URLSession.shared.dataTask(with: oneMapURL!) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            var result: OneMapData?
            do {
                result = try JSONDecoder().decode(OneMapData.self, from: data)
            } catch {
                print(error)
            }
            
            guard let json = result else {
                print("error!")
                return
            }
            print(json.results[0].LATITUDE)
            print(json.results[0].LONGITUDE)
            self.requestWeatherData(lat: CLLocationDegrees(json.results[0].LATITUDE)!, lon: CLLocationDegrees(json.results[0].LONGITUDE)!)
            
        }
        
        firstTask.resume()
    }
    
    func requestWeatherData(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        // get weather data from the coordinates obtained from converting the postal code.
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)")
        
        let task = URLSession.shared.dataTask(with: weatherURL!) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            var result: WeatherData?
            do {
                result = try JSONDecoder().decode(WeatherData.self, from: data)
            } catch {
                print(error)
            }
            
            guard let json = result else {
                return
            }
            print(json.weather[0].description)
            self.currentTemperature = "\(json.main.temp)°C"
            self.currentDescription = json.weather[0].main
            if self.currentDescription == "Rain" {
                self.currentDeliveryMethod = "NEXT-DAY DELIVERY"
            } else {
                self.currentDeliveryMethod = "SAME-DAY DELIVERY"
            }
            
            DispatchQueue.main.async {
                
                // set the label text to its respective values.
                self.deliveryMethod.text = self.currentDeliveryMethod
                self.weatherTemp.text = self.currentTemperature
                self.weatherType.text = self.currentDescription
                self.acknowledgeBtn.isEnabled = true
            }
        }
        
        
        task.resume()
        
    }
    
}
