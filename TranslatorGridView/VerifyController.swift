//
//  AddNewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class VerifyController: NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate{
    
    var parentController:StringsViewController?
    var simil:SimilString?
    var mapped:[SimilString] = [SimilString]()
    var searchString:String        = ""
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var androidString: NSTextField!
    @IBOutlet weak var androidValue: NSTextField!
    @IBOutlet weak var iosString: NSTextField!
    @IBOutlet weak var iosValue: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var checkMatch: NSButton!
    
    
    @IBAction func accept(_ sender: Any) {
        
        parentController!.mapped[simil!.android_var] = simil!.ios_var
        parentController!.tableView!.reloadData()
        parentController?.matchLabel.stringValue = "\(parentController!.mapped.count)"
        parentController?.createMap(self)
        self.dismiss(self)
        
    }
    
    @IBAction func discard(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func change(_ sender: Any) {
        buildIOSVars()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        searchField.delegate        = self
        
        tableView.delegate          = self
        tableView.dataSource        = self
        
        iosValue!.isEditable        = false
        androidValue!.isEditable    = false

        updateValues()
        buildIOSVars()
        tableView.reloadData()
        
    }
    
    func updateValues(){
        
        androidString.stringValue   = "ANDROID NAME: \(simil!.android_var)"
        iosString.stringValue       = "IOS NAME: \(simil!.ios_var)"
        iosValue.stringValue        = simil!.ios_value
        androidValue.stringValue    = simil!.android_value
    }
    
    func buildIOSVars(){
        mapped.removeAll()
        for(k,v) in parentController!.dictIOS{
  
            let pp = parentController!.wordsDis(w1: simil!.android_value, w2: v)
            
            let add = (checkMatch.state == 0) ? true : (pp > 0)
            
            if add {
                mapped.append(SimilString(ios_var: k, ios_val: v, android_var: simil!.android_var, android_val: simil!.android_value, distance: pp))
            }
            
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

    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return (searchString == "") ? mapped.count : mapped.filter({$0.ios_value.lowercased().contains(searchString.lowercased()) || $0.ios_var.lowercased().contains(searchString.lowercased())}).count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var ar = (searchString == "") ? mapped : mapped.filter({$0.ios_value.lowercased().contains(searchString.lowercased()) || $0.ios_var.lowercased().contains(searchString.lowercased())})
        
        if tableColumn!.identifier == "match"{
            let cell = tableView.make(withIdentifier: "string", owner: self) as! NSTableCellView
            cell.textField?.stringValue = "\(ar[row].distance)"
            return cell
        }else if tableColumn!.identifier == "var"{
            let cell = tableView.make(withIdentifier: "var", owner: self) as! NSTableCellView
            cell.textField!.attributedStringValue = appCore.getColoredText(text: ar[row].ios_var, search: simil!.android_var.components(separatedBy: " "))
            return cell
        }else{
            let cell = tableView.make(withIdentifier: "point", owner: self) as! NSTableCellView
            
            cell.textField!.attributedStringValue = appCore.getColoredText(text: ar[row].ios_value, search: simil!.android_value.components(separatedBy: " ").filter({$0.characters.count > 2}))

            return cell
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            // we create an [Int] array from the index set
            let selected = myTable.selectedRowIndexes.map { Int($0) }
            if let id = selected.first{
                var ar = (searchString == "") ? mapped : mapped.filter({$0.ios_value.lowercased().contains(searchString.lowercased()) || $0.ios_var.lowercased().contains(searchString.lowercased())})
                let sim = ar[id]
                simil!.ios_var = sim.ios_var
                simil!.ios_value = sim.ios_value
                updateValues()
            }
            
            
          
            
        }
    }
    
}
