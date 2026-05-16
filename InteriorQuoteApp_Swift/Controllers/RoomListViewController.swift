//
//  RoomListViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore

class RoomListViewController: UIViewController {

    var property: Property!

    private let db = Firestore.firestore()
    private var rooms: [Room] = []
    private var filteredRooms: [Room] = []

    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    private let searchController = UISearchController(searchResultsController: nil)

    private var isSearching: Bool {
        let text = searchController.searchBar.text ?? ""
        return searchController.isActive && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = property.propertyName
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        setupSearchBar()
        fetchRooms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRooms()
    }
    
    private func confirmDeleteRoom(_ room: Room) {
        let alert = UIAlertController(
            title: "Delete Room?",
            message: "This will delete \(room.name), including its windows and floor details. This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteRoom(room)
        })

        present(alert, animated: true)
    }

    private func deleteRoom(_ room: Room) {
        let roomRef = db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(room.id)

        let group = DispatchGroup()

        group.enter()
        deleteSubcollection(roomRef.collection("windows")) {
            group.leave()
        }

        group.enter()
        deleteSubcollection(roomRef.collection("floors")) {
            group.leave()
        }

        group.notify(queue: .main) {
            roomRef.delete { error in
                if let error = error {
                    self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                    return
                }

                self.rooms.removeAll { $0.id == room.id }
                self.filteredRooms.removeAll { $0.id == room.id }

                self.updateEmptyState()
                self.tableView.reloadData()
            }
        }
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

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoomTapped)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(RoomCell.self, forCellReuseIdentifier: "RoomCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 105
        
        tableView.backgroundColor = .clear

        emptyLabel.text = "No rooms added yet.\nTap + to add the first room."
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 17)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search rooms"
        searchController.searchBar.sizeToFit()

        tableView.tableHeaderView = searchController.searchBar

        definesPresentationContext = true
    }

    private func fetchRooms() {
        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    self.showAlert(title: "Loading Failed", message: error.localizedDescription)
                    return
                }

                self.rooms = snapshot?.documents.compactMap { document in
                    let data = document.data()

                    guard let name = data["name"] as? String else {
                        return nil
                    }

                    return Room(
                        id: document.documentID,
                        name: name,
                        imageUrl: data["imageUrl"] as? String
                    )
                } ?? []

                self.filteredRooms = self.rooms
                self.updateEmptyState()
                self.tableView.reloadData()
            }
    }

    private func updateEmptyState() {
        let visibleRooms = isSearching ? filteredRooms : rooms

        if rooms.isEmpty {
            emptyLabel.text = "No rooms added yet.\nTap + to add the first room."
            emptyLabel.isHidden = false
        } else if visibleRooms.isEmpty {
            emptyLabel.text = "No matching rooms found."
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
    }

    @objc private func addRoomTapped() {
        let addRoomVC = AddRoomViewController()
        addRoomVC.property = property
        navigationController?.pushViewController(addRoomVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RoomListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredRooms.count : rooms.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RoomCell",
            for: indexPath
        ) as? RoomCell else {
            return UITableViewCell()
        }

        let room = isSearching ? filteredRooms[indexPath.row] : rooms[indexPath.row]

        cell.configure(with: room)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedRoom = isSearching
            ? filteredRooms[indexPath.row]
            : rooms[indexPath.row]

        let addRoomVC = AddRoomViewController()
        addRoomVC.property = property
        addRoomVC.roomToEdit = selectedRoom

        navigationController?.pushViewController(addRoomVC, animated: true)
    }
}

extension RoomListViewController: RoomCellDelegate {
    func didTapDelete(room: Room) {
        confirmDeleteRoom(room)
    }
}

extension RoomListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?
            .lowercased()
            .trimmingCharacters(in: .whitespaces),
              !searchText.isEmpty else {
            filteredRooms = rooms
            updateEmptyState()
            tableView.reloadData()
            return
        }

        filteredRooms = rooms.filter { room in
            room.name.lowercased().contains(searchText)
        }

        updateEmptyState()
        tableView.reloadData()
    }
}
