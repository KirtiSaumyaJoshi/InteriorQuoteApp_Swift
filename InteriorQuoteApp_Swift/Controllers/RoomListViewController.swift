import UIKit
import FirebaseFirestore

class RoomListViewController: UIViewController {

    var property: Property!

    private let db = Firestore.firestore()
    private var rooms: [Room] = []

    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = property.propertyName
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        fetchRooms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRooms()
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoomCell")
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

                self.emptyLabel.isHidden = !self.rooms.isEmpty
                self.tableView.reloadData()
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
        return rooms.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RoomCell")
        let room = rooms[indexPath.row]

        cell.textLabel?.text = room.name
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.text = "Tap to manage windows, floors, photo and quote"
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Next stage: open room details page
        print("Selected room: \(rooms[indexPath.row].name)")
    }
}
