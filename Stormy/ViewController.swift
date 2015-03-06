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
    

    
    
    // API key is for debug and now defunct. Sorry request pirates!
    private let apiKey = "b18e971e431697969a866523bdbed2a0"

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshActivityIndicator.hidden = true
        getCurrentWeatherData()
        

    } // end viewDidLoad
    
    func getCurrentWeatherData() -> Void {
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "33.830441,-118.307169", relativeToURL: baseURL)
        
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
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                networkIssueController.addAction(cancelButton)
                
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

    } // end getCurrentWeatherData
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //did update locations
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // Unable to find location. Add an alert with button to tell the user
        let locationIssueController: UIAlertController = UIAlertController(title: "Unable to find location", message: "Sorry! We were unable to get your location", preferredStyle: .Alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        locationIssueController.addAction(dismissButton)
        
    }
    
    
    
    func getLocation() {
        // Get user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    @IBAction func refreshButton() {
        
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

