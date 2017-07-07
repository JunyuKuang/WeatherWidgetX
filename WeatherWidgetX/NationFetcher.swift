////
////  NationFetcher.swift
////  WeatherWidgetX
////
////  Created by Jonny on 7/7/17.
////  Copyright © 2017 Jonny. All rights reserved.
////
//
//import Foundation
//
//
//static func fetch(handler: @escaping (Nation?, Error?) -> Void) {
//
//	var nation = Nation(provinces: [])
//
//	WeatherWidgetX.Province.fetchProvinces { provinces, error in
//		if let provinces = provinces {
//			nation.provinces = provinces.map { Province(id: $0.id, name: $0.name, cities: []) }
//			for i in 0 ..< provinces.count {
//				let province = provinces[i]
//				WeatherWidgetX.City.fetchCities(withProvince: province, handler: { (cities, error) in
//					if let cities = cities {
//						nation.provinces[i].cities = cities.map { City(id: $0.id, name: $0.name, counties: []) }
//						for j in 0 ..< cities.count {
//							let city = cities[j]
//							WeatherWidgetX.County.fetchCounties(withProvince: province, city: city, handler: { (counties, error) in
//								if let counties = counties {
//									nation.provinces[i].cities[j].counties = counties.map { County(id: $0.id, name: $0.name, weatherID: $0.weatherID) }
//								} else if let error = error {
//									print(error)
//								}
//							})
//						}
//					} else if let error = error {
//						print(error)
//					}
//				})
//			}
//		} else if let error = error {
//			print(error)
//		}
//	}
//
//	DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//		handler(nation, nil)
//
//		assert(!nation.provinces.isEmpty)
//		for province in nation.provinces {
//			assert(!province.cities.isEmpty)
//			for city in province.cities {
//				assert(!city.counties.isEmpty)
//			}
//		}
//
//		let json = try! JSONEncoder().encode(nation)
//		let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).last!.appendingPathComponent("Nation.json", isDirectory: false)
//		try! json.write(to: url)
//	}
//}
//
//
//struct Province : Codable {
//	let id: Int
//	let name: String
//
//	static func fetchProvinces(handler: @escaping ([Province]?, Error?) -> Void) {
//		let url = URL(string: "http://guolin.tech/api/china")!
//		URLSession.shared.dataTask(with: url) { data, _, error in
//			if let data = data {
//				do {
//					let provinces = try JSONDecoder().decode([Province].self, from: data)
//					handler(provinces, nil)
//				} catch {
//					handler(nil, error)
//				}
//			} else if let error = error {
//				handler(nil, error)
//			}
//			}.resume()
//	}
//}
//
//struct City : Codable {
//	let id: Int
//	let name: String
//
//	static func fetchCities(withProvince province: Province, handler: @escaping ([City]?, Error?) -> Void) {
//		let url = URL(string: "http://guolin.tech/api/china/\(province.id)")!
//		URLSession.shared.dataTask(with: url) { data, _, error in
//			if let data = data {
//				do {
//					let cities = try JSONDecoder().decode([City].self, from: data)
//					handler(cities, nil)
//				} catch {
//					handler(nil, error)
//				}
//			} else if let error = error {
//				handler(nil, error)
//			}
//			}.resume()
//	}
//}
//
//struct County : Codable {
//	let id: Int
//	let name: String
//	let weatherID: String
//
//	private enum CodingKeys : String, CodingKey {
//		case id, name, weatherID = "weather_id"
//	}
//
//	static func fetchCounties(withProvince province: Province, city: City, handler: @escaping ([County]?, Error?) -> Void) {
//		let url = URL(string: "http://guolin.tech/api/china/\(province.id)/\(city.id)")!
//		URLSession.shared.dataTask(with: url) { data, _, error in
//			if let data = data {
//				do {
//					let counties = try JSONDecoder().decode([County].self, from: data)
//					handler(counties, nil)
//				} catch {
//					handler(nil, error)
//				}
//			} else if let error = error {
//				handler(nil, error)
//			}
//			}.resume()
//	}
//}

