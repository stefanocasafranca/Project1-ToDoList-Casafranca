//
//  ToDoTableViewController.swift
//  Project1-ToDoList-Casafranca
//
//  Created by Stefano Casafranca on 3/30/25.
//



//The ToDoCellDelegate method checkmarkTapped is implemented to toggle the isComplete status of a to-do when the cell’s checkmark button is tapped, and then update the row. Swipe-to-delete is enabled via commit editingStyle.

//We also implement UISearchResultsUpdating to filter the todos array based on the search text and reload the table.

import UIKit // Import UI kit for UI elements

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {

    var todos = [ToDo]() // Main list of to-dos
    private var filteredTodos = [ToDo]() // List for search results
    let searchController = UISearchController(searchResultsController: nil) // Manages search bar

    // Returns true if search bar text is empty
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    // Returns true if search is active and there's text in the search bar
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    //Explanation: In viewDidLoad, we set up an Edit button (provided by editButtonItem) on the left and configure the search controller. We load saved to-dos if available, otherwise load some sample to-dos.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem // Adds Edit button on left
        setupSearchBar() // Configure search bar settings
        // Load saved to-dos; if none, load sample to-dos
        if let savedToDos = ToDo.loadToDos() {
            todos = savedToDos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        
    }

    //The unwindToToDoList IBAction handles returning from the detail screen — if a to-do was passed back, it updates the existing item or adds a new one, then saves the list.
    
    
    
    //Referencing the selector in the Unwind from the Save Button in Detail bringing it to the list of ToDo's
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return } // Only act on Save
        let sourceViewController = segue.source as! ToDoDetailTableViewController

        if let todo = sourceViewController.todo {
            if let indexOfExistingToDo = todos.firstIndex(of: todo) {
                // Update existing to-do
                todos[indexOfExistingToDo] = todo
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
                // Add new to-do at end of list
                let newIndexPath = IndexPath(row: todos.count, section: 0)
                todos.append(todo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(todos) // Persist updated list
    }

    //The @IBSegueAction func editToDo is used for editing an existing to-do when a cell is tapped; it finds the tapped item (accounting for search filtering), deselects the cell, and initializes a ToDoDetailTableViewController with that item.
    
   
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        // Called when editing an existing to-do via cell tap
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        let todo: ToDo
        // Use filtered list if search is active
        if isFiltering {
            todo = filteredTodos[indexPath.row]
        } else {
            todo = todos[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the cell
        let detailController = ToDoDetailTableViewController(coder: coder)
        detailController?.todo = todo // Pass the selected to-do to detail screen
        return detailController
    }
    
    

    private func setupSearchBar() {
        navigationItem.searchController = searchController // Embed search bar in nav bar
        searchController.searchBar.delegate = self // Set delegate for search bar events
        navigationController?.navigationBar.prefersLargeTitles = true // Use large titles
        searchController.obscuresBackgroundDuringPresentation = false // Keep background visible during search
        searchController.searchResultsUpdater = self // Update search results as user types
        searchController.searchBar.placeholder = "Search" // Set search bar placeholder text
        definesPresentationContext = true // Limit search to current context
    }

    
    
  
    
    // MARK: - ToDoCellDelegate
    // Called when checkmark button in a cell is tapped
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var todo = todos[indexPath.row]
            todo.isComplete.toggle() // Toggle completion state
            todos[indexPath.row] = todo
            tableView.reloadRows(at: [indexPath], with: .automatic) // Refresh cell UI
        }
        ToDo.saveToDos(todos) // Save changes
    }

    // MARK: - Table view data source
    // The table view data source methods handle showing either the full list or filtered list when searching.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return filtered count if search is active; else return all to-dos
        return isFiltering ? filteredTodos.count : todos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with our identifier and cast to ToDoCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
        let todo: ToDo = isFiltering ? filteredTodos[indexPath.row] : todos[indexPath.row]
        cell.delegate = self // Set cell delegate to self
        cell.titleLabel.text = todo.title // Display to-do title
        cell.isCompleteButton.isSelected = todo.isComplete // Set checkmark state
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Enable row editing (for delete)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todos.remove(at: indexPath.row) // Remove to-do from list
            tableView.deleteRows(at: [indexPath], with: .automatic) // Animate row deletion
            ToDo.saveToDos(todos) // Save updated list
        }
    }
}

// MARK: - Search capabilities in the array

//Part 1: Very Nice extension --> Search Mode

extension ToDoTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Print search text; can be used for debugging or extra handling
        print(searchText)
    }
}


//Part 2: Very Nice extension --> Search Mode

extension ToDoTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Update filtered results as search text changes
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        // Filter todos based on search text (case-insensitive)
        filteredTodos = todos.filter { todo in
            return todo.title.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData() // Refresh table with filtered todos
    }
}



    /* EXTRA NOT NEEDED
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


