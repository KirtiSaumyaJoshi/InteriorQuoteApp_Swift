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
    var roomToEdit: Room?

    private let db = Firestore.firestore()
    private let productService = ProductService()

    private var savedRoomId: String?

    private var windows: [WindowSpace] = []

    private var floor: FloorSpace?
    private var floorProducts: [Product] = []
    private var selectedFloorProduct: Product?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let roomNameField = UITextField()
    private let saveNameButton = UIButton(type: .system)

    private let photoButton = UIButton(type: .system)
    private let roomImageView = UIImageView()
    private var selectedRoomImage: UIImage?

    private let addWindowButton = UIButton(type: .system)
    private let windowListStack = UIStackView()

    private let floorWidthField = UITextField()
    private let floorDepthField = UITextField()
    private let floorProductButton = UIButton(type: .system)
    private let saveFloorButton = UIButton(type: .system)

    private let selectedFloorProductCard = UIView()
    private let floorProductImageView = UIImageView()
    private let floorProductTitleLabel = UILabel()
    private let floorProductDescriptionLabel = UILabel()
    private let floorProductPriceLabel = UILabel()

    private let saveRoomDetailsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Room"
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        populateRoomIfEditing()
        fetchFloorProducts()

        roomNameField.addTarget(self, action: #selector(roomNameChanged), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if savedRoomId != nil {
            fetchWindows()
            fetchFloor()
        }
    }

    private func populateRoomIfEditing() {
        guard let room = roomToEdit else { return }

        title = "Manage Room"
        savedRoomId = room.id
        roomNameField.text = room.name
        saveNameButton.setTitle("Update Room Name", for: .normal)
        saveNameButton.isHidden = true

        fetchWindows()
        fetchFloor()
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

        stackView.addArrangedSubview(createLabel(text: "Manage room measurements", size: 30, weight: .bold, color: .label))
        stackView.addArrangedSubview(createLabel(text: "Save the room name first, then add a photo, windows, and floor details.", size: 17, weight: .regular, color: .secondaryLabel))

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
        let helper = createLabel(text: "Give this room a clear name, such as Living Room or Bedroom 1.", size: 16, weight: .regular, color: .secondaryLabel)

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
        let helper = createLabel(text: "Choose a photo from the gallery to help identify this room later.", size: 16, weight: .regular, color: .secondaryLabel)

        roomImageView.contentMode = .scaleAspectFill
        roomImageView.clipsToBounds = true
        roomImageView.layer.cornerRadius = 16
        roomImageView.backgroundColor = .secondarySystemBackground
        roomImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        roomImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
        roomImageView.tintColor = .secondaryLabel

        if let imageUrl = roomToEdit?.imageUrl {
            loadRoomImage(filename: imageUrl)
        }

        styleOutlineButton(photoButton, title: "Choose Photo from Gallery")
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)

        addContent([title, helper, roomImageView, photoButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupWindowSection() {
        let card = createCardView()

        let title = createLabel(text: "Windows", size: 24, weight: .bold, color: .label)
        let helper = createLabel(text: "Add each window space and assign a compatible window product.", size: 16, weight: .regular, color: .secondaryLabel)

        windowListStack.axis = .vertical
        windowListStack.spacing = 12

        styleOutlineButton(addWindowButton, title: "Add Window +")
        addWindowButton.addTarget(self, action: #selector(addWindowTapped), for: .touchUpInside)

        addContent([title, helper, windowListStack, addWindowButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupFloorSection() {
        let card = createCardView()

        let title = createLabel(text: "Floor details", size: 24, weight: .bold, color: .label)
        let helper = createLabel(text: "Enter one floor space for this room. You can update width, depth, and product anytime.", size: 16, weight: .regular, color: .secondaryLabel)

        setupField(floorWidthField, placeholder: "Width (mm) *")
        setupField(floorDepthField, placeholder: "Depth (mm) *")

        floorWidthField.keyboardType = .decimalPad
        floorDepthField.keyboardType = .decimalPad

        setupSelectedFloorProductCard()

        styleOutlineButton(floorProductButton, title: "Select Floor Product")
        floorProductButton.addTarget(self, action: #selector(selectFloorProductTapped), for: .touchUpInside)

        stylePrimaryButton(saveFloorButton, title: "Save Floor Details")
        saveFloorButton.addTarget(self, action: #selector(saveFloorTapped), for: .touchUpInside)

        addContent([
            title,
            helper,
            floorWidthField,
            floorDepthField,
            selectedFloorProductCard,
            floorProductButton,
            saveFloorButton
        ], to: card)

        stackView.addArrangedSubview(card)
    }

    private func setupSelectedFloorProductCard() {
        selectedFloorProductCard.backgroundColor = .secondarySystemBackground
        selectedFloorProductCard.layer.cornerRadius = 16

        floorProductImageView.contentMode = .scaleAspectFill
        floorProductImageView.clipsToBounds = true
        floorProductImageView.layer.cornerRadius = 12
        floorProductImageView.backgroundColor = .tertiarySystemBackground
        floorProductImageView.image = UIImage(systemName: "shippingbox")?.withRenderingMode(.alwaysTemplate)
        floorProductImageView.tintColor = .secondaryLabel

        floorProductTitleLabel.text = "No floor product selected"
        floorProductTitleLabel.font = .boldSystemFont(ofSize: 16)
        floorProductTitleLabel.numberOfLines = 2

        floorProductDescriptionLabel.text = "Choose a floor product to view its details."
        floorProductDescriptionLabel.font = .systemFont(ofSize: 13)
        floorProductDescriptionLabel.textColor = .secondaryLabel
        floorProductDescriptionLabel.numberOfLines = 2

        floorProductPriceLabel.font = .boldSystemFont(ofSize: 14)
        floorProductPriceLabel.textColor = .systemGreen

        let textStack = UIStackView(arrangedSubviews: [
            floorProductTitleLabel,
            floorProductDescriptionLabel,
            floorProductPriceLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 5

        let mainStack = UIStackView(arrangedSubviews: [
            floorProductImageView,
            textStack
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        selectedFloorProductCard.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: selectedFloorProductCard.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: selectedFloorProductCard.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: selectedFloorProductCard.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: selectedFloorProductCard.bottomAnchor, constant: -12),

            floorProductImageView.widthAnchor.constraint(equalToConstant: 76),
            floorProductImageView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }

    private func setupBottomSaveButton() {
        stylePrimaryButton(saveRoomDetailsButton, title: "Save Room Details")
        saveRoomDetailsButton.addTarget(self, action: #selector(saveRoomDetailsTapped), for: .touchUpInside)
    }

    @objc private func saveRoomNameTapped() {
        let roomName = roomNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if roomName.isEmpty {
            showAlert(title: "Room Name Required", message: "Please enter a room name before saving.")
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
                self.showAlert(title: "Room Saved", message: "You can now add a photo, windows, and floor details.")
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

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func addWindowTapped() {
        guard let savedRoomId = savedRoomId else {
            showAlert(title: "Save Room First", message: "Please save the room name before adding windows.")
            return
        }

        let addWindowVC = AddWindowViewController()
        addWindowVC.property = property
        addWindowVC.roomId = savedRoomId

        navigationController?.pushViewController(addWindowVC, animated: true)
    }

    @objc private func selectFloorProductTapped() {
        guard !floorProducts.isEmpty else {
            showAlert(title: "Products Loading", message: "Floor products are still loading or could not be fetched.")
            return
        }

        let productVC = ProductSelectionViewController()
        productVC.products = floorProducts
        productVC.delegate = self

        navigationController?.pushViewController(productVC, animated: true)
    }

    @objc private func saveFloorTapped() {
        guard let savedRoomId = savedRoomId else {
            showAlert(title: "Save Room First", message: "Please save the room name before saving floor details.")
            return
        }

        let widthText = clean(floorWidthField.text)
        let depthText = clean(floorDepthField.text)

        guard let width = Double(widthText), width > 0 else {
            showAlert(title: "Invalid Width", message: "Please enter a valid floor width in mm.")
            return
        }

        guard let depth = Double(depthText), depth > 0 else {
            showAlert(title: "Invalid Depth", message: "Please enter a valid floor depth in mm.")
            return
        }

        guard let product = selectedFloorProduct ?? existingFloorProduct() else {
            showAlert(title: "Product Required", message: "Please select a floor product.")
            return
        }

        let data: [String: Any] = [
            "widthMM": width,
            "depthMM": depth,
            "productId": product.id,
            "productName": product.title,
            "pricePerSqm": product.pricePerSquareMeter,
            "updatedAt": Timestamp(date: Date())
        ]

        var finalData = data

        if floor == nil {
            finalData["createdAt"] = Timestamp(date: Date())
        }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(savedRoomId)
            .collection("floors")
            .document("mainFloor")
            .setData(finalData, merge: true) { error in
                if let error = error {
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self.showAlert(title: "Floor Saved", message: "Floor details have been saved.")
                self.fetchFloor()
            }
    }

    @objc private func saveRoomDetailsTapped() {
        guard savedRoomId != nil else {
            showAlert(title: "Save Room First", message: "Please save the room name before saving room details.")
            return
        }

        navigationController?.popViewController(animated: true)
    }

    private func fetchWindows() {
        guard let savedRoomId = savedRoomId else { return }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(savedRoomId)
            .collection("windows")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "Windows Loading Failed", message: error.localizedDescription)
                    return
                }

                self.windows = snapshot?.documents.compactMap { document in
                    let data = document.data()

                    guard let name = data["name"] as? String else {
                        return nil
                    }

                    return WindowSpace(
                        id: document.documentID,
                        name: name,
                        widthMM: data["widthMM"] as? Double,
                        heightMM: data["heightMM"] as? Double,
                        imageUrl: data["imageUrl"] as? String,
                        productId: data["productId"] as? String,
                        productName: data["productName"] as? String,
                        pricePerSqm: data["pricePerSqm"] as? Double
                    )
                } ?? []

                self.refreshWindowList()
            }
    }

    private func fetchFloor() {
        guard let savedRoomId = savedRoomId else { return }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(savedRoomId)
            .collection("floors")
            .document("mainFloor")
            .getDocument { snapshot, error in
                if let error = error {
                    self.showAlert(title: "Floor Loading Failed", message: error.localizedDescription)
                    return
                }

                guard let data = snapshot?.data(),
                      let width = data["widthMM"] as? Double,
                      let depth = data["depthMM"] as? Double else {
                    return
                }

                self.floor = FloorSpace(
                    id: "mainFloor",
                    widthMM: width,
                    depthMM: depth,
                    productId: data["productId"] as? String,
                    productName: data["productName"] as? String,
                    pricePerSqm: data["pricePerSqm"] as? Double
                )

                self.floorWidthField.text = "\(Int(width))"
                self.floorDepthField.text = "\(Int(depth))"

                if let productName = self.floor?.productName,
                   let price = self.floor?.pricePerSqm {
                    self.floorProductTitleLabel.text = productName
                    self.floorProductDescriptionLabel.text = "Selected floor product"
                    self.floorProductPriceLabel.text = "$\(price)/m²"
                    self.saveFloorButton.setTitle("Update Floor Details", for: .normal)
                }
            }
    }

    private func fetchFloorProducts() {
        productService.fetchFloorProducts { products in
            self.floorProducts = products
        }
    }

    private func refreshWindowList() {
        windowListStack.arrangedSubviews.forEach {
            windowListStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if windows.isEmpty {
            windowListStack.addArrangedSubview(
                createLabel(text: "No windows added yet.", size: 15, weight: .regular, color: .secondaryLabel)
            )
            return
        }

        for window in windows {
            windowListStack.addArrangedSubview(createWindowItemView(for: window))
        }
    }

    private func createWindowItemView(for window: WindowSpace) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16

        let deleteButton = WindowDeleteButton(type: .system)
        deleteButton.windowSpace = window
        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteWindowTapped(_:)), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .tertiarySystemBackground

        if let imageUrl = window.imageUrl,
           let image = UIImage(contentsOfFile: getDocumentsDirectory().appendingPathComponent(imageUrl).path) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .secondaryLabel
            imageView.contentMode = .center
        }

        let titleLabel = createLabel(text: window.name, size: 17, weight: .bold, color: .label)

        let measurementText: String
        if let width = window.widthMM, let height = window.heightMM {
            measurementText = "\(Int(width)) mm × \(Int(height)) mm"
        } else {
            measurementText = "Measurements not completed"
        }

        let measurementLabel = createLabel(text: measurementText, size: 14, weight: .regular, color: .secondaryLabel)
        let productLabel = createLabel(text: window.productName ?? "No product selected", size: 14, weight: .regular, color: .secondaryLabel)

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            measurementLabel,
            productLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [
            imageView,
            textStack,
            deleteButton
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        container.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),

            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        container.isUserInteractionEnabled = true

        let tap = WindowTapGestureRecognizer(target: self, action: #selector(windowCardTapped(_:)))
        tap.windowSpace = window
        container.addGestureRecognizer(tap)

        return container
    }

    @objc private func windowCardTapped(_ sender: WindowTapGestureRecognizer) {
        guard let window = sender.windowSpace,
              let savedRoomId = savedRoomId else {
            return
        }

        let addWindowVC = AddWindowViewController()
        addWindowVC.property = property
        addWindowVC.roomId = savedRoomId
        addWindowVC.windowToEdit = window

        navigationController?.pushViewController(addWindowVC, animated: true)
    }

    @objc private func deleteWindowTapped(_ sender: WindowDeleteButton) {
        guard let window = sender.windowSpace else { return }

        let alert = UIAlertController(
            title: "Delete Window?",
            message: "This will delete \(window.name). This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteWindow(window)
        })

        present(alert, animated: true)
    }

    private func deleteWindow(_ window: WindowSpace) {
        guard let savedRoomId = savedRoomId else { return }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(savedRoomId)
            .collection("windows")
            .document(window.id)
            .delete { error in
                if let error = error {
                    self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                    return
                }

                self.windows.removeAll { $0.id == window.id }
                self.refreshWindowList()
            }
    }

    private func existingFloorProduct() -> Product? {
        guard let floor = floor,
              let productId = floor.productId,
              let productName = floor.productName,
              let price = floor.pricePerSqm else {
            return nil
        }

        return Product(
            id: productId,
            type: "floor",
            title: productName,
            description: "",
            imageUrl: "",
            pricePerSquareMeter: price,
            minWidth: nil,
            maxWidth: nil,
            minHeight: nil,
            maxHeight: nil,
            maxPanelCount: nil,
            variants: []
        )
    }

    private func updateFloorProductCard(with product: Product) {
        floorProductTitleLabel.text = product.title
        floorProductDescriptionLabel.text = product.description
        floorProductPriceLabel.text = "$\(product.pricePerSquareMeter)/m²"

        if !product.imageUrl.isEmpty,
           let url = URL(string: product.imageUrl) {
            loadRemoteImage(from: url, into: floorProductImageView)
        }
    }

    private func loadRemoteImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    private func saveImageLocally(_ image: UIImage, roomId: String) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return nil }

        let filename = "room_\(roomId).jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try imageData.write(to: url)
            return filename
        } catch {
            showAlert(title: "Image Save Failed", message: error.localizedDescription)
            return nil
        }
    }

    private func loadRoomImage(filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        if let image = UIImage(contentsOfFile: url.path) {
            roomImageView.image = image
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func setupField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    private func clean(_ text: String?) -> String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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

extension AddRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage

        guard let selectedImage = image,
              let roomId = savedRoomId else {
            return
        }

        selectedRoomImage = selectedImage
        roomImageView.image = selectedImage

        guard let filename = saveImageLocally(selectedImage, roomId: roomId) else {
            return
        }

        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(roomId)
            .updateData([
                "imageUrl": filename,
                "updatedAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    self.showAlert(title: "Photo Update Failed", message: error.localizedDescription)
                    return
                }

                self.showAlert(title: "Photo Saved", message: "Room photo has been saved successfully.")
            }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension AddRoomViewController: ProductSelectionDelegate {
    func didSelectProduct(_ product: Product) {
        selectedFloorProduct = product
        updateFloorProductCard(with: product)
    }
}

class WindowTapGestureRecognizer: UITapGestureRecognizer {
    var windowSpace: WindowSpace?
}

class WindowDeleteButton: UIButton {
    var windowSpace: WindowSpace?
}
