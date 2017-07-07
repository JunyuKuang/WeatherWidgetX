//
//  Weather.swift
//  WeatherWidgetX
//
//  Created by Jonny on 7/6/17.
//  Copyright © 2017 Jonny. All rights reserved.
//

import Foundation

//struct AQI : Codable {
//
//	struct Data : Codable {
//		let aqi: Int
//	}
//
//	let data: Data
//	let status: String
//}
//

struct Weathers : Codable {
	let weathers: [Weather]
	private enum CodingKeys : String, CodingKey {
		case weathers = "HeWeather"
	}
}

struct Weather : Codable {
	
	let status: String
	let basic: Basic
	let aqi: AQI?
	let now: Now
	let suggestion: Suggestion
	let dailyForecasts: [Forecast]
	
	private enum CodingKeys : String, CodingKey {
		case status
		case basic
		case aqi
		case now
		case suggestion
		case dailyForecasts = "daily_forecast"
	}
	
	struct Basic : Codable {
		let city: String
		let id: String
		let update: Update
		
		struct Update : Codable {
			let updateTime: String
			private enum CodingKeys : String, CodingKey {
				case updateTime = "loc"
			}
		}
	}
	
	struct AQI : Codable {
		let city: City
		
		struct City : Codable {
			let aqi: String?
			let pm10: String?
			let pm25: String?
			let co: String?
			let no2: String?
			let o3: String?
			let so2: String?
			let qlty: String?
			
			var quality : String? {
				guard let aqi = aqi, let intValue = Int(aqi) else { return "" }
				switch intValue {
				case 0...50:
					return "Excellent"
				case 51...100:
					return "Good"
				case 101...150:
					return "Lightly Polluted"
				case 151...200:
					return "Moderately Polluted"
				case 201...300:
					return "Heavily Polluted"
				case 301...500:
					return "Severely Polluted"
				default:
					return ""
				}
			}
		}
	}
	
	struct Now : Codable {
		let temperature: String
		let more: More
		private enum CodingKeys : String, CodingKey {
			case temperature = "tmp"
			case more = "cond"
		}
		
		struct More : Codable {
			let info: String
			private enum CodingKeys : String, CodingKey {
				case info = "txt"
			}
		}
	}
	
	struct Suggestion : Codable {
		let comfort: Comfort
		let carWash: Carwash
		let sport: Sport
		
		private enum CodingKeys : String, CodingKey {
			case comfort = "comf"
			case carWash = "cw"
			case sport
		}
		
		struct Comfort : Codable {
			let info: String
			private enum CodingKeys : String, CodingKey {
				case info = "txt"
			}
		}
		
		struct Carwash : Codable {
			let info: String
			private enum CodingKeys : String, CodingKey {
				case info = "txt"
			}
		}
		
		struct Sport : Codable {
			let info: String
			private enum CodingKeys : String, CodingKey {
				case info = "txt"
			}
		}
	}
	
	struct Forecast : Codable {
		private let dateString: String
		let temperature: Temperature
		let more: More
		
		private enum CodingKeys : String, CodingKey {
			case dateString = "date"
			case temperature = "tmp"
			case more = "cond"
		}
		
		struct Temperature : Codable {
			let max: String
			let min: String
		}
		
		struct More : Codable {
			let info: String
			private enum CodingKeys : String, CodingKey {
				case info = "txt_d"
			}
		}
		
		var dateComponents: DateComponents? {
			let components = dateString.components(separatedBy: "-")
			guard components.count == 3 else { return nil }
			
			guard let year = Int(components[0]),
				let month = Int(components[1]),
				let day = Int(components[2]) else { return nil }
			
			return DateComponents(calendar: Calendar(identifier: .gregorian),
			                      timeZone: TimeZone(abbreviation: "Asia/Hong_Kong"),
			                      year: year,
			                      month: month,
			                      day: day)
		}
	}
}




