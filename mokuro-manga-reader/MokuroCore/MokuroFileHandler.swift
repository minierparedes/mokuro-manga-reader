//
//  MokuroFileHandler.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation

class MokuroFileHandler {
    static func loadMokuroData(from fileURL: URL) -> MokuroData? {
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: fileURL)
            let decodedData = try decoder.decode(MokuroData.self, from: data)
            return decodedData
        } catch {
            print("Error decoding JSON: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    print("Missing key: \(key.stringValue)")
                default:
                    print("Decoding error: \(decodingError)")
                }
            }
            return nil
        }
    }
}
