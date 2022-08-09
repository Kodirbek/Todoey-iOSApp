//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Abduqodir's MacPro on 2022/05/03.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var toDoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //searchBar.delegate = self
        // While assigning current view controller as the UISearchBar's delegate, we have to do 2 steps: creating a new instant for UISearchBar (let = searchBar = UISearchBar, ln 15), then declaring the view controller as its delegate in viewDidLoad method. Instead, in storyboard, we can just 'control'+right click, hold and drag it to viewController sign (tiny white square in yellow circle above the screen of device) and choose delegate.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let hexColor = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist")}
            
            if let navBarColor = UIColor(hexString: hexColor) {
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.backgroundColor = navBarColor
                searchBar.barTintColor = navBarColor.lighten(byPercentage: 0.8)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
            }
            
        }
    }
    
    //MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
    
            //Ternary operator:
            // value              = condition         ? valueIfTrue : valueIfFalse
            // cell.accessoryType = item.done == true ? .checkmark : .none
            // this line can be shortened as so:
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        // These two lines are used to delete a specified object. The order is super important, otherwise when itemArray's object is deleted first, the same index can't be found in the context and so the app crashesh with "index is out of range" fatal error. In CRUD, except for Reading the data, all three remaining parts require us to use save (context.save) command, like committing changes in git.
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
//                    realm.delete(item) (this is how we delete the selected object in Realm.)
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let selectedItem = toDoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(selectedItem)
                }
            } catch {
                print("Error deleteing the item, \(error)")
            }
        }
    }
            
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            //searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
            // This line also dismisses keyboard, but with 0.1 second delay
        }
    }

}
