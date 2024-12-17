//
//  ContentView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//
import SwiftUI

struct ContentView: View {
    @State private var tokenizer = Tokenizer()
    @State private var inputText = ""
    @State private var tokens: [Token] = []
    
    var body: some View {
        VStack {
            // Input area
            TextField("Text to tokenize...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Tokenize!") {
                tokenize()
            }
            .buttonStyle(.borderedProminent)
            
            // Token list
            List(tokens, id: \.surface) { token in
                VStack(alignment: .leading) {
                    Text(token.surface)
                        .font(.headline)
                    
                    // Secondary information
                    VStack(alignment: .leading, spacing: 4) {
                        if let kana = token.kana {
                            Text("仮名: \(kana)")
                                .font(.caption)
                        }
                        
                        if let pronunciation = token.pronunciation {
                            Text("発音: \(pronunciation)")
                                .font(.caption)
                        }
                        
                        if let lemma = token.lemma {
                            Text("語彙素: \(lemma)")
                                .font(.caption)
                        }
                        
                        if let inflection = token.inflection {
                            Text("活用形: \(inflection)")
                                .font(.caption)
                        }
                        
                        if !token.partsOfSpeech.isEmpty {
                            Text("品詞: \(token.partsOfSpeech.joined(separator: "、"))")
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
    
    private func tokenize() {
        tokens = tokenizer.parse(inputText)
    }
}


#Preview {
    ContentView()
}
