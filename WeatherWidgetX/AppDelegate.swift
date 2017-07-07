//
//  AppDelegate.swift
//  WeatherWidgetX
//
//  Created by Jonny on 7/5/17.
//  Copyright © 2017 Jonny. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		refresh()
		
		// refresh every 10 min.
		Timer.scheduledTimer(timeInterval: 10 * 60, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
	}
	
	private struct WeatherURL {
		static var locationName: String {
			get {
				return UserDefaults.standard.string(forKey: "locationName") ?? "长沙"
			}
			set {
				UserDefaults.standard.set(newValue, forKey: "locationName")
			}
		}
		static var weatherID: String {
			get {
				return UserDefaults.standard.string(forKey: "WeatherID") ?? "CN101250101"
			}
			set {
				UserDefaults.standard.set(newValue, forKey: "WeatherID")
			}
		}
		static let key = "bc0418b57b2d4918819d3974ac1285d9"
		static var url: URL {
			return URL(string: "http://guolin.tech/api/weather?cityid=\(weatherID)&key=\(key)")!
		}
	}
	
	private let statusItem: NSStatusItem = {
		let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusItem.button?.title = "WeatherWidgetX"
		
		let menu = NSMenu()
		let refreshItem = NSMenuItem(title: "Refresh", action: #selector(tapRefreshMenuItem), keyEquivalent: "r")
		let exitItem = NSMenuItem(title: "Exit", action: #selector(tapExitMenuItem), keyEquivalent: "q")
		
		menu.addItem(NSMenuItem(title: "Updating", action: nil, keyEquivalent: ""))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(AppDelegate.nationMenuItem)
		menu.addItem(NSMenuItem.separator())
		menu.addItem(refreshItem)
		menu.addItem(exitItem)
		
		statusItem.menu = menu
		
		return statusItem
	}()
	
	private static let nationMenuItem: NSMenuItem = {
		
		let item = NSMenuItem(title: NSLocalizedString("Change City", comment: ""), action: nil, keyEquivalent: "")
		
		let subItems = Nation.shared.provinces.map { province -> NSMenuItem in
			let item = NSMenuItem(title: province.name, action: nil, keyEquivalent: "")
			
			let subItems = province.cities.map { city -> NSMenuItem in
				let item = NSMenuItem(title: city.name, action: nil, keyEquivalent: "")
				let subItems = city.counties.map { CountyMenuItem(county: $0, action: #selector(tapCountyMenuItem)) }
				let menu = NSMenu()
				subItems.forEach(menu.addItem)
				item.submenu = menu
				return item
			}
			
			let menu = NSMenu()
			subItems.forEach(menu.addItem)
			item.submenu = menu
			return item
		}
		
		let menu = NSMenu()
		subItems.forEach(menu.addItem)
		item.submenu = menu
		
		return item
	}()
	
	@objc private func refresh() {
		
		URLSession.shared.dataTask(with: WeatherURL.url) { data, _, error in
			if let data = data {
				do {
					let weathers = try JSONDecoder().decode(Weathers.self, from: data)
					guard let weather = weathers.weathers.last else { return }
					DispatchQueue.main.async {
						self.updateUI(with: weather)
					}
				} catch {
					print(error)
					DispatchQueue.main.async {
						let alert = NSAlert(error: error)
						alert.runModal()
					}
				}
			} else if let error = error {
				print(error)
				DispatchQueue.main.async {
					let alert = NSAlert(error: error)
					alert.runModal()
				}
			}
		}.resume()
	}
	
	private func updateUI(with weather: Weather) {
		
		if let aqi = weather.aqi?.city.aqi, let airQuality = weather.aqi?.city.qlty {
			statusItem.button?.title = " \(weather.now.temperature)°C \(weather.now.more.info), \(aqi) \(airQuality) "
		} else {
			statusItem.button?.title = " \(weather.now.temperature)°C \(weather.now.more.info)"
		}
		
		let forecasts = weather.dailyForecasts.map {
			DateFormatter.localizedString(from: $0.dateComponents!.date!, dateStyle: .medium, timeStyle: .none) + "  " + $0.temperature.min + "°C" + " - " + $0.temperature.max + "°C  " + $0.more.info
		}
		let forecastMenuItems = forecasts.map { NSMenuItem(title: $0, action: #selector(tapGeneralItem), keyEquivalent: "") }
		
		let aqis = [
			"AQI \(weather.aqi?.city.aqi ?? "N/A")",
			"PM2.5 \(weather.aqi?.city.pm25 ?? "N/A")",
			"PM10 \(weather.aqi?.city.pm10 ?? "N/A")",
		]
		let aqiMenuItems = aqis.map { NSMenuItem(title: $0, action: #selector(tapGeneralItem), keyEquivalent: "") }
		
		let menu = statusItem.menu!
		menu.removeAllItems()
		
		var items: [NSMenuItem] = [NSMenuItem(title: WeatherURL.locationName, action: nil, keyEquivalent: ""), NSMenuItem(title: "Updated at " + DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium), action: nil, keyEquivalent: "")]
		
		items += [NSMenuItem.separator()]
		items += forecastMenuItems
		items += [NSMenuItem.separator()]
		items += aqiMenuItems
		items += [NSMenuItem.separator()]
		items += [AppDelegate.nationMenuItem]
		items += [NSMenuItem.separator()]
		items += [NSMenuItem(title: "Refresh", action: #selector(tapRefreshMenuItem), keyEquivalent: "r")]
		items += [NSMenuItem.separator()]
		items += [NSMenuItem(title: "Exit", action: #selector(tapExitMenuItem), keyEquivalent: "q")]
		
		items.forEach(menu.addItem)
	}
	
	@objc private func tapGeneralItem(_ sender: NSMenuItem) {}
	
	@objc private func tapRefreshMenuItem(_ sender: NSMenuItem) {
		refresh()
	}
	
	@objc private func tapExitMenuItem(_ sender: NSMenuItem) {
		NSApp.terminate(self)
	}
	
	@objc private func tapCountyMenuItem(_ sender: CountyMenuItem) {
		WeatherURL.locationName = sender.county.name
		WeatherURL.weatherID = sender.county.weatherID
		refresh()
	}
}


private class CountyMenuItem : NSMenuItem {
	
	let county: County
	
	init(county: County, action: Selector) {
		self.county = county
		super.init(title: county.name, action: action, keyEquivalent: "")
	}
	
	required init(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

