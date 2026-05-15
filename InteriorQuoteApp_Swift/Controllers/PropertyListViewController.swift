//
//  PropertyListViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore

class PropertyListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var properties: [Property] = []
    private var filteredProperties: [Property] = []

    private let searchController = UISearchController(searchResultsController: nil)

    private var isSearching: Bool {
        let text = searchController.searchBar.text ?? ""
        return searchController.isActive && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "Properties"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PropertyCell.self, forCellReuseIdentifier: "PropertyCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPropertyTapped)
        )

        setupSearchBar()
        fetchProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProperties()
    }

    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search properties, owners, or location"
        searchController.searchBar.sizeToFit()

        tableView.tableHeaderView = searchController.searchBar

        definesPresentationContext = true
    }

    private func fetchProperties() {
        db.collection("properties")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    self.showAlert(title: "Loading Failed", message: error.localizedDescription)
                    return
                }

                let documents = snapshot?.documents ?? []

                var loadedProperties: [Property] = []

                let group = DispatchGroup()

                for document in documents {

                    let data = document.data()

                    guard let propertyName = data["propertyName"] as? String,
                          let ownerFirstName = data["ownerFirstName"] as? String,
                          let ownerLastName = data["ownerLastName"] as? String,
                          let ownerGender = data["ownerGender"] as? String,
                          let addressLine = data["addressLine"] as? String,
                          let city = data["city"] as? String,
                          let state = data["state"] as? String,
                          let country = data["country"] as? String,
                          let zipCode = data["zipCode"] as? String else {
                        continue
                    }

                    group.enter()

                    self.db.collection("properties")
                        .document(document.documentID)
                        .collection("rooms")
                        .getDocuments { roomSnapshot, _ in

                            let roomCount = roomSnapshot?.documents.count ?? 0

                            let property = Property(
                                id: document.documentID,
                                propertyName: propertyName,
                                ownerFirstName: ownerFirstName,
                                ownerMiddleName: data["ownerMiddleName"] as? String,
                                ownerLastName: ownerLastName,
                                ownerGender: ownerGender,
                                addressLine: addressLine,
                                city: city,
                                state: state,
                                country: country,
                                roomCount: roomCount,
                                zipCode: zipCode
                            )

                            loadedProperties.append(property)

                            group.leave()
                        }
                }

                group.notify(queue: .main) {
                    self.properties = loadedProperties
                    self.filteredProperties = loadedProperties
                    self.tableView.reloadData()
                }
            }
    }

    @objc private func addPropertyTapped() {
        let addPropertyVC = AddPropertyViewController()
        navigationController?.pushViewController(addPropertyVC, animated: true)
    }

    private func openEditProperty(_ property: Property) {
        let editVC = AddPropertyViewController()
        editVC.propertyToEdit = property
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func confirmDeleteProperty(_ property: Property) {
        let alert = UIAlertController(
            title: "Delete Property?",
            message: "This will delete \(property.propertyName). This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteProperty(property)
        })

        present(alert, animated: true)
    }

    private func deleteSubcollection(_ collection: CollectionReference,
                                     completion: @escaping () -> Void) {
        collection.getDocuments { snapshot, error in
            guard error == nil else {
                completion()
                return
            }

            let group = DispatchGroup()

            snapshot?.documents.forEach { document in
                group.enter()
                document.reference.delete { _ in
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion()
            }
        }
    }

    private func deleteProperty(_ property: Property) {
        let propertyRef = db.collection("properties").document(property.id)
        let roomsRef = propertyRef.collection("rooms")

        roomsRef.getDocuments { roomSnapshot, error in
            if let error = error {
                self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                return
            }

            let group = DispatchGroup()

            roomSnapshot?.documents.forEach { roomDocument in
                let roomRef = roomsRef.document(roomDocument.documentID)

                group.enter()
                self.deleteSubcollection(roomRef.collection("windows")) {
                    group.leave()
                }

                group.enter()
                self.deleteSubcollection(roomRef.collection("floors")) {
                    group.leave()
                }

                group.enter()
                roomRef.delete { _ in
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                propertyRef.delete { error in
                    if let error = error {
                        self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                        return
                    }

                    self.properties.removeAll { $0.id == property.id }
                    self.filteredProperties.removeAll { $0.id == property.id }
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PropertyListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredProperties.count : properties.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PropertyCell",
            for: indexPath
        ) as? PropertyCell else {
            return UITableViewCell()
        }

        let property = isSearching ? filteredProperties[indexPath.row] : properties[indexPath.row]

        cell.configure(with: property)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedProperty = isSearching ? filteredProperties[indexPath.row] : properties[indexPath.row]

        let roomListVC = RoomListViewController()
        roomListVC.property = selectedProperty

        navigationController?.pushViewController(roomListVC, animated: true)
    }
}

extension PropertyListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?
            .lowercased()
            .trimmingCharacters(in: .whitespaces),
              !searchText.isEmpty else {
            filteredProperties = properties
            tableView.reloadData()
            return
        }

        filteredProperties = properties.filter { property in
            property.propertyName.lowercased().contains(searchText) ||
            property.ownerFirstName.lowercased().contains(searchText) ||
            property.ownerLastName.lowercased().contains(searchText) ||
            property.city.lowercased().contains(searchText) ||
            property.state.lowercased().contains(searchText) ||
            property.country.lowercased().contains(searchText) ||
            property.zipCode.lowercased().contains(searchText)
        }

        tableView.reloadData()
    }
}

extension PropertyListViewController: PropertyCellDelegate {

    func didTapEdit(property: Property) {
        openEditProperty(property)
    }

    func didTapDelete(property: Property) {
        confirmDeleteProperty(property)
    }
}
