//
//  ViewController.swift
//  Stormy
//
//  Created by Ben Junya on 3/3/15.
//  Copyright (c) 2015 Prism-Mobile. All rights reserved.
//

import UIKit
import CoreLocation;

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    var oldLocation: Location = Location(lat: 0, lng: 0)
    var newLocation: Location = Location(lat: 100, lng: 100)

    
    
    // API key is for debug and now defunct. Sorry request pirates!
    private let apiKey = "b18e971e431697969a866523bdbed2a0"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshActivityIndicator.hidden = true
        
        // check for authorization status for view
        while (!askforLocationPermission()) {
            
            if(askforLocationPermission()) {
                getLocation()
                getCurrentWeatherData()
            }
            else {
                askforLocationPermission()
            }
        }
        
        

    } // end viewDidLoad
    
    func getCurrentWeatherData() -> Void {
        
        // Check for new location
        if (newLocation.lat != oldLocation.lat && newLocation.lng != oldLocation.lng) {
            // Set new location as the old location
            oldLocation.lat = newLocation.lat
            oldLocation.lng = newLocation.lng
            
            let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
            let forecastURL = NSURL(string: "\(newLocation.lat),\(newLocation.lng)", relativeToURL: baseURL)
            
            let sharedSession = NSURLSession.sharedSession()
            let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                
                if (error == nil) {
                    
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                    
                    let currentWeather = Current(weatherDictionary: weatherDictionary)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.temperatureLabel.text = "\(currentWeather.temperature)"
                        self.iconView.image = currentWeather.icon!
                        self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                        self.humidityLabel.text = "\(currentWeather.humidity)"
                        self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                        self.summaryLabel.text = "\(currentWeather.summary)"
                        
                        // Stop animation
                        self.refreshActivityIndicator.stopAnimating()
                        self.refreshActivityIndicator.hidden = true
                        self.refresh.hidden = false
                        
                    }) // end dispatch_async closure
                    
                } // end if
                else {
                    let networkIssueController: UIAlertController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .Alert)
                    
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    networkIssueController.addAction(okButton)
                    
                    self.presentViewController(networkIssueController, animated: true, completion: nil)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                    // Stop animation
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                    self.refresh.hidden = false
                        
                    }) // end dispatch_async closure
                    
                } // end Else
                
                
            }) // end downloadTask closure
            
            downloadTask.resume()
        }
            
        else {
            //Locations are the same. Don't make an API call
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.refreshActivityIndicator.stopAnimating()
                self.refreshActivityIndicator.hidden = true
                self.refresh.hidden = false
            })
        }
        
        
        
        

    } // end getCurrentWeatherData
    
    // There's 2 locationManager functions because each one is a delegate. One is successful in updating location(didUpdateLocations). The other is when there's an error in that process and shows an Alert message(didFailWithError)
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //did update locations
        // The code fires when we new location updates are available

        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                println("Reverse geocoder failed with error " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            }
            
            else {
                // Display error message
            }
            
        }) // end CLGeocoder closure
        
    } // end locationManager - didUpdateLocations delegate
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // Unable to find location. Add an alert with button to tell the user
        
        println("locationManager is running with didUpdateLocations)")
        
        let locationIssueController: UIAlertController = UIAlertController(title: "Unable to find location", message: "Sorry! We were unable to get your location", preferredStyle: .Alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        locationIssueController.addAction(dismissButton)
        
        self.presentViewController(locationIssueController, animated: true, completion: nil)
        
    } // end locationManager - didFailWithError delegate
    
    
    
    func displayLocationInfo(placemark: CLPlacemark) {
        // Stop updating the location
        
        locationManager.stopUpdatingLocation()
        locationLabel.text = placemark.locality + ", " + placemark.administrativeArea
        newLocation = Location(lat: placemark.location.coordinate.latitude, lng: placemark.location.coordinate.longitude)

        
    }
    
    
    
    func getLocation() {
        // Get user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func askforLocationPermission() -> Bool {
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return true
        }
            
        else if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
            return true
        }
        else {
            return false
        }
    }
    
    
    
    @IBAction func refreshButton() {
        
        getLocation()
        getCurrentWeatherData()
        
        refresh.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

