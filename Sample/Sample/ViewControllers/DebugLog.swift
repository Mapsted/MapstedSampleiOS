//
//  DebugLog.swift
//  Sample
//
//  Created by joseph on 2023-08-30.
//  Copyright © 2023 Mapsted. All rights reserved.
//

import Foundation

class DebugLog {
	func Log(_ message: String, _ object: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {

			var filename = (file as NSString).lastPathComponent
			filename = filename.components(separatedBy: ".")[0]

			let currentDate = Date()
			let df = DateFormatter()
			df.dateFormat = "HH:mm:ss.SSS"

			print("──────────────────────────────────────────────────────────────────────────────────")
			print("\(message) | \(df.string(from: currentDate)) │ \(filename).\(function) (\(line))  ")
			print("──────────────────────────────────────────────────────────────────────────────────")
			print("\(String(describing: object))\n")
	}
}
