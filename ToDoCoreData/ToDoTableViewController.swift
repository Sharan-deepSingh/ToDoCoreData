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
    var category: Categories? {
        didSet {
            fetchToDos()
        }
    }
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchToDos()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoCell
        
        cell.textLabel?.text = toDoList[indexPath.row].title
        cell.accessoryType = toDoList[indexPath.row].isSelected ? .checkmark : .none
        cell.index = indexPath.row
        cell.deleteToDo = { [weak self] index in
            self?.deleteToDo(at: index)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
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
                toDo.hasCategory = self.category
                
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
    
    private func deleteToDo(at index: Int) {
        context?.delete(toDoList[index])
        toDoList.remove(at: index)
        saveContext()
        tableView.reloadData()
    }
    
    @discardableResult private func fetchToDos(with request: NSFetchRequest<ToDo> = ToDo.fetchRequest(), and searchPredicate: NSPredicate? = nil) -> [ToDo] {
        let predicate = NSPredicate(format: "hasCategory.title MATCHES %@", category?.title ?? "")
        
        if let sp = searchPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, sp])
        } else {
            request.predicate = predicate
        }
                
        do {
            let toDos = try context?.fetch(request)
            toDoList = toDos ?? []
            tableView.reloadData()

            return toDos ?? []
        } catch {
            print("Got some error while fetching data, Reason: \(error.localizedDescription)")
            return []
        }
    }
    
    private func saveContext(completion: ((String) -> Void)? = nil) {
        if let context = context {
            do {
                try context.save()
                completion?("Success")
            } catch {
                completion?("Error in saving context, Reason: \(error.localizedDescription)")
            }
        }
    }
}

extension ToDoTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !(searchBar.text?.isEmpty ?? true) {
            let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
            /// [cd] means case and diacritic insensetive (Diacritic means jida k a and à will be treated as same some languages use these diacritics)
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            /// This is used to apply some sort order on request
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            fetchToDos(with: request, and: predicate)
        } else {
            fetchToDos()
            searchBar.resignFirstResponder()
        }
    }
}
