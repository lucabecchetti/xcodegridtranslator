//
//  ViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate,SplitViewDelegate,NSTextFieldDelegate,AddNewDelegate,ToolbarDelegate,SearchDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var dict:[String:[String:String]]? = [String:Dictionary]()
    var columns:[NSTableColumn] = [NSTableColumn]()
    var currentPath:[String] = [String]()
    var pathsFile: NSMutableDictionary = NSMutableDictionary()
    var variables:[String] = [String]()
    var mainWindow:StartWindowController?
    var delegate:EditingDelegate?
    var gridViewController:GridViewController?
    var searchString:String?
    var selected:IndexSet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableColumns[0].headerCell.title = "VARIABILE"
        tableView.tableColumns[0].width = 150
        tableView.selectionHighlightStyle = .none
        
    }
    
    override func viewDidAppear() {
        
        if let win = NSApplication.shared().mainWindow?.windowController as? GridViewController{
            gridViewController = win
            win.searchItem.isEnabled = false
            win.trashItem.isEnabled = false
            win.searchItem.label = NSLocalizedString("SEARCH", comment: "").lowercased()
            win.trashItem.label = NSLocalizedString("DELETE", comment: "").lowercased()
            win.delegate = self
        }
        
    }
    
    override func viewDidDisappear() {
        
        if mainWindow == nil{
            mainWindow = StartWindowController.loadFromNib()
            mainWindow?.showWindow(self)
            mainWindow?.window?.center()
            self.view.window?.close()
        }
        
    }
    
    func addNew(){
        self.performSegue(withIdentifier: "addNew", sender: self)
    }
    
    //MARK: EditingProtocol
    
    func newItemDidAdded(name: String) {
        
        //If is not empty, continue
        if name != ""{
            self.variables.append(name)
            self.tableView.reloadData()
            tableView.scrollToEndOfDocument(self)
        }
        
        
    }
    
    //MARK: SearchProtocol
    
    func searchString(string: String) {
        
        searchString = (string != "") ? string : nil
        tableView.reloadData()
        
    }
    
    //MARK: ToolbarProtocol
    
    func search() {
        self.performSegue(withIdentifier: "search", sender: self)
    }
    
    func delete() {
        appCore.showCloseAlert(question: NSLocalizedString("QUESTION_1", comment: ""), text: NSLocalizedString("DETAILS_1", comment: ""), completion: { (answer) in
            if answer == true{
                if selected != nil{
                    if let id = selected!.first{
                        let vari = variables[id]
                        variables = variables.filter({$0 != vari})
                        for(languageFolder, filePath) in pathsFile{
                            
                            if !removeOrUpdate(stringInPath: URL(string: "\(filePath)")!, identifierVar: vari, stringValue: "", identifierFile: "\(languageFolder)", remove: true){
                                
                            }
                        }
                        
                    }
                }
                
                self.tableView.removeRows(at: selected!, withAnimation: NSTableViewAnimationOptions.slideDown)
                selected = nil
                gridViewController!.trashItem.isEnabled = false
            }
        })
    }
    
    //MARK: AddNewProtocol
    
    func didSelectedFile(atPaths paths: [String]) {
        
        searchString = nil
        variables.removeAll()
        currentPath = paths
        dict?.removeAll()
        for coltoremove in columns{
            tableView.removeTableColumn(coltoremove)
        }
        tableView.reloadData()
        
        for file in paths{
            let language = file.components(separatedBy: "/").filter({
                return $0.contains(".lproj")
            }).first?.replacingOccurrences(of: ".lproj", with: "").lowercased()
            
            let url = URL(string: "file://"+file)
            let col = NSTableColumn(identifier: language!.lowercased())
            
            col.width = max(300,(self.tableView.frame.size.width-150)/CGFloat(paths.count))
            col.headerCell.title = language!.uppercased()
            columns.append(col)
            tableView.addTableColumn(col)
            
            if let dic = NSDictionary(contentsOf: url!) as? [String: String]{
                dict![language!] = dic
                for d in dic{
                    if let _ = variables.index(of: d.key){
                        
                    }else{
                        variables.append(d.key)
                    }
                }
            }else{
                _ = appCore.dialogOKCancel(question: NSLocalizedString("OK", comment: ""), text: String(format: NSLocalizedString("ERROR_1", comment: ""), "\(url!)") )
            }
            pathsFile[language!] = "file://\(file)"
        }
        
        variables.sort(by: >)
        tableView.reloadData()
        gridViewController?.searchItem.isEnabled = true
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if searchString == nil{
            return variables.count
        }else{
            return variables.filter({$0.contains(searchString!)}).count
        }
        
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            selected = myTable.selectedRowIndexes
            gridViewController!.trashItem.isEnabled = true
            
        }
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        if (tableColumn!.identifier == "name") {
            
            let cell = tableView.make(withIdentifier: "name", owner: self) as! NSTableCellView
            
            cell.textField!.font = NSFont.boldSystemFont(ofSize: 13)
            if searchString == nil{
                cell.textField!.stringValue = " "+variables[row]
            }else{
                cell.textField!.attributedStringValue = appCore.getColoredText(text: variables.filter({$0.contains(searchString!)})[row].replacingOccurrences(of: searchString!, with: searchString!), search: searchString!)
            }
            
            return cell;
            
        }else {
            
            let cell = tableView.make(withIdentifier: "value", owner: self) as! EditableCell
            cell.textArea.delegate = self
            cell.textArea.tag = row
            var idr = variables[row]
            if searchString != nil{
                idr = variables.filter({$0.contains(searchString!)})[row]
            }
            cell.textArea.identifierVar = idr
            cell.textArea.identifierFile = tableColumn!.identifier.lowercased()
            if let fielddata = dict![tableColumn!.identifier.lowercased()], let valor = fielddata[idr]{
                cell.textArea.stringValue = valor
                cell.textArea.backgroundColor = .clear
            }else{
                cell.textArea.backgroundColor = NSColor(red:0.98, green:0.85, blue:0.81, alpha:1.00)
                cell.textArea.stringValue = ""
            }
            
            return cell;
            
        }
        
        
    }
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        let textField:EditableTextField = (obj.object as? EditableTextField)!
        textField.backgroundColor = NSColor(red:0.91, green:0.99, blue:1.00, alpha:1.00)
        if let path = URL(string: self.pathsFile[textField.identifierFile] as! String){
            delegate?.userIsEditing(path: path.absoluteString)
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        
        
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if let textField:EditableTextField = obj.object as? EditableTextField{
            
            //reading and writing to file
            
            
            if let path = URL(string: self.pathsFile[textField.identifierFile] as! String){
                
                if removeOrUpdate(stringInPath:path, identifierVar:textField.identifierVar, stringValue: textField.stringValue, identifierFile: textField.identifierFile) {
                    textField.backgroundColor = .clear
                    self.delegate?.userDidEdit(path: path.absoluteString)
                }else{
                    textField.backgroundColor = .red
                    self.delegate?.userEditDidError(path: path.absoluteString)
                }
                
            }else{
                textField.backgroundColor = .red
            }
            
            
            
            
        }
    }
    
    func removeOrUpdate(stringInPath path:URL, identifierVar:String, stringValue:String, identifierFile:String, remove:Bool = false) -> Bool{
        
        print("------------ FILE EDIT ------------")
        print("pathFile         : \(path.absoluteString)")
        print("varToEdit        : \(identifierVar)")
        print("newValue         : \(stringValue)")
        print("languageFolder   : \(identifierFile)")
        print("remove           : \(remove)")
        
        do {
            let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
            
            let identifier = identifierVar
                .replacingOccurrences(of: "[", with: "\\[")
                .replacingOccurrences(of: "]", with: "\\]")
                .replacingOccurrences(of: "(", with: "\\(")
                .replacingOccurrences(of: ")", with: "\\)")
                .replacingOccurrences(of: "{", with: "\\{")
                .replacingOccurrences(of: "}", with: "\\}")
            
            //Check for string
            let matched = appCore.matches(for: "\"\(identifier)\"[ ]*=[ ]*\"(.*)\";", in: text2)
            
            var newString = ""
            
            //String exists
            if matched.count > 0{
                print("Regex: \"\(identifier)\"[ ]*=[ ]*\"(.*)\"; -> FOUND")
                let regex = try NSRegularExpression(pattern:"\"\(identifier)\"[ ]*=[ ]*\"(.*)\";", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, (text2 as NSString).length)
                newString = regex.stringByReplacingMatches(in: text2, options: [], range: range, withTemplate: (remove) ? "" : "\"\(identifierVar)\" = \"\(stringValue)\";")
                //String do not exists
            }else if !remove{
                print("Regex: \"\(identifier)\"[ ]*=[ ]*\"(.*)\"; -> NOT FOUND")
                newString = text2+"\n"+"\"\(identifierVar)\" = \"\(stringValue)\";"
            }
            
            //Test if dictionary is present
            if let _ = self.dict![identifierFile]{
                if !remove {
                    print("Update dictionary")
                    self.dict![identifierFile]![identifierVar] = stringValue
                }else{
                    print("Remove from dictionary")
                    self.dict![identifierFile]!.removeValue(forKey: identifierVar)
                }
            }else if !remove{
                var newDic = [String:String]()
                newDic[identifierVar] = stringValue
                self.dict![identifierFile] = newDic
                print("Create new item in dictionary")
            }
            
            //Test if there is something to write
            if newString != ""{
                
                do {
                    try newString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                    
                    print("Saved to file!")
                            print("-----------------------------------")
                    
                    return true
                } catch let e{
                    print("Error: \(e)")
                            print("-----------------------------------")
                    return false
                }
                
            }else{
                
                print("Error: EmptyString")
                        print("-----------------------------------")
                return false
            }
            
        }catch let e{
            
            print("Error: \(e)")
                    print("-----------------------------------")
            return false
        }
        
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "addNew") {
            
            // initialize new view controller and cast it as your view controller
            let addNewController = segue.destinationController as? AddNewController
            addNewController?.delegate = self
        }else if (segue.identifier == "search") {
            
            // initialize new view controller and cast it as your view controller
            let addNewController = segue.destinationController as? SearchController
            addNewController?.delegate = self
            if searchString != nil{
                addNewController?.initialSearchString = searchString!
            }
        }
        
        
        
    }
    
    
}

