//
//  ViewController.swift
//  ToDoCoreData
//
//  Created by Sharandeep Singh on 08/12/24.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {

    //MARK: - Properties
    var toDoList: [ToDo] = []
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoList = fetchAllToDos()
        
        /// Code to print path for user defaults file
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 211/255, green: 57/255, blue: 81/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - TableView DataSource and Delegate Overriden Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        
        cell.textLabel?.text = toDoList[indexPath.row].title
        cell.accessoryType = toDoList[indexPath.row].isSelected ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark

        /// Update selection on DB
        toDoList[indexPath.row].isSelected.toggle()
        saveContext { feedBack in
            print(feedBack)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - IBOutlets
    @IBAction func addNewToDoButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Enter ToDo", message: nil, preferredStyle: .alert)
        alert.addTextField { localTextField in
            localTextField.placeholder = "Enter Task..."
            textField = localTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            if let context = self.context {
                let toDo = ToDo(context: context)
                toDo.title = textField.text
                toDo.isSelected = false
                
                self.toDoList.append(toDo)
                self.saveContext { feedBack in
                    self.showAlert(title: feedBack)
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func fetchAllToDos() -> [ToDo] {
        if let toDos = fetchToDos() {
            return toDos
        }
        
        return []
    }
    
    private func fetchToDos() -> [ToDo]? {
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        do {
            let toDos = try context?.fetch(request)
            return toDos
        } catch {
            print("Got some error while fetching data, Reason: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveContext(completion: (String) -> Void) {
        if let context = context {
            do {
                try context.save()
                completion("Success")
            } catch {
                completion("Error in saving context, Reason: \(error.localizedDescription)")
            }
        }
    }
}
