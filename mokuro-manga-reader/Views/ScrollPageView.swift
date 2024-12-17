//
//  ScrollPageView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import SwiftUI

struct ScrollPageView: View {
    var pages: [Page]

    var body: some View {
        TabView {
            ForEach(pages, id: \.self) { page in
                PageView(page: page)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .ignoresSafeArea() // For fullscreen presentation
    }
}
