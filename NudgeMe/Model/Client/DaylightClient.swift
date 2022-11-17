//
//  DaylightClient.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation

class DaylightClient {
    
    enum Endpoint {
        
        case daylightInfo(Double, Double)
        static let baseUrl = "https://api.sunrise-sunset.org/json?"
        
        var stringValue: String {
            switch self {
            case .daylightInfo(let latitude, let longitude):
                return Endpoint.baseUrl + "&lat=\(latitude)&lon=\(longitude)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getDaylightHours(latitude: Double, longitude: Double, completionHandler: @escaping (APIResponse?, Error?) -> Void) {
        let url = Endpoint.daylightInfo(latitude, longitude).url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            //debugPrint(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(APIResponse.self, from: data)
                //debugPrint(response)
                DispatchQueue.main.async {
                    completionHandler(response, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
        
}
    



