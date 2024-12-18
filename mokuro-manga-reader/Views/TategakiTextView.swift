//
//  TategakiTextView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import SwiftUI
import UIKit

public class TategakiTextView: UIView {
    public var text: String? = nil {
        didSet {
            ctFrame = nil
        }
    }
    
    private var ctFrame: CTFrame? = nil
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Flip the context to handle vertical text properly
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.height)
        
        // Function to calculate the max font size that fits within the rect
        func getMaxFontSizeThatFits(rect: CGRect, text: String) -> CGFloat {
            let testFontSize: CGFloat = 25  // Start with a standard font size
            var font = UIFont(name: "HiraginoSans-W3", size: testFontSize) ?? UIFont.systemFont(ofSize: testFontSize)
            
            var fontSize: CGFloat = testFontSize
            var textBoundingRect: CGRect
            
            repeat {
                // Measure the size of the text
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                textBoundingRect = attributedText.boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                                                               options: .usesLineFragmentOrigin,
                                                               context: nil)
                // If the text is too big, reduce the font size
                fontSize -= 1
                font = UIFont(name: "HiraginoSans-W3", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            } while textBoundingRect.height > rect.height // Ensure it fits within the rect's height
            
            return fontSize
        }
        
        // Get the maximum font size that fits the rect
        let fontSize = getMaxFontSizeThatFits(rect: rect, text: text ?? "")
        
        // Define the attributes for the text with the computed font size
        let font = UIFont(name: "HiraginoSans-W3", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .verticalGlyphForm: true // Ensures vertical text rendering
        ]
        
        // Create attributed string
        let attributedText = NSMutableAttributedString(string: text ?? "", attributes: baseAttributes)
        
        // Create the framesetter
        let setter = CTFramesetterCreateWithAttributedString(attributedText)
        
        // Create a path for the text frame
        let path = CGPath(rect: rect, transform: nil)
        
        // Frame attributes for right-to-left vertical text progression
        let frameAttrs = [
            kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue,
        ]
        
        // Create the frame with framesetter and path
        let ctFrame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, frameAttrs as CFDictionary)
        
        // Draw the frame (the actual text)
        CTFrameDraw(ctFrame, context)
        
        // Optionally, add a border around the rect for debugging
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2)
        context.stroke(rect)
    }

}

public struct TategakiText: UIViewRepresentable {
    public var text: String?
    
    public func makeUIView(context: Context) -> TategakiTextView {
        let uiView = TategakiTextView()
        uiView.isOpaque = false
        uiView.text = text
        return uiView
    }
    
    public func updateUIView(_ uiView: TategakiTextView, context: Context) {
        uiView.text = text
    }
}
