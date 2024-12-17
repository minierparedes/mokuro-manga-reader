//
//  JMdictParser.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import SwiftyJSON

class DictionaryParser {
    static func parseJMdictJSON(data: Data) -> JMdictDictionary? {
        do {
            let json = try JSON(data: data)
            
            // Debug: Print the entire JSON structure
            print("JSON Type: \(json.type)")
            print("JSON Keys: \(json.dictionaryValue.keys)")
            
            let dictionary = JMdictDictionary()
            
            // Populate dictionary-level metadata
            dictionary.commonOnly = json["commonOnly"].boolValue
            dictionary.dictDate = json["dictDate"].stringValue
            dictionary.dictRevisions = json["dictRevisions"].arrayValue.compactMap { $0.stringValue }
            dictionary.languages = json["languages"].arrayValue.compactMap { $0.stringValue }
            dictionary.tags = json["tags"].dictionaryValue.mapValues { $0.stringValue }
            dictionary.version = json["version"].stringValue
            
            // Extract entries from the "words" key
            let entriesArray = json["words"].arrayValue
            
            // Parse entries
            for (index, entryJSON) in entriesArray.enumerated() {
                if let jmDictEntry = JMdictParser.parseEntry(json: entryJSON) {
                    dictionary.words.append(jmDictEntry)
                } else {
                    print("Failed to parse entry at index \(index)")
                }
            }
            
            // Additional debugging
            print("Parsed Entries Count: \(dictionary.words.count)")
            
            return dictionary.words.isEmpty ? nil : dictionary
            
        } catch {
            print("Error parsing JMdict JSON: \(error)")
            print("Full Error Details: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func parseEntry(json: JSON) -> JMdictEntry? {
        guard !json.isEmpty else {
            print("Empty entry JSON")
            return nil
        }
        
        let entry = JMdictEntry()
        
        // Parse ID
        entry.id = json["id"].stringValue
        
        // Parse Kanji
        entry.kanji = json["kanji"].arrayValue.compactMap { kanjiJSON in
            let kanji = JMdictKanji()
            kanji.common = kanjiJSON["common"].boolValue
            kanji.tags = kanjiJSON["tags"].arrayValue.compactMap { $0.stringValue }
            kanji.text = kanjiJSON["text"].stringValue
            return kanji.text.isEmpty ? nil : kanji
        }
        
        // Parse Kana
        entry.kana = json["kana"].arrayValue.compactMap { kanaJSON in
            let kana = JMdictKana()
            kana.appliesToKanji = kanaJSON["appliesToKanji"].arrayValue.compactMap { $0.stringValue }
            kana.common = kanaJSON["common"].boolValue
            kana.tags = kanaJSON["tags"].arrayValue.compactMap { $0.stringValue }
            kana.text = kanaJSON["text"].stringValue
            return kana.text.isEmpty ? nil : kana
        }
        
        // Parse Sense
        entry.sense = json["sense"].arrayValue.compactMap { senseJSON in
            let sense = JMdictSense()
            
            // Parse sense components
            sense.antonym = senseJSON["antonym"].arrayValue.compactMap { $0.stringValue }
            sense.appliesToKana = senseJSON["appliesToKana"].arrayValue.compactMap { $0.stringValue }
            sense.appliesToKanji = senseJSON["appliesToKanji"].arrayValue.compactMap { $0.stringValue }
            sense.dialect = senseJSON["dialect"].arrayValue.compactMap { $0.stringValue }
            sense.field = senseJSON["field"].arrayValue.compactMap { $0.stringValue }
            sense.info = senseJSON["info"].arrayValue.compactMap { $0.stringValue }
            sense.misc = senseJSON["misc"].arrayValue.compactMap { $0.stringValue }
            sense.partOfSpeech = senseJSON["partOfSpeech"].arrayValue.compactMap { $0.stringValue }
            sense.related = senseJSON["related"].arrayValue.compactMap { $0.stringValue }
            
            // Parse Gloss
            sense.gloss = senseJSON["gloss"].arrayValue.compactMap { glossJSON in
                let gloss = JMdictGloss()
                gloss.gender = JMdictGender(rawValue: glossJSON["gender"].stringValue)
                gloss.lang = glossJSON["lang"].stringValue
                gloss.text = glossJSON["text"].stringValue
                gloss.type = JMdictGlossType(rawValue: glossJSON["type"].stringValue)
                return gloss.text.isEmpty ? nil : gloss
            }
            
            // Parse Language Source
            sense.languageSource = senseJSON["languageSource"].arrayValue.compactMap { sourceJSON in
                let source = JMdictLanguageSource()
                source.full = sourceJSON["full"].boolValue
                source.lang = sourceJSON["lang"].stringValue
                source.text = sourceJSON["text"].stringValue
                source.wasei = sourceJSON["wasei"].boolValue
                return source.lang.isEmpty ? nil : source
            }
            
            return (sense.gloss.isEmpty && sense.antonym.isEmpty) ? nil : sense
        }
        
        // Return nil if the entry is essentially empty
        return (entry.kana.isEmpty && entry.kanji.isEmpty && entry.sense.isEmpty) ? nil : entry
    }
}

class JMdictParser {
    static func parseEntry(json: JSON) -> JMdictEntry? {
        // Validate that we have a valid entry
        guard !json.isEmpty else {
            print("Empty JSON entry")
            return nil
        }
        
        let entry = JMdictEntry()
        
        // More flexible ID extraction
        entry.id = json["entry_id"].stringValue.isEmpty
            ? json["id"].stringValue
            : json["entry_id"].stringValue
        
        // More robust extraction with fallback keys
        func extractArray(primaryKey: String, fallbackKeys: [String]) -> [JSON] {
            if !json[primaryKey].arrayValue.isEmpty {
                return json[primaryKey].arrayValue
            }
            
            for key in fallbackKeys {
                if !json[key].arrayValue.isEmpty {
                    return json[key].arrayValue
                }
            }
            
            return []
        }
        
        // Extract Kana readings with multiple possible keys and new model
        entry.kana = extractArray(primaryKey: "r_ele", fallbackKeys: ["kana", "readings"])
            .compactMap { kana in
                let kanaObject = JMdictKana()
                kanaObject.text = kana["reb"].stringValue.isEmpty
                    ? kana["reading"].stringValue
                    : kana["reb"].stringValue
                
                // Populate additional properties
                kanaObject.common = kana["common"].boolValue
                kanaObject.tags = kana["tags"].arrayValue.compactMap { $0.stringValue }
                kanaObject.appliesToKanji = kana["applies_to"].arrayValue.compactMap { $0.stringValue }
                
                return kanaObject.text.isEmpty ? nil : kanaObject
            }
        
        // Extract Kanji characters with multiple possible keys and new model
        entry.kanji = extractArray(primaryKey: "k_ele", fallbackKeys: ["kanji", "characters"])
            .compactMap { kanji in
                let kanjiObject = JMdictKanji()
                kanjiObject.text = kanji["keb"].stringValue.isEmpty
                    ? kanji["character"].stringValue
                    : kanji["keb"].stringValue
                
                // Populate additional properties
                kanjiObject.common = kanji["common"].boolValue
                kanjiObject.tags = kanji["tags"].arrayValue.compactMap { $0.stringValue }
                
                return kanjiObject.text.isEmpty ? nil : kanjiObject
            }
        
        // Extract senses with multiple possible keys and new model
        entry.sense = extractArray(primaryKey: "sense", fallbackKeys: ["senses", "meanings"])
            .compactMap { senseJSON in
                let senseObject = JMdictSense()
                
                // Part of speech
                senseObject.partOfSpeech = senseJSON["pos"].arrayValue.compactMap { $0.stringValue }
                
                // Gloss extraction with new model
                senseObject.gloss = senseJSON["gloss"].arrayValue.compactMap { glossJSON in
                    let glossObject = JMdictGloss()
                    
                    // Populate gloss properties
                    glossObject.text = glossJSON["text"].stringValue
                    glossObject.lang = glossJSON["lang"].stringValue
                    
                    // Gender mapping
                    if let genderString = glossJSON["gender"].string {
                        glossObject.gender = JMdictGender(rawValue: genderString.lowercased())
                    }
                    
                    // Gloss type mapping
                    if let typeString = glossJSON["type"].string {
                        glossObject.type = JMdictGlossType(rawValue: typeString.lowercased())
                    }
                    
                    return glossObject
                }
                
                // Additional sense properties
                senseObject.dialect = senseJSON["dialect"].arrayValue.compactMap { $0.stringValue }
                senseObject.field = senseJSON["field"].arrayValue.compactMap { $0.stringValue }
                senseObject.info = senseJSON["info"].arrayValue.compactMap { $0.stringValue }
                senseObject.misc = senseJSON["misc"].arrayValue.compactMap { $0.stringValue }
                senseObject.antonym = senseJSON["antonym"].arrayValue.compactMap { $0.stringValue }
                senseObject.related = senseJSON["related"].arrayValue.compactMap { $0.stringValue }
                
                // Language source extraction
                senseObject.languageSource = senseJSON["language_source"].arrayValue.compactMap { sourceJSON in
                    let sourceObject = JMdictLanguageSource()
                    
                    sourceObject.lang = sourceJSON["lang"].stringValue
                    sourceObject.text = sourceJSON["text"].string
                    sourceObject.full = sourceJSON["full"].boolValue
                    sourceObject.wasei = sourceJSON["wasei"].boolValue
                    
                    return sourceObject
                }
                
                // Applies to properties
                senseObject.appliesToKana = senseJSON["applies_to_kana"].arrayValue.compactMap { $0.stringValue }
                senseObject.appliesToKanji = senseJSON["applies_to_kanji"].arrayValue.compactMap { $0.stringValue }
                
                return (senseObject.gloss.isEmpty && senseObject.partOfSpeech.isEmpty) ? nil : senseObject
            }
        
        // Return nil if the entry is essentially empty
        return (entry.kana.isEmpty && entry.kanji.isEmpty && entry.sense.isEmpty) ? nil : entry
    }
}
