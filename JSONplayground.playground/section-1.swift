// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let apiKey = "b18e971e431697969a866523bdbed2a0"

let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
let forecastURL = NSURL(string: "33.830441,-118.307169", relativeToURL: baseURL)

let weatherData = NSData(contentsOfURL: forecastURL!, options: nil, error: nil)

