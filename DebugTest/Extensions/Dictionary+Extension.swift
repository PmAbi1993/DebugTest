//
//  Dictionary+Extension.swift
//  DebugTest
//
//  Created by Abhijith Pm on 10/9/25.
//

import Foundation

extension Dictionary {
    /// Returns a pretty-printed JSON string representation of the dictionary
    /// - Returns: A formatted JSON string or nil if conversion fails
    func jsonString(prettyPrinted: Bool = true) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        
        let options: JSONSerialization.WritingOptions = prettyPrinted ? [.prettyPrinted] : []
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: options)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error converting dictionary to JSON: \(error)")
            return nil
        }
    }
    
    /// Prints the JSON representation of the dictionary to the console
    func printAsJSON(prettyPrinted: Bool = true) {
        if let jsonString = self.jsonString(prettyPrinted: prettyPrinted) {
            print(jsonString)
        } else {
            print("Failed to convert dictionary to JSON")
        }
    }
}
