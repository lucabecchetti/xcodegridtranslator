//
//  AddNewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa
import AEXML
class ExportController: NSViewController{

    @IBOutlet weak var textField: NSTextView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var stringWork: NSTextField!
    
    var mapped:[String:String] = [String:String]()
    var dictIOS:[String:String] = [String:String]()
    
    override func viewDidLoad() {
        
        progress.isHidden = false
        progress.isIndeterminate = true
        progress.startAnimation(self)
        stringWork.stringValue = "inizio"
        stringWork.textColor = .gray
        textField.isHidden = true
        
        let yourXML = AEXMLDocument()
        yourXML.attributes = ["version" : "1.0", "encoding" : "utf-8"]
        let resources = yourXML.addChild(name: "resources")
        
        DispatchQueue.global(qos: .background).async {
            //Build Android strings
            
            
             DispatchQueue.main.async {
                self.stringWork.stringValue = "Reading android strings..."
             }
            
            //Read old map
            if let url = URL(string: "file://"+appCore.currentPath)?.appendingPathComponent("ios_android_map").appendingPathExtension("plist"){
                
                if let dic = NSDictionary(contentsOf: url) as? [String:String]{
                    
                    self.mapped = dic
                    
                }
            }
            
            //Build IOS strings
            DispatchQueue.main.async {
             self.stringWork.stringValue = "Reading IOS Strings..."
            }
            
            for lists in appCore.dict!{
                
                for file in lists.value{
                    
                    let language = file.components(separatedBy: "/").filter({
                        return $0.contains(".lproj")
                    }).first?.replacingOccurrences(of: ".lproj", with: "").lowercased()
                    
                    if language != "fr"{
                        continue
                    }
                    
                    
                     DispatchQueue.main.async {
                        self.stringWork.stringValue = "Reading file: \(file)"
                     }
                    
                    let url = URL(string: "file://"+file)
                    
                    if let dic = NSDictionary(contentsOf: url!) as? [String:String]{
                        for d in dic{
                            if let _ = self.dictIOS[d.key]{
                                self.dictIOS[d.key+"_{{file}}_"+file.components(separatedBy: "/").last!] = d.value
                            }else{
                                self.dictIOS[d.key] = d.value
                                DispatchQueue.main.async {
                                    self.stringWork.stringValue = "Reading string: \(d.key)"
                                }
                            }
                        }
                    }else{
                        _ = appCore.dialogOKCancel(question: NSLocalizedString("OK", comment: ""), text: String(format: NSLocalizedString("ERROR_1", comment: ""), "\(url!)") )
                    }
                }
            }
            
            for m in self.mapped{
                
                if let str = self.mapped[m.key]{
                    if var val = self.dictIOS[str] {
                        DispatchQueue.main.async {
                            self.stringWork.stringValue = "Building string: \(val)"
                        }
                    
                        let matched = appCore.matches(for: "%[@d]", in: val)
                        var pcount = 1
                        for m in matched{
                            
                            val = val.stringByReplacingFirstOccurrenceOfString(target: m, withString: "%\(pcount)$\( m == "%@" ? "s" : "d" )")
                            pcount += 1
                            
                        }
                        
                        resources.addChild(name: "string", value: val.replacingOccurrences(of: "\n", with: ""), attributes: ["name" : m.key])
                    }
                }
                
                
            }
            
            DispatchQueue.main.async {
                self.textField.string       = yourXML.xml.replacingOccurrences(of: "&apos;", with: "\'").replacingOccurrences(of: "&quot;", with: "\\\"")
                self.textField.isHidden     = false
                self.progress.isHidden      = true
                self.stringWork.isHidden    = true
            }
            
        }
        
        
        
        
    }
    
}
