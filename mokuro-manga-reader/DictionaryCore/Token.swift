//
//  Token.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import mecab

/**
 A struct that represents a MeCab node.
 
 `nil` is used instead of "*" (MeCab's convention) to represent a non-existent feature.
 */
struct Token {
    let surface: String?               // Exact substring (表層形)
    let partOfSpeech: String?         // Primary part of speech (品詞)
    let partsOfSpeech: [String]       // Array of part of speech types (品詞, 品詞細分類1, ...)
    let inflectionType: String?       // Inflection type (活用型)
    let inflection: String?           // Inflection of the word (活用形)
    let lemma: String?                // Lemma (語彙素)
    let writtenForm: String?          // Written form (書字形)
    let pronunciation: String?        // Pronunciation (発音形)
    let kana: String?                 // Kana representation (仮名形)
    
    init?(with node: mecab_node_t) {
        guard let surfaceData = node.surface else {
            return nil
        }
        
        // Use `String(decoding: Data, as:)` to handle the string conversion.
        let surface = String(decoding: Data(bytes: surfaceData, count: Int(node.length)), as: UTF8.self)
        guard let feature = node.feature,
              let features = String(cString: feature, encoding: .utf8)?.components(separatedBy: ",") else {
            return nil
        }
        
        self.surface = surface
        self.partOfSpeech = Self.starToNil(features[safe: 0])
        
        // Build the partsOfSpeech array with safe boundary checks.
        self.partsOfSpeech = features.prefix(4).compactMap { $0 != "*" ? $0 : nil }
        
        self.inflectionType = Self.starToNil(features[safe: 4])
        self.inflection = Self.starToNil(features[safe: 5])
        self.lemma = Self.starToNil(features[safe: 7])
        self.writtenForm = Self.starToNil(features[safe: 8])
        self.pronunciation = Self.starToNil(features[safe: 9])
        self.kana = Self.starToNil(features[safe: 17])
    }

    private static func starToNil(_ string: String?) -> String? {
        return string == "*" ? nil : string
    }
}

private extension Array {
    /// A helper to safely access elements in an array by index.
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
