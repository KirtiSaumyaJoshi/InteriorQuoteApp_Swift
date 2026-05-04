//
//  AddPropertyViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore

class AddPropertyViewController: UIViewController {

    private let db = Firestore.firestore()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let propertyNameField = UITextField()
    private let firstNameField = UITextField()
    private let middleNameField = UITextField()
    private let lastNameField = UITextField()
    private let genderField = UITextField()
    private let addressLineField = UITextField()
    private let cityField = UITextField()
    private let stateField = UITextField()
    private let countryField = UITextField()
    private let zipCodeField = UITextField()

    private let submitButton = UIButton(type: .system)

    private let genders = ["Male", "Female", "Other", "Prefer not to say"]
    private let genderPicker = UIPickerView()
    
    var propertyToEdit: Property?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Property"
        view.backgroundColor = .systemBackground

        setupUI()
        setupGenderPicker()
        populateFormIfEditing()
    }
    
    private func populateFormIfEditing() {
        guard let property = propertyToEdit else { return }

        title = "Edit Property"

        propertyNameField.text = property.propertyName
        firstNameField.text = property.ownerFirstName
        middleNameField.text = property.ownerMiddleName
        lastNameField.text = property.ownerLastName
        genderField.text = property.ownerGender
        addressLineField.text = property.addressLine
        cityField.text = property.city
        stateField.text = property.state
        countryField.text = property.country
        zipCodeField.text = property.zipCode

        submitButton.setTitle("Update Property", for: .normal)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(submitButton)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 14

        setupField(propertyNameField, placeholder: "Property name *")
        setupField(firstNameField, placeholder: "Owner first name *")
        setupField(middleNameField, placeholder: "Owner middle name (optional)")
        setupField(lastNameField, placeholder: "Owner last name *")
        setupField(genderField, placeholder: "Gender *")
        setupField(addressLineField, placeholder: "Address line *")
        setupField(cityField, placeholder: "City *")
        setupField(stateField, placeholder: "State *")
        setupField(countryField, placeholder: "Country *")
        setupField(zipCodeField, placeholder: "Zip code *")

        addSectionTitle(
            "Property Details",
            helperText: "Give this property a clear name so it is easy to find later.  Fields marked with * are required."
        )
        stackView.addArrangedSubview(propertyNameField)

        addSectionTitle(
            "Owner Details",
            helperText: "Enter the main contact person for this property."
        )
        stackView.addArrangedSubview(firstNameField)
        stackView.addArrangedSubview(middleNameField)
        stackView.addArrangedSubview(lastNameField)
        stackView.addArrangedSubview(genderField)

        addSectionTitle(
            "Address",
            helperText: "Enter the full property address."
        )
        stackView.addArrangedSubview(addressLineField)
        stackView.addArrangedSubview(cityField)
        stackView.addArrangedSubview(stateField)
        stackView.addArrangedSubview(countryField)
        stackView.addArrangedSubview(zipCodeField)

        submitButton.setTitle("Submit Property", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 12
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 52),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func setupField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.autocapitalizationType = .words
    }

    private func addSectionTitle(_ title: String, helperText: String? = nil) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)

        if let helperText = helperText {
            let helperLabel = UILabel()
            helperLabel.text = helperText
            helperLabel.font = .systemFont(ofSize: 14)
            helperLabel.textColor = .secondaryLabel
            helperLabel.numberOfLines = 0
            stackView.addArrangedSubview(helperLabel)
        }
    }

    private func setupGenderPicker() {
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderField.inputView = genderPicker
    }

    @objc private func submitTapped() {
        let propertyName = clean(propertyNameField.text)
        let firstName = clean(firstNameField.text)
        let middleName = clean(middleNameField.text)
        let lastName = clean(lastNameField.text)
        let gender = clean(genderField.text)
        let addressLine = clean(addressLineField.text)
        let city = clean(cityField.text)
        let state = clean(stateField.text)
        let country = clean(countryField.text)
        let zipCode = clean(zipCodeField.text)

        if propertyName.isEmpty {
            showAlert(title: "Property Name Required", message: "Please enter a name for this property.")
            return
        }

        if firstName.isEmpty {
            showAlert(title: "First Name Required", message: "Please enter the owner's first name.")
            return
        }

        if lastName.isEmpty {
            showAlert(title: "Last Name Required", message: "Please enter the owner's last name.")
            return
        }

        if gender.isEmpty {
            showAlert(title: "Gender Required", message: "Please select the owner's gender.")
            return
        }

        if addressLine.isEmpty {
            showAlert(title: "Address Required", message: "Please enter the property address line.")
            return
        }

        if city.isEmpty {
            showAlert(title: "City Required", message: "Please enter the city.")
            return
        }

        if state.isEmpty {
            showAlert(title: "State Required", message: "Please enter the state.")
            return
        }

        if country.isEmpty {
            showAlert(title: "Country Required", message: "Please enter the country.")
            return
        }

        if zipCode.isEmpty {
            showAlert(title: "Zip Code Required", message: "Please enter the zip code.")
            return
        }

        if !zipCode.allSatisfy({ $0.isNumber }) {
            showAlert(title: "Invalid Zip Code", message: "Zip code must contain numbers only.")
            return
        }

        if zipCode.count < 3 {
            showAlert(title: "Invalid Zip Code", message: "Please enter a valid zip code.")
            return
        }

        let propertyData: [String: Any] = [
            "propertyName": propertyName,
            "ownerFirstName": firstName,
            "ownerMiddleName": middleName,
            "ownerLastName": lastName,
            "ownerGender": gender,
            "addressLine": addressLine,
            "city": city,
            "state": state,
            "country": country,
            "zipCode": zipCode,
            "updatedAt": Timestamp(date: Date())
        ]

        if let propertyToEdit = propertyToEdit {
            db.collection("properties").document(propertyToEdit.id).updateData(propertyData) { error in
                if let error = error {
                    self.showAlert(title: "Update Failed", message: error.localizedDescription)
                    return
                }

                self.navigationController?.popViewController(animated: true)
            }
        } else {
            var newPropertyData = propertyData
            newPropertyData["createdAt"] = Timestamp(date: Date())

            db.collection("properties").addDocument(data: newPropertyData) { error in
                if let error = error {
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func clean(_ text: String?) -> String {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddPropertyViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genders[row]
    }
}
