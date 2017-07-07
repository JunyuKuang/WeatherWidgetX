//
//  City.swift
//  WeatherWidgetX
//
//  Created by Jonny on 7/7/17.
//  Copyright © 2017 Jonny. All rights reserved.
//

import Foundation

struct Nation : Codable {
	let provinces: [Province]
	
	static let shared: Nation = {
//		let url = Bundle.main.url(forResource: "Nation", withExtension: "json")!
//		let jsonData = try! Data(contentsOf: url)
		let jsonData = nationJSON.data(using: .utf8)!
		return try! JSONDecoder().decode(Nation.self, from: jsonData)
	}()
}

struct Province : Codable {
	let id: Int
	let name: String
	let cities: [City]
}

struct City : Codable {
	let id: Int
	let name: String
	let counties: [County]
}

struct County : Codable {
	let id: Int
	let name: String
	let weatherID: String
}
