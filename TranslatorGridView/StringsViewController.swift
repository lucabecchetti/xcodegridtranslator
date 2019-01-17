//
//  ViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class StringsViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate{
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var similarLabel: NSTextField!
    @IBOutlet weak var unmatchlabel: NSTextField!
    @IBOutlet weak var processedLabel: NSTextField!
    @IBOutlet weak var matchLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var stringWork: NSTextField!
    var path:String?
    var dictIOS:[String:String] = [String:String]()
    var dictAndroid:[String:String] = [String:String]()
    var variables:[String] = [String]()
    var mapped:[String:String] = [String:String]()
    var similar:[String:String] = [String:String]()
    var searchString:String        = ""

    var similarSelected:SimilString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableColumns[0].width = 150
        tableView.selectionHighlightStyle = .none
        tableView.isHidden = true
        progress.isHidden = false
        progress.isIndeterminate = true
        progress.startAnimation(self)
        stringWork.stringValue = "inizio"
        stringWork.textColor = .gray
        
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
            
            do {
                let node = try XMLDocument(contentsOf: URL(string: "file://"+self.path!)!, options: 0)
                
                let child = node.rootElement()?.children
                for ch in child!{
                    if let c = ch as? XMLElement{
                        if ch.name != nil && ch.name!.lowercased() == "string"{
                            if let att = c.attribute(forName: "name"){
                                DispatchQueue.main.async {
                                    self.stringWork.stringValue = "Reading string: \(ch.stringValue!)"
                                }
                                self.dictAndroid[att.stringValue!] = ch.stringValue!
                            }
                        }
                    }
                }
                
            }catch let e{
                print(e)
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
                    
                    if language != "en"{
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
            
            
            var work = 0
            var unmatch = 0
            for(key,value) in self.dictAndroid{
                work += 1
                DispatchQueue.main.async {
                    self.progress!.maxValue = Double(self.dictAndroid.count)
                    self.progress!.minValue = 0
                    self.progress!.isIndeterminate = false
                    self.progress!.doubleValue = Double(work)
                    self.stringWork.stringValue = "Testing string: \(key)"
                    self.processedLabel.stringValue = "\(work)"
                }
                
                if let _ = self.mapped[key]{
                    DispatchQueue.main.async {
                        self.matchLabel.stringValue = "\(self.mapped.count)"
                    }
                }else{
                //let ios = dictIOS.index(where: {$0.value == value})
                let fil = self.dictIOS.filter({ (key,string) -> Bool in
                    do{
                        let regex = try NSRegularExpression(pattern:"%\\d{1}\\$[sdf]", options: NSRegularExpression.Options.caseInsensitive)
                        let range = NSMakeRange(0, (value as NSString).length)
                        let newString = regex.stringByReplacingMatches(in: value, options: [], range: range, withTemplate: "").lowercased()
                        return
                            string.replacingOccurrences(of: "%@", with: "")
                                .replacingOccurrences(of: "%d", with: "")
                                .replacingOccurrences(of: "\n", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                                ==
                                newString.trimmingCharacters(in: .whitespacesAndNewlines)
                                    .replacingOccurrences(of: "…", with: "...")
                                    .replacingOccurrences(of: "\n", with: "")
                                    .replacingOccurrences(of: "\'", with: "'")
                                    .replacingOccurrences(of: "\\\"", with: "\"")
                    }catch{
                        return false
                    }
                })
                
                if fil.count > 0{
                    //print("Android[\(key)] = \(value) == IOS[\(fil.first!.key)] = \(fil.first!.value)")
                    
                    self.mapped[key] = fil.first!.key
                    
                    DispatchQueue.main.async {
                        self.matchLabel.stringValue = "\(self.mapped.count)"
                    }
                }else{
                    unmatch += 1
                    DispatchQueue.main.async {
                        self.unmatchlabel.stringValue = "\(unmatch)"
                        
                    }
                    
                    var kw = ""
                    let wd = value.components(separatedBy: " ")
                    if wd.count == 1{
                        continue
                    }

                    let r:Double = (Double(wd.count)/100)*80
                    var point:Int = Int(round(r))
                    
                    for(k,v) in self.dictIOS{
                        
                        let pp = self.wordsDis(w1: value, w2: v)
                        if pp >= point{
                            point = pp
                            kw = k
                        }
                        
                    }
                    if kw != "" {
                        self.similar[key] = kw
                        DispatchQueue.main.async {
                            self.similarLabel.stringValue = "\(self.similar.count)"
                        }
                        //print("trovato simile: \(value) ~ \(self.dictIOS[kw]) con distanza: \(point)")
                    }
                    
                }
                }
                
            }
            
            DispatchQueue.main.async {
                self.progress.isHidden = true
                self.stringWork.isHidden = true
                self.tableView.reloadData()
                for col in self.tableView.tableColumns{
                    col.width = max(300,(self.tableView.frame.size.width-150)/4)
                }
                self.tableView.isHidden = false
                
            }
            
        }
        
    }
    
    override func viewDidAppear() {
        
    }
    
    override func viewDidDisappear() {
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        
        self.searchString = self.searchField.stringValue
        self.tableView.reloadData()
        
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return (searchString == "") ?   dictAndroid.count : dictAndroid.filter({$0.key.lowercased().contains(searchString.lowercased()) || $0.value.lowercased().contains(searchString.lowercased())}).count
        
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let ar = (searchString == "") ? dictAndroid.filter({$0.key != ""}) : dictAndroid.filter({$0.key.lowercased().contains(searchString.lowercased()) || $0.value.lowercased().contains(searchString.lowercased())})
        let dc = Array(ar)[row]
        if (tableColumn!.identifier == "iosVar") {
            
            let cell = tableView.make(withIdentifier: "name", owner: self) as! NSTableCellView
            
            if let str = mapped[dc.key]{
                cell.textField?.stringValue = str
                cell.textField?.backgroundColor = .clear
                cell.textField?.textColor = .black
            }else{
                
                if let simil = similar[dc.key]{
                    cell.textField?.stringValue = "* \(simil) *"
                    cell.textField?.textColor = .orange
                    cell.textField?.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                }else{
                    cell.textField?.stringValue = "??????"
                    cell.textField?.textColor = .red
                    cell.textField?.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                }
            }
            
            return cell;
            
        }else if (tableColumn!.identifier == "iosValue") {
            
            let cell = tableView.make(withIdentifier: "value", owner: self) as! NSTableCellView
            if let str = mapped[dc.key]{
                if let val = dictIOS[str] {
                    cell.textField?.stringValue = val
                    cell.textField?.backgroundColor = .clear
                    cell.textField?.textColor = .black
                    
                }else{
                    cell.textField?.stringValue = "??????"
                    cell.textField?.textColor = .red
                    cell.textField?.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                }
            }else{
                if let simil = similar[dc.key], let ww = self.dictIOS[simil]{
                    cell.textField?.stringValue = "* \(ww) *"
                    cell.textField?.textColor = .orange
                    cell.textField?.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                }else{
                    cell.textField?.stringValue = "??????"
                    cell.textField?.textColor = .red
                    cell.textField?.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                }
            }
            return cell;
            
        }else if (tableColumn!.identifier == "androidValue") {
            
            let cell = tableView.make(withIdentifier: "value", owner: self) as! NSTableCellView
            cell.textField?.stringValue = dc.value
            return cell;
            
        }else if (tableColumn!.identifier == "androidVar") {
            
            let cell = tableView.make(withIdentifier: "name", owner: self) as! NSTableCellView
            cell.textField?.stringValue = dc.key
            //cell.textField?.stringValue = Array(mapped[row]).first!.value
            return cell;
            
        }else {
            
            let cell = tableView.make(withIdentifier: "action", owner: self) as! ActionCell
            
            if let _ = mapped[dc.key]{
                cell.actionButton.title = ""
                cell.actionButton.isHidden = true
            }else{
                if let simil = similar[dc.key], let _ = self.dictIOS[simil]{
                    cell.actionButton.title = "Review"
                    cell.actionButton.isHidden = false
                    cell.actionButton.tag = row
                    cell.actionButton.target = self
                    cell.actionButton.action = #selector(StringsViewController.clickButton(sender:))
                }else{
                    cell.actionButton.title = "Find string"
                    cell.actionButton.isHidden = false
                    cell.actionButton.tag = row
                    cell.actionButton.target = self
                    cell.actionButton.action = #selector(StringsViewController.clickButton(sender:))
                }
            }
            
            
            return cell;
            
        }
        
        
    }
    
    @objc func clickButton(sender:NSButton){
        
        let ar = (searchString == "") ? dictAndroid.filter({$0.key != ""}) : dictAndroid.filter({$0.key.lowercased().contains(searchString.lowercased()) || $0.value.lowercased().contains(searchString.lowercased())})
        let dc = Array(ar)[sender.tag]
        if let ios_var = similar[dc.key], let ios_val = self.dictIOS[ios_var]{
            similarSelected = SimilString(ios_var: ios_var, ios_val: ios_val, android_var: dc.key, android_val: dc.value)
        }else{
            similarSelected = SimilString(ios_var: "", ios_val: "", android_var: dc.key, android_val: dc.value)
        }
        self.performSegue(withIdentifier: "verify", sender: self)
    }
    
    @IBAction func createMap(_ sender: Any) {
        store(dictionary: mapped, in: "ios_android_map")
    }
    
    func store(dictionary: Dictionary<String, String>, in fileName: String) {
       
        let fileExtension = "plist"
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: mapped, format: .xml, options: 0)
            try data.write(to: URL(string: "file://"+appCore.currentPath)!.appendingPathComponent(fileName).appendingPathExtension(fileExtension))
            
        }  catch {
            print(error)
        }
  
    }
    
    func wordsDis(w1: String, w2: String) -> Int {
        
        var words1 = w1.components(separatedBy: " ").filter({$0.characters.count > 2}).map { $0.lowercased()}
        let words2 = w2.components(separatedBy: " ").map { $0.lowercased()}
        
        let precount = words1.count
        for w in words2{
            if let i = words1.index(of: w){
                words1.remove(at: i)
            }
        }
        return precount-words1.count
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "verify") {
            
            // initialize new view controller and cast it as your view controller
            let verController = segue.destinationController as? VerifyController
            verController?.simil = similarSelected
            verController?.parentController = self
            
        }
    }
    
}

