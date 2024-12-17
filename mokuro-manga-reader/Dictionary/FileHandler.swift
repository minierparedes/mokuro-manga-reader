//
//  FileHandler.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import ZIPFoundation

class FileHandler {
    // Function to unzip a file from sourceURL to a temporary directory using ZipFoundation
    static func unzipFile(at sourceURL: URL) -> URL? {
        // Destination URL in the temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let destinationURL = tempDirectory.appendingPathComponent(UUID().uuidString) // Unique subfolder

        // Create the destination directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating destination directory: \(error)")
            return nil
        }
        
        // Unzip the file to the destination URL using ZIPFoundation
        do {
            let archive = try Archive(url: sourceURL, accessMode: .read)
            for entry in archive {
                let entryURL = destinationURL.appendingPathComponent(entry.path)
                
                // Create intermediate directories if needed
                if entry.type == .directory {
                    try FileManager.default.createDirectory(at: entryURL, withIntermediateDirectories: true, attributes: nil)
                } else {
                    // Ensure the directory exists before extracting
                    try FileManager.default.createDirectory(at: entryURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    
                    // Extract the file
                    try archive.extract(entry, to: entryURL)
                }
            }
            return destinationURL // Return the path of the unzipped folder
        } catch {
            print("Error unzipping file: \(error)")
            return nil
        }
    }

    // Function to load JSON data from the unzipped folder
    static func loadJSONData(from directoryURL: URL) -> Data? {
        do {
            // Recursively search for JSON files in the directory
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
            
            while let fileURL = enumerator?.nextObject() as? URL {
                if fileURL.pathExtension.lowercased() == "json" {
                    return try Data(contentsOf: fileURL)
                }
            }
            
            print("No JSON file found in the unzipped folder.")
            return nil
        } catch {
            print("Error reading directory or JSON file: \(error)")
            return nil
        }
    }
}

