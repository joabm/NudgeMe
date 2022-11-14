//
//  ErrorResponse.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/14/22.
//

import Foundation

struct ErrorResponse: Codable {
    let status: String
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
