//
//  MeCabJMdictTokenMatcher.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/18.
//

import Foundation

// Make JMdictEntry conform to Hashable and Equatable
extension JMdictEntry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: JMdictEntry, rhs: JMdictEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

class MecabJMdictTokenMatcher {
    private let jmdict: JMdictDictionary
    
    init(dictionary: JMdictDictionary) {
        self.jmdict = dictionary
    }
    
    /// Matches a Mecab token to JMdict entries based on different criteria
    func match(token: Token) -> [JMdictEntry] {
        var matchedEntries: [JMdictEntry] = []
        
        // Match strategies prioritized in order
        matchedEntries += matchByLemma(token)
        
        if matchedEntries.isEmpty {
            matchedEntries += matchByKana(token)
        }
        
        if matchedEntries.isEmpty {
            matchedEntries += matchByKanji(token)
        }
        
        if matchedEntries.isEmpty {
            matchedEntries += matchByPartOfSpeech(token)
        }
        
        return matchedEntries
    }
    
    /// Match by lemma (語彙素)
    private func matchByLemma(_ token: Token) -> [JMdictEntry] {
        guard let lemma = token.lemma else { return [] }
        
        return jmdict.words.filter { entry in
            // Check if lemma matches any kanji or kana readings
            let kanjiMatch = entry.kanji.contains { $0.text == lemma }
            let kanaMatch = entry.kana.contains { $0.text == lemma }
            
            return kanjiMatch || kanaMatch
        }
    }
    
    /// Match by kana reading
    private func matchByKana(_ token: Token) -> [JMdictEntry] {
        guard let kana = token.kana ?? token.pronunciation else { return [] }
        
        return jmdict.words.filter { entry in
            entry.kana.contains { $0.text == kana }
        }
    }
    
    /// Match by kanji reading
    private func matchByKanji(_ token: Token) -> [JMdictEntry] {
        guard let surface = token.surface, !surface.isEmpty else { return [] }
        
        return jmdict.words.filter { entry in
            entry.kanji.contains { $0.text == surface }
        }
    }
    
    /// Match by part of speech
    private func matchByPartOfSpeech(_ token: Token) -> [JMdictEntry] {
        guard let primaryPartOfSpeech = token.partOfSpeech else { return [] }
        
        return jmdict.words.filter { entry in
            entry.sense.contains { sense in
                sense.partOfSpeech.contains { pos in
                    pos.lowercased() == primaryPartOfSpeech.lowercased()
                }
            }
        }
    }
    
    /// Advanced matching with multiple criteria
    func advancedMatch(token: Token) -> [JMdictEntry] {
        var matchedEntries: [JMdictEntry] = []
        
        // Combine multiple matching strategies
        let lemmaMatches = matchByLemma(token)
        let kanaMatches = matchByKana(token)
        let kanjiMatches = matchByKanji(token)
        let posMatches = matchByPartOfSpeech(token)
        
        // Combine matches, prioritizing entries that match multiple criteria
        matchedEntries += lemmaMatches
        
        // Add entries that match kana but weren't in lemma matches
        matchedEntries += kanaMatches.filter { !lemmaMatches.contains($0) }
        
        // Add entries that match kanji but weren't in previous matches
        matchedEntries += kanjiMatches.filter { entry in
            !lemmaMatches.contains(entry) && !kanaMatches.contains(entry)
        }
        
        // Add part of speech matches as a last resort
        matchedEntries += posMatches.filter { entry in
            !lemmaMatches.contains(entry) &&
            !kanaMatches.contains(entry) &&
            !kanjiMatches.contains(entry)
        }
        
        // Remove duplicates using Set
        return Array(Set(matchedEntries))
    }
    
    /// Filter matches based on additional criteria
    func filterMatches(entries: [JMdictEntry], token: Token) -> [JMdictEntry] {
        return entries.filter { entry -> Bool in
            // Optional: Add more sophisticated filtering logic
            // For example, check inflection types, additional part of speech details
            
            // Example filter for common words
            let isCommonWord = entry.kanji.contains { $0.common } ||
                               entry.kana.contains { $0.common }
            
            return isCommonWord
        }
    }
    
    /// Contextual matching considering surrounding tokens
    func contextualMatch(tokens: [Token], currentIndex: Int) -> [JMdictEntry] {
        guard currentIndex >= 0 && currentIndex < tokens.count else {
            return []
        }
        
        let currentToken = tokens[currentIndex]
        var contextMatches: [JMdictEntry] = []
        
        // Basic contextual matching
        if currentIndex > 0 {
            let prevToken = tokens[currentIndex - 1]
            contextMatches += match(token: prevToken)
        }
        
        if currentIndex < tokens.count - 1 {
            let nextToken = tokens[currentIndex + 1]
            contextMatches += match(token: nextToken)
        }
        
        // Combine with current token matches
        contextMatches += match(token: currentToken)
        
        // Remove duplicates using Set
        return Array(Set(contextMatches))
    }
}
