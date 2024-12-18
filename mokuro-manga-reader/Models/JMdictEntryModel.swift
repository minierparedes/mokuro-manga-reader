//
//  JMdictEntryModel.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation

// Enum for Gloss Type
enum JMdictGlossType: String, Codable {
    case literal
    case figurative
    case explanation
    case trademark
}

// Enum for Gender
enum JMdictGender: String, Codable {
    case masculine
    case feminine
    case neuter
}

// Updated Data Models
class JMdictDictionary {
    var commonOnly: Bool?
    var dictDate: String?
    var dictRevisions: [String]?
    var languages: [String]?
    var tags: [String: String]?
    var version: String?
    var words: [JMdictEntry] = []
}

class JMdictEntry {
    var id: String = ""
    var kanji: [JMdictKanji] = []
    var kana: [JMdictKana] = []
    var sense: [JMdictSense] = []
}

class JMdictKanji {
    var common: Bool = false
    var tags: [String] = []
    var text: String = ""
}

class JMdictKana {
    var appliesToKanji: [String] = []
    var common: Bool = false
    var tags: [String] = []
    var text: String = ""
}

class JMdictSense {
    var antonym: [String] = []
    var appliesToKana: [String] = []
    var appliesToKanji: [String] = []
    var dialect: [String] = []
    var field: [String] = []
    var gloss: [JMdictGloss] = []
    var info: [String] = []
    var languageSource: [JMdictLanguageSource] = []
    var misc: [String] = []
    var partOfSpeech: [String] = []
    var related: [String] = []
}

class JMdictGloss {
    var gender: JMdictGender?
    var lang: String = ""
    var text: String = ""
    var type: JMdictGlossType?
}

class JMdictLanguageSource {
    var full: Bool = false
    var lang: String = ""
    var text: String?
    var wasei: Bool = false
}

// Extension to make JMdictSense Hashable
extension JMdictSense: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Combine hash values of properties that uniquely identify the sense
        hasher.combine(partOfSpeech)
        hasher.combine(gloss.map { $0.text })
        hasher.combine(appliesToKanji)
        hasher.combine(appliesToKana)
    }
    
    public static func == (lhs: JMdictSense, rhs: JMdictSense) -> Bool {
        return lhs.partOfSpeech == rhs.partOfSpeech &&
               lhs.gloss.map { $0.text } == rhs.gloss.map { $0.text } &&
               lhs.appliesToKanji == rhs.appliesToKanji &&
               lhs.appliesToKana == rhs.appliesToKana
    }
}

// Extension to make JMdictGloss Hashable
extension JMdictGloss: Hashable {
    public func hash(into hasher: inout Hasher) {
        // Combine hash values of properties that uniquely identify the gloss
        hasher.combine(text)
        hasher.combine(lang)
        hasher.combine(type)
        hasher.combine(gender)
    }
    
    public static func == (lhs: JMdictGloss, rhs: JMdictGloss) -> Bool {
        return lhs.text == rhs.text &&
               lhs.lang == rhs.lang &&
               lhs.type == rhs.type &&
               lhs.gender == rhs.gender
    }
}
