//
//  Tokenizer.swift
//  mokuro-manga-reader
//
//  Created by ethan crown on 2024/12/17.
//

import Foundation
import mecab

/**
 A Swift wrapper for MeCab.
 
 Provides a simple function, parse(), to break a String into tokens.
 */
class Tokenizer {
    typealias MeCab = OpaquePointer
    var mecab: MeCab?
    
    deinit {
        if let mecab = mecab {
            mecab_destroy(mecab)
        }
    }
    
    func parse(_ text: String) -> [Token] {
        guard let path = URL(string: "dicdir", relativeTo: Bundle.main.resourceURL)?.path else {
            assertionFailure("Unable to get resource path.")
            return []
        }
        
        if mecab == nil {
            mecab = mecab_new2("-d \(path)")
            guard let mecab = mecab else {
                assertionFailure("Error in mecab_new2: \(String(cString: mecab_strerror(nil)))")
                return []
            }
        }
        
        guard let buf = text.cString(using: .utf8) else {
            assertionFailure("Failed to convert text to CString.")
            return []
        }
        
        let length = text.lengthOfBytes(using: .utf8)
        guard let nodePtr = mecab_sparse_tonode2(mecab, buf, length) else {
            assertionFailure("Failed to create initial MeCab node.")
            return []
        }
        
        var tokens = [Token]()
        var currentNodePtr = nodePtr.pointee.next
        
        while let node = currentNodePtr, node.pointee.next != nil {
            if let token = Token(with: node.pointee) {
                tokens.append(token)
            }
            currentNodePtr = node.pointee.next
        }
        
        return tokens
    }
}
