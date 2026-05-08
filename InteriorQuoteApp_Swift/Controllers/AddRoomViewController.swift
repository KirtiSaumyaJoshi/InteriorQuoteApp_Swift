//
//  AddRoomViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 6/5/2026.
//

import UIKit
import FirebaseFirestore

class AddRoomViewController: UIViewController {

    var property: Property!

    private let db = Firestore.firestore()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let roomNameField = UITextField()

    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Room"
        view.backgroundColor = .systemGroupedBackground

        setupUI()
    }

    private func setupUI() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(saveButton)

        stackView.axis = .vertical
        stackView.spacing = 18

        let headerLabel = UILabel()
        headerLabel.text = "Manage room measurements"
        headerLabel.font = .boldSystemFont(ofSize: 32)
        headerLabel.numberOfLines = 0

        let helperLabel = UILabel()
        helperLabel.text = "Add windows, floor dimensions, and selected products for this room."
        helperLabel.font = .systemFont(ofSize: 18)
        helperLabel.textColor = .secondaryLabel
        helperLabel.numberOfLines = 0

        let roomCard = createCardView()

        let roomTitle = UILabel()
        roomTitle.text = "Room information"
        roomTitle.font = .boldSystemFont(ofSize: 24)

        let roomHelper = UILabel()
        roomHelper.text = "Give this room a clear name, such as Living Room or Bedroom 1."
        roomHelper.font = .systemFont(ofSize: 16)
        roomHelper.textColor = .secondaryLabel
        roomHelper.numberOfLines = 0

        roomNameField.placeholder = "Room name"
        roomNameField.borderStyle = .roundedRect
        roomNameField.font = .systemFont(ofSize: 18)
        roomNameField.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let roomStack = UIStackView(arrangedSubviews: [
            roomTitle,
            roomHelper,
            roomNameField
        ])

        roomStack.axis = .vertical
        roomStack.spacing = 16

        roomCard.addSubview(roomStack)

        roomStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            roomStack.topAnchor.constraint(equalTo: roomCard.topAnchor, constant: 24),
            roomStack.leadingAnchor.constraint(equalTo: roomCard.leadingAnchor, constant: 24),
            roomStack.trailingAnchor.constraint(equalTo: roomCard.trailingAnchor, constant: -24),
            roomStack.bottomAnchor.constraint(equalTo: roomCard.bottomAnchor, constant: -24)
        ])

        saveButton.setTitle("Save Room Name", for: .normal)
        saveButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.25)
        saveButton.setTitleColor(.systemIndigo, for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        saveButton.layer.cornerRadius = 18
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        saveButton.addTarget(self, action: #selector(saveRoomTapped), for: .touchUpInside)

        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(helperLabel)
        stackView.addArrangedSubview(roomCard)

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),

            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func saveRoomTapped() {

        let roomName = roomNameField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if roomName.isEmpty {
            showAlert(
                title: "Room Name Required",
                message: "Please enter a room name before saving."
            )
            return
        }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .addDocument(data: [
                "name": roomName,
                "createdAt": Timestamp(date: Date())
            ]) { error in

                if let error = error {
                    self.showAlert(
                        title: "Save Failed",
                        message: error.localizedDescription
                    )
                    return
                }

                self.navigationController?.popViewController(animated: true)
            }
    }

    private func createCardView() -> UIView {

        let card = UIView()

        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 28

        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 10

        return card
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
