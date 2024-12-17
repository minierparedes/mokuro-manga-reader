//
//  PageView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import SwiftUI

struct PageView: View {
    var page: Page

    var resolvedImagePath: String? {
        if let imgPath = page.imgPath?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let normalizedPath = imgPath.replacingOccurrences(of: ".PNG", with: ".png")
            let imagePath = "01幼稚園Wars/\(imgPath)" + (imgPath.hasSuffix(".jpg") ? "" : ".jpg")
            return Bundle.main.url(forResource: imagePath, withExtension: nil)?.path
        }
        return nil
    }

    var body: some View {
        ZStack(alignment: .center) {
            // Display the image
            if let resolvedPath = resolvedImagePath {
                Image(uiImage: UIImage(contentsOfFile: resolvedPath) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .layoutPriority(1) // Ensure image gets priority in layout
                    .onAppear {
                        logResolvedImagePath(resolvedPath: resolvedPath)
                    }
            } else {
                Text("Image not found")
                    .foregroundColor(.red)
                    .onAppear {
                        logError("Image not found for page.")
                    }
            }

            // Overlay layout using PageLayout
            PageLayout(imgWidth: CGFloat(page.imgWidth), imgHeight: CGFloat(page.imgHeight)) {
                if page.blocks.isEmpty {
                    Text("No overlay blocks available")
                        .foregroundColor(.gray)
                        .onAppear {
                            logError("No overlay blocks found.")
                        }
                } else {
                    ForEach(page.blocks) { block in
                        TategakiText(text: block.lines.joined(separator: "\n"))
                            .font(.system(size: block.fontSize))
                            .layoutValue(key: BlockLayoutKey.self, value: block)
                            .onAppear {
                                logBlockDetails(block: block)
                            }
                    }
                }
            }
        }
    }

    // Helper function for logging the resolved image path
    private func logResolvedImagePath(resolvedPath: String) {
        print("[PageView] Resolved Image Path: \(resolvedPath)")
    }

    // Helper function for logging errors
    private func logError(_ message: String) {
        print("[Error] \(message)")
    }

    // Helper function for logging block details
    private func logBlockDetails(block: MokuroBlock) {
        print("""
        [Block]
        Lines: \(block.lines.joined(separator: " "))
        Font Size: \(block.fontSize)
        Box: \(block.box)
        """)
    }
}
