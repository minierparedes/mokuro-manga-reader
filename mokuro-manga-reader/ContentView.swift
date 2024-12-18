//
//  ContentView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import SwiftUI

struct ContentView: View {
    @State private var tokenizer = Tokenizer()
    @State private var dictionary: JMdictDictionary = JMdictDictionary() // Populate this with your JMdict data
    @State private var matcher: MecabJMdictTokenMatcher?
    @State private var inputText = ""
    @State private var tokens: [(token: Token, matches: [JMdictEntry])] = []
    
    var body: some View {
        VStack {
            // Input area
            TextField("Text to tokenize...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Tokenize and Match!") {
                performTokenizeAndMatch()
            }
            .buttonStyle(.borderedProminent)
            
            // Token list
            tokenListView
        }
        .padding()
        .onAppear(perform: initializeMatcher)
    }
    
    // Separate view for token list to reduce complexity
    private var tokenListView: some View {
        List {
            ForEach(tokens.indices, id: \.self) { index in
                tokenMatchView(for: tokens[index])
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // View for individual token match
    private func tokenMatchView(for tokenMatch: (token: Token, matches: [JMdictEntry])) -> some View {
        DisclosureGroup {
            tokenDetailsView(for: tokenMatch)
        } label: {
            Text(tokenMatch.token.surface ?? "Unknown")
                .font(.headline)
                .foregroundColor(tokenMatch.matches.isEmpty ? .red : .primary)
        }
    }
    
    // Detailed view for token information and matches
    private func tokenDetailsView(for tokenMatch: (token: Token, matches: [JMdictEntry])) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Token Information
            tokenInformationView(for: tokenMatch.token)
            
            // Dictionary Matches
            dictionaryMatchesView(for: tokenMatch.matches)
        }
    }
    
    // View for token information
    private func tokenInformationView(for token: Token) -> some View {
        Group {
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
    
    // View for dictionary matches
    private func dictionaryMatchesView(for matches: [JMdictEntry]) -> some View {
        Group {
            if !matches.isEmpty {
                Divider()
                Text("Dictionary Matches:")
                    .font(.headline)
                
                ForEach(matches, id: \.id) { entry in
                    dictionaryEntryView(for: entry)
                }
            } else {
                Text("No dictionary matches found")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // View for individual dictionary entry
    private func dictionaryEntryView(for entry: JMdictEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Kanji Representations
            if !entry.kanji.isEmpty {
                Text("Kanji: " + entry.kanji.map { $0.text }.joined(separator: ", "))
                    .font(.subheadline)
            }
            
            // Kana Representations
            if !entry.kana.isEmpty {
                Text("Kana: " + entry.kana.map { $0.text }.joined(separator: ", "))
                    .font(.subheadline)
            }
            
            // Senses (Meanings)
            ForEach(entry.sense.prefix(3), id: \.self) { sense in
                senseSummaryView(for: sense)
            }
        }
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
    
    // View for sense summary
    private func senseSummaryView(for sense: JMdictSense) -> some View {
        VStack(alignment: .leading) {
            // Part of Speech
            if !sense.partOfSpeech.isEmpty {
                Text("POS: " + sense.partOfSpeech.joined(separator: ", "))
                    .font(.caption)
            }
            
            // Glosses (Translations)
            ForEach(sense.gloss.prefix(2), id: \.self) { gloss in
                Text("\(gloss.lang): \(gloss.text)")
                    .font(.caption)
            }
        }
    }
    
    // Initialize matcher
    private func initializeMatcher() {
        matcher = MecabJMdictTokenMatcher(dictionary: dictionary)
    }
    
    // Tokenize and match
    private func performTokenizeAndMatch() {
        // Tokenize input
        let parsedTokens = tokenizer.parse(inputText)
        
        // Match tokens to dictionary
        tokens = parsedTokens.map { token in
            // Use advanced matching method
            let matches = matcher?.advancedMatch(token: token) ?? []
            return (token: token, matches: matches)
        }
    }
}

#Preview {
    ContentView()
}
