//
//  AppCore.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 11/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa


/// Singelton clas
class AppCore: NSObject {
    
    var currentEditor:ViewController?
    let defaults = UserDefaults.standard
    
    
    /// Open a file chooser dialog
    ///
    /// - Parameter completition: callback when user choose a file
    func openDialog(completition: (_ path:String?) -> Void){
        let dialog = NSOpenPanel();
        
        dialog.title                   = NSLocalizedString("CHOOSE", comment: "Choose Folder");
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles          = false;
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                completition(path)
            }
        } else {
            // User clicked on "Cancel"
            completition(nil)
        }
    }
    
    
    /// Match occurrences of regex in a sring
    ///
    /// - Parameters:
    ///   - regex: the regex to search
    ///   - text: the text
    /// - Returns: array of resuts
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
    /// Show simple dialog
    ///
    /// - Parameters:
    ///   - question: the question string
    ///   - text: the detail text
    /// - Returns: true if user press button
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
    
    /// Function to show a close alert
    ///
    /// - Parameters:
    ///   - question: the question string
    ///   - text: the detail text
    ///   - completion: callback func when user confirm
    func showCloseAlert(question: String, text: String, completion : (Bool)->Void) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("CANCEL", comment: ""))
        completion(alert.runModal() == NSAlertFirstButtonReturn)
    }
    
    
    /// Color a particular word in a given text
    ///
    /// - Parameters:
    ///   - text: all text
    ///   - search: word to color
    /// - Returns: colorated string
    func getColoredText(text: String, search:String) -> NSMutableAttributedString {
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.components(separatedBy:" ")
        
        for word in words {
            if (word.contains(search)) {
                let range:NSRange = (string.string as NSString).range(of: search)
                string.addAttribute(NSForegroundColorAttributeName, value: NSColor.red, range: range)
            }
        }
        return string
    }
    
    
    /// Scan file contents to find a localization variables
    ///
    /// - Parameter path: the file path
    /// - Returns: dictionary [namevar : comment]
    func findString(inPath path:String) -> [String:String]? {
        
        print("------------ FILEPARSING --------------")
        print("path: \(path)")
        do{
            let text2 = try String(contentsOf: URL(string: "file://\(path)")!, encoding: String.Encoding.utf8)
            let str = text2.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
            let matched = appCore.matches(for: "NSLocalizedString\\(\"[a-zA-Z0-9\\(\\)\\[\\]\\s_]+\",\\s*comment:\\s+\"[a-zA-Z0-9\\(\\)\\[\\]\\s_]*\"\\)[ ]*", in: str)
            var identifiedString:[String:String] = [String:String]()
            for m in matched{
                let grp = m.capturedGroups(withRegex: "\\(\"(.*)\",\\s+comment:\\s+\"(.*)\"\\)")
                if grp?.count == 2{
                    if let _ = identifiedString[grp!.first!]{
                        
                    }else{
                        identifiedString[grp!.first!] = grp!.last!
                    }
                }
            }
            print(identifiedString)
            return identifiedString
        }catch let e{
            print(e)
        }
        print("-----------------------------------")
        
        return nil
        
    }
    
}

//Instanse of singelton
let appCore = AppCore()


//USEFULL EXTENSION

extension String {
    
    
    /// Capture group of string that match a regex
    ///
    /// - Parameter pattern: the regex
    /// - Returns: the result groups
    func capturedGroups(withRegex pattern: String) -> [String]? {
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return nil
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        guard let match = matches.first else { return nil }
        
        // Note: Index 1 is 1st capture group, 2 is 2nd, ..., while index 0 is full match which we don't use
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return nil }
        
        var results = [String]()
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.rangeAt(i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
    
}

