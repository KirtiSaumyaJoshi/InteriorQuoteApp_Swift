//
//  AddWindowViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import UIKit
import FirebaseFirestore

class AddWindowViewController: UIViewController {

    var property: Property!
    var roomId: String!

    private let db = Firestore.firestore()
    private let productService = ProductService()
    
    private var savedWindowId: String?
    private var selectedImage: UIImage?
    private var selectedProduct: Product?

    private var products: [Product] = []

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let windowNameField = UITextField()
    private let widthField = UITextField()
    private let heightField = UITextField()

    private let windowImageView = UIImageView()
    private let saveNameButton = UIButton(type: .system)
    private let photoButton = UIButton(type: .system)
    private let productButton = UIButton(type: .system)
    
    private let selectedProductLabel = UILabel()
    private let selectedProductCard = UIView()
    private let selectedProductImageView = UIImageView()
    private let selectedProductTitleLabel = UILabel()
    private let selectedProductDescriptionLabel = UILabel()
    private let selectedProductPriceLabel = UILabel()
    
    private let saveAllButton = UIButton(type: .system)
    var windowToEdit: WindowSpace?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Window"
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        fetchProducts()
        populateWindowIfEditing()
        windowNameField.addTarget(self, action: #selector(windowNameChanged), for: .editingChanged)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveAllButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(saveAllButton)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 18

        let header = createLabel(text: "Add window details", size: 30, weight: .bold, color: .label)
        let helper = createLabel(text: "Save the window name first, then add photo, measurements, and product.", size: 16, weight: .regular, color: .secondaryLabel)

        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(helper)

        setupNameSection()
        setupPhotoSection()
        setupMeasurementSection()
        setupProductSection()
        setupSaveButton()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveAllButton.topAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),

            saveAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveAllButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func setupNameSection() {
        let card = createCardView()

        let title = createLabel(text: "Window information", size: 22, weight: .bold, color: .label)
        let helper = createLabel(text: "Use a clear name, such as North Window or Sliding Door.", size: 15, weight: .regular, color: .secondaryLabel)

        setupField(windowNameField, placeholder: "Window name *")

        stylePrimaryButton(saveNameButton, title: "Save Window Name")
        saveNameButton.addTarget(self, action: #selector(saveWindowNameTapped), for: .touchUpInside)

        addContent([title, helper, windowNameField, saveNameButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupPhotoSection() {
        let card = createCardView()

        let title = createLabel(text: "Window photo", size: 22, weight: .bold, color: .label)
        let helper = createLabel(text: "Choose a photo from gallery for reference.", size: 15, weight: .regular, color: .secondaryLabel)

        windowImageView.contentMode = .scaleAspectFill
        windowImageView.clipsToBounds = true
        windowImageView.layer.cornerRadius = 16
        windowImageView.backgroundColor = .secondarySystemBackground
        windowImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
        windowImageView.tintColor = .secondaryLabel
        windowImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        styleOutlineButton(photoButton, title: "Choose Photo from Gallery")
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)

        addContent([title, helper, windowImageView, photoButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupMeasurementSection() {
        let card = createCardView()

        let title = createLabel(text: "Measurements", size: 22, weight: .bold, color: .label)
        let helper = createLabel(text: "Enter dimensions in millimetres. Example: 1200 width and 1500 height.", size: 15, weight: .regular, color: .secondaryLabel)

        setupField(widthField, placeholder: "Width (mm) *")
        setupField(heightField, placeholder: "Height (mm) *")

        widthField.keyboardType = .decimalPad
        heightField.keyboardType = .decimalPad

        addContent([title, helper, widthField, heightField], to: card)
        stackView.addArrangedSubview(card)
    }
    
    private func setupSelectedProductCard() {
        selectedProductCard.backgroundColor = .secondarySystemBackground
        selectedProductCard.layer.cornerRadius = 16

        selectedProductImageView.contentMode = .scaleAspectFill
        selectedProductImageView.clipsToBounds = true
        selectedProductImageView.layer.cornerRadius = 12
        selectedProductImageView.backgroundColor = .tertiarySystemBackground
        selectedProductImageView.image = UIImage(systemName: "shippingbox")?.withRenderingMode(.alwaysTemplate)
        selectedProductImageView.tintColor = .secondaryLabel

        selectedProductTitleLabel.text = "No product selected"
        selectedProductTitleLabel.font = .boldSystemFont(ofSize: 16)
        selectedProductTitleLabel.textColor = .label
        selectedProductTitleLabel.numberOfLines = 2

        selectedProductDescriptionLabel.text = "Choose a window product to view its details here."
        selectedProductDescriptionLabel.font = .systemFont(ofSize: 13)
        selectedProductDescriptionLabel.textColor = .secondaryLabel
        selectedProductDescriptionLabel.numberOfLines = 2

        selectedProductPriceLabel.text = ""
        selectedProductPriceLabel.font = .boldSystemFont(ofSize: 14)
        selectedProductPriceLabel.textColor = .systemGreen

        let textStack = UIStackView(arrangedSubviews: [
            selectedProductTitleLabel,
            selectedProductDescriptionLabel,
            selectedProductPriceLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 5

        let mainStack = UIStackView(arrangedSubviews: [
            selectedProductImageView,
            textStack
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        selectedProductCard.addSubview(mainStack)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        selectedProductImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: selectedProductCard.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: selectedProductCard.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: selectedProductCard.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: selectedProductCard.bottomAnchor, constant: -12),

            selectedProductImageView.widthAnchor.constraint(equalToConstant: 76),
            selectedProductImageView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }

    private func updateSelectedProductCard(with product: Product) {
        selectedProductTitleLabel.text = product.title
        selectedProductDescriptionLabel.text = product.description
        selectedProductPriceLabel.text = "$\(product.pricePerSquareMeter)/m²"

        if !product.imageUrl.isEmpty,
           let url = URL(string: product.imageUrl) {
            loadRemoteImage(from: url, into: selectedProductImageView)
        } else {
            selectedProductImageView.image = UIImage(systemName: "shippingbox")?.withRenderingMode(.alwaysTemplate)
            selectedProductImageView.tintColor = .secondaryLabel
        }
    }

    private func loadRemoteImage(from url: URL, into imageView: UIImageView) {
        imageView.image = UIImage(systemName: "shippingbox")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabel

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    private func setupProductSection() {
        let card = createCardView()

        let title = createLabel(text: "Window product", size: 22, weight: .bold, color: .label)
        let helper = createLabel(
            text: "Select a window product from the provided API. The selected product will be used for the quote calculation.",
            size: 15,
            weight: .regular,
            color: .secondaryLabel
        )

        setupSelectedProductCard()

        styleOutlineButton(productButton, title: "Choose Window Product")
        productButton.addTarget(self, action: #selector(productTapped), for: .touchUpInside)

        addContent([title, helper, selectedProductCard, productButton], to: card)
        stackView.addArrangedSubview(card)
    }

    private func setupSaveButton() {
        stylePrimaryButton(saveAllButton, title: "Save Window Details")
        saveAllButton.addTarget(self, action: #selector(saveAllTapped), for: .touchUpInside)
    }

    @objc private func saveWindowNameTapped() {
        let windowName = clean(windowNameField.text)

        if windowName.isEmpty {
            showAlert(title: "Window Name Required", message: "Please enter a window name before saving.")
            return
        }

        if let savedWindowId = savedWindowId {
            db.collection("properties").document(property.id)
                .collection("rooms").document(roomId)
                .collection("windows").document(savedWindowId)
                .updateData([
                    "name": windowName,
                    "updatedAt": Timestamp(date: Date())
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "Update Failed", message: error.localizedDescription)
                        return
                    }

                    self.saveNameButton.isHidden = true
                }
        } else {
            let newWindowRef = db.collection("properties").document(property.id)
                .collection("rooms").document(roomId)
                .collection("windows").document()

            newWindowRef.setData([
                "name": windowName,
                "createdAt": Timestamp(date: Date()),
                "updatedAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self.savedWindowId = newWindowRef.documentID
                self.saveNameButton.isHidden = true
                self.showAlert(title: "Window Saved", message: "You can now add photo, measurements, and product.")
            }
        }
    }

    @objc private func windowNameChanged() {
        saveNameButton.isHidden = false
    }

    @objc private func photoTapped() {
        guard savedWindowId != nil else {
            showAlert(title: "Save Window First", message: "Please save the window name before adding a photo.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func productTapped() {
        guard !products.isEmpty else {
            showAlert(
                title: "Products Loading",
                message: "Window products are still loading or could not be fetched."
            )
            return
        }

        guard let width = Double(clean(widthField.text)), width > 0 else {
            showAlert(title: "Width Required", message: "Please enter a valid width before choosing a product.")
            return
        }

        guard let height = Double(clean(heightField.text)), height > 0 else {
            showAlert(title: "Height Required", message: "Please enter a valid height before choosing a product.")
            return
        }

        let productVC = ProductSelectionViewController()
        productVC.products = products
        productVC.windowWidthMM = width
        productVC.windowHeightMM = height
        productVC.delegate = self

        navigationController?.pushViewController(productVC, animated: true)
    }

    @objc private func saveAllTapped() {
        guard let savedWindowId = savedWindowId else {
            showAlert(title: "Save Window First", message: "Please save the window name first.")
            return
        }

        let widthText = clean(widthField.text)
        let heightText = clean(heightField.text)

        guard let width = Double(widthText), width > 0 else {
            showAlert(title: "Invalid Width", message: "Please enter a valid window width in mm.")
            return
        }

        guard let height = Double(heightText), height > 0 else {
            showAlert(title: "Invalid Height", message: "Please enter a valid window height in mm.")
            return
        }

        guard let product = selectedProduct else {
            showAlert(title: "Product Required", message: "Please choose a window product before saving.")
            return
        }
        let compatibility = ProductConstraintChecker.check(
            product: product,
            widthMM: width,
            heightMM: height
        )

        if !compatibility.isCompatible {
            showAlert(
                title: "Product Not Compatible",
                message: compatibility.message
            )
            return
        }

        db.collection("properties").document(property.id)
            .collection("rooms").document(roomId)
            .collection("windows").document(savedWindowId)
            .updateData([
                "widthMM": width,
                "heightMM": height,
                "productId": product.id,
                "productName": product.title,
                "pricePerSqm": product.pricePerSquareMeter,
                "updatedAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self.navigationController?.popViewController(animated: true)
            }
    }

    private func fetchProducts() {
        productService.fetchWindowProducts { products in
            self.products = products
        }
    }
    
    private func populateWindowIfEditing() {
        guard let window = windowToEdit else { return }

        title = "Edit Window"

        savedWindowId = window.id
        windowNameField.text = window.name

        if let width = window.widthMM {
            widthField.text = "\(Int(width))"
        }

        if let height = window.heightMM {
            heightField.text = "\(Int(height))"
        }

        if let imageUrl = window.imageUrl {
            let url = documentsDirectory().appendingPathComponent(imageUrl)
            if let image = UIImage(contentsOfFile: url.path) {
                windowImageView.image = image
            }
        }

        if let productName = window.productName,
           let price = window.pricePerSqm {
            selectedProductTitleLabel.text = productName
            selectedProductDescriptionLabel.text = "Previously selected product"
            selectedProductPriceLabel.text = "$\(price)/m²"
        }

        saveNameButton.setTitle("Update Window Name", for: .normal)
        saveNameButton.isHidden = true
    }

    private func saveImageLocally(_ image: UIImage, windowId: String) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return nil }

        let filename = "window_\(windowId).jpg"
        let url = documentsDirectory().appendingPathComponent(filename)

        do {
            try imageData.write(to: url)
            return filename
        } catch {
            showAlert(title: "Image Save Failed", message: error.localizedDescription)
            return nil
        }
    }

    private func documentsDirectory() -> URL {
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

extension AddWindowViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage

        guard let selectedImage = image,
              let windowId = savedWindowId else { return }

        windowImageView.image = selectedImage

        guard let filename = saveImageLocally(selectedImage, windowId: windowId) else { return }

        db.collection("properties").document(property.id)
            .collection("rooms").document(roomId)
            .collection("windows").document(windowId)
            .updateData([
                "imageUrl": filename,
                "updatedAt": Timestamp(date: Date())
            ])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
extension AddWindowViewController: ProductSelectionDelegate {
    func didSelectProduct(_ product: Product) {
        selectedProduct = product
        updateSelectedProductCard(with: product)
    }
}
