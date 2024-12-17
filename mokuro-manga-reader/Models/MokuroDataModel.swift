//
//  MokuroDataModel.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import CoreGraphics
import SwiftUI

// Extend CGPoint to make it hashable for usage in sets or as dictionary keys
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

// Decode each coordinate as a CGPoint
extension CGPoint {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let coords = try container.decode([Double].self)
        guard coords.count == 2 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid number of coordinates")
        }
        self.init(x: coords[0], y: coords[1])
    }
}

// Define a structure for each "block" that contains the text and its properties
struct MokuroBlock: Identifiable, Hashable, Codable {
    var id = UUID() // Unique ID for each block
    var box: [CGFloat] // [x1, y1, x2, y2] for bounding box of the block
    var vertical: Bool // Whether the text is vertical
    var fontSize: CGFloat // The font size
    var linesCoords: [[[CGPoint]]] // Coordinates for each line of text
    var lines: [String] // The text content for each block
    
    // Custom keys for coding and decoding if needed
    enum CodingKeys: String, CodingKey {
        case box
        case vertical
        case fontSize = "font_size"
        case linesCoords = "lines_coords"
        case lines
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Ensure all stored properties are initialized
        self.box = try container.decode([CGFloat].self, forKey: .box)
        self.vertical = try container.decode(Bool.self, forKey: .vertical)
        self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        self.lines = try container.decode([String].self, forKey: .lines)
        
        let rawLinesCoords = try container.decode([[[CGFloat]]].self, forKey: .linesCoords)
        
        self.linesCoords = rawLinesCoords.map { line in
            line.compactMap { pair -> [CGPoint]? in
                guard pair.count == 2 else { return nil }
                return [CGPoint(x: pair[0], y: pair[1])]
            }
        }
    }
}

enum VerticalAlignment {
    case top
    case center
    case bottom
}

extension MokuroBlock {
    func getOverlayPosition(in imgSize: CGSize) -> CGPoint {
        // Calculate scaling factors based on image size
        let scaleX = imgSize.width / (box[2] - box[0])
        let scaleY = imgSize.height / (box[3] - box[1])

        // Calculate the center point of the scaled bounding box
        let centerX = (box[0] + box[2]) / 2 * scaleX
        let centerY = (box[1] + box[3]) / 2 * scaleY

        return CGPoint(x: centerX, y: centerY)
    }
}

struct Page: Hashable, Codable{
    var version: String
    var imgWidth: CGFloat
    var imgHeight: CGFloat
    var blocks: [MokuroBlock]
    var imgPath: String?
    
    enum CodingKeys: String, CodingKey {
        case version
        case imgWidth = "img_width"
        case imgHeight = "img_height"
        case blocks
        case imgPath = "img_path"
    }
}

// Define the main MokuroData model that will hold the entire data
struct MokuroData: Codable {
    var version: String
    var title: String
    var titleUUID: String
    var volume: String
    var volumeUUID: String
    var pages: [Page] // Array of pages in the mokuro file

    // Mapping keys for decoding to ensure proper translation
    enum CodingKeys: String, CodingKey {
        case version
        case title
        case titleUUID = "title_uuid"
        case volume
        case volumeUUID = "volume_uuid"
        case pages
    }
}
