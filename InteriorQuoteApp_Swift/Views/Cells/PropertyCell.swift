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

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
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
        titleLabel.font = .boldSystemFont(ofSize: 17)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        editButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        editButton.tintColor = .systemBlue
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let buttonStack = UIStackView(arrangedSubviews: [editButton, deleteButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [textStack, buttonStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

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
