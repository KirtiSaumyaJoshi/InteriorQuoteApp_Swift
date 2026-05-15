//
//  AddRoomViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore

class AddRoomViewController: UIViewController {

    var property: Property!

    private let db = Firestore.firestore()
    private var savedRoomId: String?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let roomNameField = UITextField()

    private let saveNameButton = UIButton(type: .system)
    private let photoButton = UIButton(type: .system)
    private let addWindowButton = UIButton(type: .system)
    private let addFloorButton = UIButton(type: .system)
    private let saveRoomDetailsButton = UIButton(type: .system)
    var roomToEdit: Room?
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Room"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        populateRoomIfEditing()
        roomNameField.addTarget(self, action: #selector(roomNameChanged), for: .editingChanged)
    }
    private func populateRoomIfEditing() {
        guard let room = roomToEdit else { return }

        title = "Manage Room"

        savedRoomId = room.id
        roomNameField.text = room.name

        saveNameButton.setTitle("Update Room Name", for: .normal)
        saveNameButton.isHidden = true
    }
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveRoomDetailsButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(saveRoomDetailsButton)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 18

        let header = createLabel(
            text: "Manage room measurements",
            size: 30,
            weight: .bold,
            color: .label
        )

        let helper = createLabel(
            text: "Save the room name first, then add a photo, windows, and floor details.",
            size: 17,
            weight: .regular,
            color: .secondaryLabel
        )

        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(helper)

        setupRoomInfoSection()
        setupPhotoSection()
        setupWindowSection()
        setupFloorSection()
        setupBottomSaveButton()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveRoomDetailsButton.topAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            saveRoomDetailsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveRoomDetailsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveRoomDetailsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveRoomDetailsButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func setupRoomInfoSection() {
        let card = createCardView()

        let title = createLabel(text: "Room information", size: 24, weight: .bold, color: .label)
        let helper = createLabel(
            text: "Give this room a clear name, such as Living Room or Bedroom 1.",
            size: 16,
            weight: .regular,
            color: .secondaryLabel
        )

        roomNameField.placeholder = "Room name"
        roomNameField.borderStyle = .roundedRect
        roomNameField.heightAnchor.constraint(equalToConstant: 52).isActive = true

        stylePrimaryButton(saveNameButton, title: "Save Room Name")
        saveNameButton.addTarget(self, action: #selector(saveRoomNameTapped), for: .touchUpInside)

        addContent([title, helper, roomNameField, saveNameButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupPhotoSection() {
        let card = createCardView()

        let title = createLabel(text: "Room photo", size: 24, weight: .bold, color: .label)
        let helper = createLabel(
            text: "Add a photo of this room for reference. Save the room name first before adding a photo.",
            size: 16,
            weight: .regular,
            color: .secondaryLabel
        )

        styleOutlineButton(photoButton, title: "Add / Change Photo")
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)

        addContent([title, helper, photoButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupWindowSection() {
        let card = createCardView()

        let title = createLabel(text: "Windows", size: 24, weight: .bold, color: .label)
        let helper = createLabel(
            text: "Add each window space and assign a compatible window product.",
            size: 16,
            weight: .regular,
            color: .secondaryLabel
        )

        styleOutlineButton(addWindowButton, title: "Add Window +")
        addWindowButton.addTarget(self, action: #selector(addWindowTapped), for: .touchUpInside)

        addContent([title, helper, addWindowButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupFloorSection() {
        let card = createCardView()

        let title = createLabel(text: "Floor details", size: 24, weight: .bold, color: .label)
        let helper = createLabel(
            text: "Enter one floor space for this room and choose a flooring product.",
            size: 16,
            weight: .regular,
            color: .secondaryLabel
        )

        styleOutlineButton(addFloorButton, title: "Add Floor Details")
        addFloorButton.addTarget(self, action: #selector(addFloorTapped), for: .touchUpInside)

        addContent([title, helper, addFloorButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupBottomSaveButton() {
        stylePrimaryButton(saveRoomDetailsButton, title: "Save Room Details")
        saveRoomDetailsButton.addTarget(self, action: #selector(saveRoomDetailsTapped), for: .touchUpInside)
    }

    @objc private func saveRoomNameTapped() {
        let roomName = roomNameField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if roomName.isEmpty {
            showAlert(
                title: "Room Name Required",
                message: "Please enter a room name before saving."
            )
            return
        }

        let roomData: [String: Any] = [
            "name": roomName,
            "updatedAt": Timestamp(date: Date())
        ]

        if let savedRoomId = savedRoomId {
            db.collection("properties")
                .document(property.id)
                .collection("rooms")
                .document(savedRoomId)
                .updateData(roomData) { error in

                    if let error = error {
                        self.showAlert(title: "Update Failed", message: error.localizedDescription)
                        return
                    }

                    self.saveNameButton.isHidden = true
                    self.showAlert(title: "Room Updated", message: "Room name has been updated.")
                }

        } else {
            let newRoomRef = db.collection("properties")
                .document(property.id)
                .collection("rooms")
                .document()

            var newRoomData = roomData
            newRoomData["createdAt"] = Timestamp(date: Date())

            newRoomRef.setData(newRoomData) { error in
                if let error = error {
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self.savedRoomId = newRoomRef.documentID
                self.saveNameButton.isHidden = true
                self.showAlert(
                    title: "Room Saved",
                    message: "You can now add a photo, windows, and floor details."
                )
            }
        }
    }
    
    @objc private func roomNameChanged() {
        saveNameButton.isHidden = false
    }

    @objc private func photoTapped() {
        guard savedRoomId != nil else {
            showAlert(title: "Save Room First", message: "Please save the room name before adding a photo.")
            return
        }

        // Camera/gallery implementation comes in the camera stage.
        showAlert(title: "Photo", message: "Camera and gallery selection will be added in the image stage.")
    }

    @objc private func addWindowTapped() {
        guard savedRoomId != nil else {
            showAlert(title: "Save Room First", message: "Please save the room name before adding windows.")
            return
        }

        showAlert(title: "Windows", message: "Window adding screen will be built in the next stage.")
    }

    @objc private func addFloorTapped() {
        guard savedRoomId != nil else {
            showAlert(title: "Save Room First", message: "Please save the room name before adding floor details.")
            return
        }

        showAlert(title: "Floor", message: "Floor details screen will be built after windows.")
    }

    @objc private func saveRoomDetailsTapped() {
        guard savedRoomId != nil else {
            showAlert(title: "Save Room First", message: "Please save the room name before saving room details.")
            return
        }

        navigationController?.popViewController(animated: true)
    }

    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 26
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 10
        return card
    }

    private func addContent(_ views: [UIView], to card: UIView) {
        let cardStack = UIStackView(arrangedSubviews: views)
        cardStack.axis = .vertical
        cardStack.spacing = 16

        card.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    private func createLabel(text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func stylePrimaryButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.25)
        button.setTitleColor(.systemIndigo, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }

    private func styleOutlineButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
