//
//  ContentView.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftyJSON

struct ContentView: View {
    @State private var tokenizer = Tokenizer()
    @State private var importedDictionary: JMdictDictionary?
    @State private var matcher: MecabJMdictTokenMatcher?
    @State private var inputText = ""
    @State private var tokens: [(token: Token, matches: [JMdictEntry])] = []
    
    // Import and Processing States
    @State private var isImporting = false
    @State private var errorMessage: String?
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            // Dictionary Import Section
            HStack {
                Button("Import JMdict ZIP") {
                    isImporting = true
                }
                .buttonStyle(.borderedProminent)
                
                if importedDictionary != nil {
                    Text("✓ Dictionary Loaded")
                        .foregroundColor(.green)
                }
            }
            
            // Tokenization Section
            VStack {
                TextField("Text to tokenize...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Tokenize and Match") {
                    performTokenizeAndMatch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(importedDictionary == nil)
            }
            .padding()
            
            // Processing Indicators
            if isProcessing {
                ProgressView("Processing dictionary...")
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            // Token and Dictionary Match List
            tokenMatchListView
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.zip],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .padding()
    }
    
    // Token Match List View
    private var tokenMatchListView: some View {
        List {
            ForEach(tokens.indices, id: \.self) { index in
                tokenMatchView(for: tokens[index])
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Individual Token Match View
    private func tokenMatchView(for tokenMatch: (token: Token, matches: [JMdictEntry])) -> some View {
        DisclosureGroup {
            tokenDetailsView(for: tokenMatch)
        } label: {
            Text(tokenMatch.token.surface ?? "Unknown")
                .font(.headline)
                .foregroundColor(tokenMatch.matches.isEmpty ? .red : .primary)
        }
    }
    
    // Token Details View
    private func tokenDetailsView(for tokenMatch: (token: Token, matches: [JMdictEntry])) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            tokenInformationView(for: tokenMatch.token)
            dictionaryMatchesView(for: tokenMatch.matches)
        }
    }
    
    // Token Information View
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
    
    // Dictionary Matches View
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
    
    // Dictionary Entry View
    private func dictionaryEntryView(for entry: JMdictEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if !entry.kanji.isEmpty {
                Text("Kanji: " + entry.kanji.map { $0.text }.joined(separator: ", "))
                    .font(.subheadline)
            }
            
            if !entry.kana.isEmpty {
                Text("Kana: " + entry.kana.map { $0.text }.joined(separator: ", "))
                    .font(.subheadline)
            }
            
            ForEach(entry.sense.prefix(3), id: \.self) { sense in
                senseSummaryView(for: sense)
            }
        }
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
    
    // Sense Summary View
    private func senseSummaryView(for sense: JMdictSense) -> some View {
        VStack(alignment: .leading) {
            if !sense.partOfSpeech.isEmpty {
                Text("POS: " + sense.partOfSpeech.joined(separator: ", "))
                    .font(.caption)
            }
            
            ForEach(sense.gloss.prefix(2), id: \.self) { gloss in
                Text("\(gloss.lang): \(gloss.text)")
                    .font(.caption)
            }
        }
    }
    
    // Tokenize and Match
    private func performTokenizeAndMatch() {
        guard let matcher = matcher else { return }
        
        let parsedTokens = tokenizer.parse(inputText)
        
        tokens = parsedTokens.map { token in
            let matches = matcher.advancedMatch(token: token)
            return (token: token, matches: matches)
        }
    }
    
    // File Import Handler
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            // Reset previous state
            errorMessage = nil
            isProcessing = true
            
            // Extract the URL
            let selectedFile = try result.get().first!
            
            // Ensure the file is accessible
            guard selectedFile.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "FileAccessError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot access the selected file"])
            }
            
            // Unzip the file
            guard let unzippedURL = FileHandler.unzipFile(at: selectedFile) else {
                throw NSError(domain: "UnzipError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip the file"])
            }
            
            // Load JSON data
            guard let jsonData = FileHandler.loadJSONData(from: unzippedURL) else {
                throw NSError(domain: "JSONLoadError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load JSON data"])
            }
            
            // Parse the dictionary
            guard let parsedDictionary = DictionaryParser.parseJMdictJSON(data: jsonData) else {
                throw NSError(domain: "ParsingError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse dictionary entries"])
            }
            
            // Update entries on main thread
            DispatchQueue.main.async {
                self.importedDictionary = parsedDictionary
                self.matcher = MecabJMdictTokenMatcher(dictionary: parsedDictionary)
                self.isProcessing = false
            }
            
            // Stop accessing the security-scoped resource
            selectedFile.stopAccessingSecurityScopedResource()
            
        } catch {
            // Handle any errors
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isProcessing = false
            }
        }
    }
}

#Preview {
    ContentView()
}
