//
//  MokuroUtils.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import CoreGraphics

struct MokuroUtils {
    // Load mokuro data
    static func loadMokuroData(fileName: String) -> MokuroData? {
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mokuro") {
            return MokuroFileHandler.loadMokuroData(from: fileURL)
        }
        return nil
    }
    
    // Scale the block box coordinates based on page size
    static func scaleBox(_ box: [CGFloat], scaleX: CGFloat, scaleY: CGFloat) -> CGRect {
        let x = box[0] * scaleX
        let y = box[1] * scaleY
        let width = (box[2] - box[0]) * scaleX
        let height = (box[3] - box[1]) * scaleY
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
