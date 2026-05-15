//
//  RoomCell.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 8/5/2026.
//

import UIKit

protocol RoomCellDelegate: AnyObject {
    func didTapDelete(room: Room)
}

class RoomCell: UITableViewCell {

    weak var delegate: RoomCellDelegate?
    private var room: Room?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
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

        subtitleLabel.text = "Tap to manage windows, floors, photo and quote"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [textStack, deleteButton])
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

            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(with room: Room) {
        self.room = room
        titleLabel.text = room.name
    }

    @objc private func deleteTapped() {
        guard let room = room else { return }
        delegate?.didTapDelete(room: room)
    }
}
