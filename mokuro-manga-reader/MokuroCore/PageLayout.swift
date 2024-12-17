//
//  PageLayout.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import SwiftUI

struct PageLayout: Layout {
    var imgWidth: CGFloat
    var imgHeight: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Calculate dimensions while maintaining the image's aspect ratio
        let aspectRatio = imgHeight / imgWidth
        let proposedWidth = proposal.width ?? imgWidth
        let proposedHeight = proposedWidth * aspectRatio

        return CGSize(width: proposedWidth, height: proposedHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let scaleX = bounds.width / imgWidth
        let scaleY = bounds.height / imgHeight
        
        // Additional Y-offset to shift overlays downward
        let yOffset: CGFloat = 130  // Adjust this value as needed
        
        for (index, subview) in subviews.enumerated() {
            guard let block = subview[BlockLayoutKey.self] else {
                print("[placeSubviews] Subview \(index + 1) missing BlockLayoutKey.")
                continue
            }

            // Scale the block's bounding box for both X and Y
            let scaledBox = CGRect(
                x: block.box[0] * scaleX,
                y: (block.box[1] * scaleY) + yOffset,  // Apply the Y offset here
                width: (block.box[2] - block.box[0]) * scaleX,
                height: (block.box[3] - block.box[1]) * scaleY
            )

            // Position the subview based on the scaled bounding box
            subview.place(
                at: CGPoint(x: scaledBox.midX, y: scaledBox.midY),
                anchor: .center,
                proposal: ProposedViewSize(width: scaledBox.width, height: scaledBox.height)
            )
        }
    }
    func calculateYOffset(blocks: [MokuroBlock], scaleY: CGFloat) -> CGFloat {
        guard !blocks.isEmpty else { return 0 }

        // Calculate the average or minimum Y-coordinate of all blocks
        let minY = blocks.map { $0.box[1] }.min() ?? 0
        return minY * scaleY * 0.1 // Scale and adjust dynamically
    }

}
