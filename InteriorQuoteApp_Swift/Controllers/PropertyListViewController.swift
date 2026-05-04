import UIKit
import FirebaseFirestore

class PropertyListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var properties: [Property] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Properties"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PropertyCell.self, forCellReuseIdentifier: "PropertyCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPropertyTapped)
        )

        fetchProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProperties()
    }

    private func fetchProperties() {
        db.collection("properties")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    self.showAlert(title: "Loading Failed", message: error.localizedDescription)
                    return
                }

                self.properties = snapshot?.documents.compactMap { document in
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
                        return nil
                    }

                    return Property(
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
                        zipCode: zipCode
                    )
                } ?? []

                self.tableView.reloadData()
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

    private func deleteProperty(_ property: Property) {
        db.collection("properties").document(property.id).delete { error in
            if let error = error {
                self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                return
            }

            self.properties.removeAll { $0.id == property.id }
            self.tableView.reloadData()
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
        return properties.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PropertyCell",
            for: indexPath
        ) as? PropertyCell else {
            return UITableViewCell()
        }

        let property = properties[indexPath.row]
        cell.configure(with: property)
        cell.delegate = self
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Next stage: open rooms for selected property
        print("Open rooms for: \(properties[indexPath.row].propertyName)")
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
