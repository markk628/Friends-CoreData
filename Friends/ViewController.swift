//
//  ViewController.swift
//  Friends
//
//  Created by Mark Kim on 9/8/20.
//  Copyright © 2020 Mark Kim. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var people: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var managedContext: NSManagedObjectContext = {
        return appDelegate.persistentContainer.viewContext
    }()
    
    lazy var friendTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Friends"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        setUpFriendTableView()
        fetchObject()
    }
    
    func setUpFriendTableView() {
        view.addSubview(friendTableView)
        
        NSLayoutConstraint.activate([
            friendTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            friendTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            friendTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            friendTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func save(name: String, age: String, birthday: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        person.setValue(age, forKey: "age")
        person.setValue(birthday, forKey: "birthday")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
    
    func fetchObject() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @objc func addTapped() {
        var nameTextField: UITextField?
        var ageTextField: UITextField?
        var birthdayTextField: UITextField?
        
        let alert = UIAlertController(title: "New Friend", message: "Add information about your friend", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add Now", style: .default) { [unowned self] action in
            guard let friendName = nameTextField?.text, let friendAge = ageTextField?.text, let friendBirthday = birthdayTextField?.text else { return }
            self.save(name: friendName, age: friendAge, birthday: friendBirthday)
            self.friendTableView.reloadData()
        }
        
        alert.addTextField { (friendNameTextField) in
            nameTextField = friendNameTextField
            nameTextField?.placeholder = "Name"
        }
        
        alert.addTextField { (friendAgeTextField) in
            ageTextField = friendAgeTextField
            ageTextField?.placeholder = "Age"
        }
        
        alert.addTextField { (friendBirthdayTextField) in
            birthdayTextField = friendBirthdayTextField
            birthdayTextField?.placeholder = "Birthday"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(person.value(forKey: "name") ?? "") \(person.value(forKey: "age") ?? "") \(person.value(forKey: "birthday") ?? "")"
        return cell
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let person = people[indexPath.row]
            
            do {
                managedContext.delete(person)
                try managedContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
                people.remove(at: indexPath.row)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
    }

}
