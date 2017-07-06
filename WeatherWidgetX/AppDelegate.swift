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
	
	private struct WeatherURL {
		// Current City ID is for Changsha, China. For more IDs please visit http://guolin.tech
		private static let cityID = "CN101250101"
		private static let key = "bc0418b57b2d4918819d3974ac1285d9"
		static let url = URL(string: "http://guolin.tech/api/weather?cityid=\(cityID)&key=\(key)")!
	}
	
	private let statusItem: NSStatusItem = {
		let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		statusItem.button?.title = "AQI"
		
		let menu = NSMenu()
		let refreshItem = NSMenuItem(title: "Refresh", action: #selector(tapRefreshMenuItem), keyEquivalent: "R")
		let exitItem = NSMenuItem(title: "Exit", action: #selector(tapExitMenuItem), keyEquivalent: "Q")
		menu.addItem(refreshItem)
		menu.addItem(exitItem)
		statusItem.menu = menu
		
		return statusItem
	}()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		refresh()
		Timer.scheduledTimer(timeInterval: 10 * 60, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
	}
	
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
		statusItem.button?.title = " " + weather.now.temperature + "°C" + ", " + weather.aqi.city.aqi + " " + weather.aqi.city.quality + " "
		
		let forecasts = weather.dailyForecasts.map {
			DateFormatter.localizedString(from: $0.dateComponents!.date!, dateStyle: .medium, timeStyle: .none) + "  " + $0.temperature.min + "°C" + " - " + $0.temperature.max + "°C  " + $0.more.info
		}
		let forecastMenuItems = forecasts.map { NSMenuItem(title: $0, action: #selector(tapGeneralItem), keyEquivalent: "") }
		
		let aqis = [
			"AQI " + weather.aqi.city.aqi,
			"PM2.5 " + weather.aqi.city.pm25,
			"PM10 " + weather.aqi.city.pm10,
		]
		let aqiMenuItems = aqis.map { NSMenuItem(title: $0, action: #selector(tapGeneralItem), keyEquivalent: "") }
		
		let menu = NSMenu()
		let items
			= [NSMenuItem(title: "Updated at " + DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium), action: nil, keyEquivalent: "")]
			+ [NSMenuItem.separator()]
			+ forecastMenuItems
			+ [NSMenuItem.separator()]
			+ aqiMenuItems
			+ [NSMenuItem.separator()]
			+ [NSMenuItem(title: "Refresh", action: #selector(tapRefreshMenuItem), keyEquivalent: "R"),
			   NSMenuItem(title: "Exit", action: #selector(tapExitMenuItem), keyEquivalent: "Q")]
		
		items.forEach(menu.addItem)
		statusItem.menu = menu
	}
	
	@objc private func tapGeneralItem(_ sender: NSMenuItem) {}
	
	@objc private func tapRefreshMenuItem(_ sender: NSMenuItem) {
		refresh()
	}
	
	@objc private func tapExitMenuItem(_ sender: NSMenuItem) {
		NSApp.terminate(self)
	}
}

