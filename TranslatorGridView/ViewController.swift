//
//  ViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate,SplitViewDelegate,NSTextFieldDelegate,AddNewDelegate,ToolbarDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var dict:[String:[String:String]]? = [String:Dictionary]()
    var columns:[NSTableColumn] = [NSTableColumn]()
    var currentPath:[String] = [String]()
    var pathsFile: NSMutableDictionary = NSMutableDictionary()
    var variables:[String] = [String]()
    var mainWindow:StartWindowController?
    var delegate:EditingDelegate?
    var gridViewController:GridViewController?
    
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
    
    func newItemDidAdded(name: String) {
        
        //If is not empty, continue
        if name != ""{
            self.variables.append(name)
            self.tableView.reloadData()
            tableView.scrollToEndOfDocument(self)
        }
        
        
    }
    
    func didSelectedFile(atPaths paths: [String]) {
        
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
                _ = appCore.dialogOKCancel(question: "Ok", text: "Errore nel processare il file: \(url!), formato file non valido")
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
        
        return variables.count
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        if (tableColumn!.identifier == "name") {
            
            let cell = tableView.make(withIdentifier: "name", owner: self) as! NSTableCellView
            
            cell.textField!.font = NSFont.boldSystemFont(ofSize: 13)
            cell.textField!.stringValue = " "+variables[row]
            
            return cell;
            
        }else {
            
            let cell = tableView.make(withIdentifier: "value", owner: self) as! EditableCell
            cell.textArea.delegate = self
            cell.textArea.tag = row
            cell.textArea.identifierVar = variables[row]
            cell.textArea.identifierFile = tableColumn!.identifier.lowercased()
            if let fielddata = dict![tableColumn!.identifier.lowercased()], let valor = fielddata[variables[row]]{
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
            DispatchQueue.main.async {
            do {
                if let path = URL(string: self.pathsFile[textField.identifierFile] as! String){
                    
                    let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
                    
                    let identifier = textField.identifierVar
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
                        let regex = try NSRegularExpression(pattern:"\"\(identifier)\"[ ]*=[ ]*\"(.*)\";", options: NSRegularExpression.Options.caseInsensitive)
                        let range = NSMakeRange(0, (text2 as NSString).length)
                        newString = regex.stringByReplacingMatches(in: text2, options: [], range: range, withTemplate: "\"\(textField.identifierVar)\" = \"\(textField.stringValue)\";")
                    //String do not exists
                    }else{
                        newString = text2+"\n"+"\"\(textField.identifierVar)\" = \"\(textField.stringValue)\";"
                        //Test if dictionary is present
                        if let _ = self.dict![textField.identifierFile]{
                            self.dict![textField.identifierFile]![textField.identifierVar] = textField.stringValue
                        }else{
                            var newDic = [String:String]()
                            newDic[textField.identifierVar] = textField.stringValue
                            self.dict![textField.identifierFile] = newDic
                        }
                    }
                    
                    //Test if there is something to write
                    if newString != ""{
            
                        do {
                            try newString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                            textField.backgroundColor = .clear
                            self.delegate?.userDidEdit(path: path.absoluteString)
                        }
                        catch let e{
                            print(e)
                            textField.backgroundColor = .red
                            self.delegate?.userEditDidError(path: path.absoluteString)
                        }
                    }else{
                        textField.backgroundColor = .red
                        self.delegate?.userEditDidError(path: path.absoluteString)
                    }
                    
                }else{
                    textField.backgroundColor = .red
                }
            }
            catch let e {
                print(e)
                textField.backgroundColor = .red
            }
            }
            
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "addNew") {
            
            // initialize new view controller and cast it as your view controller
            let addNewController = segue.destinationController as? AddNewController
            addNewController?.delegate = self
        }
        
        
    }
    
    
}

