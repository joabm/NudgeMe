//
//  APIResponse.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation

struct APIResponse: Codable {
    let results: [Daylight]
}

struct Daylight: Codable {
    let sunrise: String
    let sunset: String
}
