//
//  PropertyCell.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit

protocol PropertyCellDelegate: AnyObject {
    func didTapEdit(property: Property)
    func didTapDelete(property: Property)
}

class PropertyCell: UITableViewCell {

    weak var delegate: PropertyCellDelegate?
    private var property: Property?

    private let cardView = UIView()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()

    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false

        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 8

        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        statusLabel.font = .boldSystemFont(ofSize: 12)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 14
        statusLabel.clipsToBounds = true

        editButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        editButton.tintColor = .systemBlue
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 4

        let buttonStack = UIStackView(arrangedSubviews: [
            editButton,
            deleteButton
        ])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [
            textStack,
            buttonStack
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)
        contentView.addSubview(statusLabel)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -12),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(equalToConstant: 118),
            statusLabel.heightAnchor.constraint(equalToConstant: 28),

            editButton.widthAnchor.constraint(equalToConstant: 32),
            editButton.heightAnchor.constraint(equalToConstant: 32),

            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with property: Property) {
        self.property = property

        titleLabel.text = property.propertyName
        subtitleLabel.text = "\(property.ownerFullName) • \(property.city), \(property.state)"

        if property.roomCount == 0 {
            statusLabel.text = "Add Rooms"
            statusLabel.textColor = .systemRed
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        } else {
            statusLabel.text = "Manage Rooms"
            statusLabel.textColor = .systemGreen
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        }
    }

    @objc private func editTapped() {
        guard let property = property else { return }
        delegate?.didTapEdit(property: property)
    }

    @objc private func deleteTapped() {
        guard let property = property else { return }
        delegate?.didTapDelete(property: property)
    }
}
