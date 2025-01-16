//
//  CategoriesTableViewController.swift
//  ToDoCoreData
//
//  Created by Sharandeep Singh on 12/01/25.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {

    var categories: [Categories] = []
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categories = getCategories()
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 211/255, green: 57/255, blue: 81/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @IBAction func deleteCategory(_ sender: UIButton) {
        context?.delete(categories[sender.tag])
        categories.remove(at: sender.tag)
        saveContext()
        tableView.reloadData()
    }
    
    @IBAction func addNewCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var globalTextField = UITextField()
        let alertController = UIAlertController(title: "Add Category", message: "Please add category below", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Add Category"
            globalTextField = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { _ in
            if let context = self.context {
                let category = Categories(context: context)
                category.title = globalTextField.text
                self.categories.append(category)
            }
            self.saveContext()
            self.tableView.reloadData()
        }
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    //MARK: - Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell")!
        cell.textLabel?.text = categories[indexPath.row].title
        cell.tag = indexPath.row
        
        return cell
    }
    
    //MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCatagory = categories[indexPath.row]
        
        /// Method 1
//        performSegue(withIdentifier: "toDoSegue", sender: self)
        
        /// Method 2
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "MainStoryboard") {
//            navigationController?.pushViewController(vc, animated: true)
//        }
        
        /// Mthod 3
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainStoryboard") as! ToDoTableViewController
        vc.category = selectedCatagory
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCategories() -> [Categories] {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        do {
            let data = try context?.fetch(request)
            if let data = data {
                return data
            } else {
                return []
            }
        } catch {
            print("Error in fetching data")
            return []
        }
    }
    
    func saveContext() {
        do {
            try context?.save()
            print("saved")
        } catch {
            print("context error")
        }
    }
}
