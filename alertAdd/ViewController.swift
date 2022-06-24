//
//  ViewController.swift
//  alertAdd
//
//  Created by İbrahim Ballıbaba on 19.06.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var alertController = UIAlertController()
    //Entity nin kod tarafında karşılığı olan  veritipi NSManagedObject
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        fetch()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
        
    }
    
    @IBAction func didRemoveBarButtonItem(_ sender: UIBarButtonItem){
        
        presentAlert(title: "Warning!",
                     message: "Are you sure delete all elements?",
                     defaultButtonTitle: "Yes",
                     cancelButtonTitle: "No") { _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let menagedObjectContext = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try menagedObjectContext!.execute(deleteRequest)
                } catch let error as NSError {
                    debugPrint(error)
                }
    
            self.data.removeAll()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func didTappedButtonItem(_ sender: UIBarButtonItem){
        
        presentAddAlert()
        
    }
    
    func presentAddAlert(){
        
        presentAlert(title: "Add new elements",
                     message: nil,
                     defaultButtonTitle: "Add",
                     cancelButtonTitle: "Cancel",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                //NSManagedObjectContext e ulaşmamız gerekiyor bu bizim coreData da veritabanımız...
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                // aşağıdaki let aslında bizim veritabanımız
                let menagedObjectContext = appDelegate?.persistentContainer.viewContext
                // burada da veritabanına kaydedeceğimiz entity i oluşturacağız.
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: menagedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: menagedObjectContext)
                listItem.setValue(text, forKey: "title")
                
              try? menagedObjectContext?.save()
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
                
                self.data = try! menagedObjectContext!.fetch(fetchRequest)
                
                self.tableView.reloadData()
              //  self.data.append(text!)
                
            }else {
                self.presentWarningAlert()
            }
            
        })
        
        
    }
    
    func presentWarningAlert(){
        
        presentAlert(title: "Warning!",
                     message: "This area cant be nil",
                     cancelButtonTitle: "OK")
        
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      prefferdStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil){
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: prefferdStyle)
        
        if defaultButtonTitle != nil{
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFieldAvailable{
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let menagedObjectContext = appDelegate?.persistentContainer.viewContext
            
            menagedObjectContext?.delete(self.data[indexPath.row])
            try? menagedObjectContext?.save()
            
          //  self.data.remove(at: indexPath.row)
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
            
            self.data = try! menagedObjectContext!.fetch(fetchRequest)
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let fixAction = UIContextualAction(style: .normal, title: "Fix") { _, _, _ in
            
            self.presentAlert(title: "Fix elements",
                         message: nil,
                         defaultButtonTitle: "Fix",
                         cancelButtonTitle: "Cancel",
                         isTextFieldAvailable: true,
                         defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let menagedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if ((menagedObjectContext?.hasChanges) != nil){
                       try? menagedObjectContext?.save()
                    }
                    //self.data[indexPath.row] = text!
                    self.tableView.reloadData()
                }else {
                    self.presentWarningAlert()
                }
                
            })
        }
        
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction, fixAction])
        return swipe
    }
    
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let menagedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! menagedObjectContext!.fetch(fetchRequest)
        self.tableView.reloadData()
    }
}

