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
