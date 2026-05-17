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

    private let roomImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let photoStatusLabel = UILabel()
    private let statusBadge = UILabel()
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
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = false
        clipsToBounds = false

        roomImageView.contentMode = .scaleAspectFill
        roomImageView.clipsToBounds = true
        roomImageView.layer.cornerRadius = 12
        roomImageView.backgroundColor = .secondarySystemBackground

        titleLabel.font = .boldSystemFont(ofSize: 17)

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        photoStatusLabel.font = .systemFont(ofSize: 13)
        photoStatusLabel.textColor = .secondaryLabel

        statusBadge.font = .boldSystemFont(ofSize: 12)
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 14
        statusBadge.clipsToBounds = true

        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            photoStatusLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [
            roomImageView,
            textStack,
            deleteButton
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        contentView.addSubview(mainStack)
        contentView.addSubview(statusBadge)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            statusBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            statusBadge.widthAnchor.constraint(equalToConstant: 145),
            statusBadge.heightAnchor.constraint(equalToConstant: 28),

            roomImageView.widthAnchor.constraint(equalToConstant: 76),
            roomImageView.heightAnchor.constraint(equalToConstant: 76),

            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(with room: Room) {
        self.room = room
        titleLabel.text = room.name

        let hasPhoto = !(room.imageUrl?.isEmpty ?? true)

        if hasPhoto {
            roomImageView.image = loadImage(filename: room.imageUrl!)
                ?? UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
            roomImageView.tintColor = .secondaryLabel
            photoStatusLabel.text = "Photo added"
        } else {
            roomImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
            roomImageView.tintColor = .secondaryLabel
            photoStatusLabel.text = "No photo yet"
        }

        let windowText = "\(room.windowCount) window\(room.windowCount == 1 ? "" : "s")"
        let floorText = room.hasFloor ? "Floor added" : "No floor"

        subtitleLabel.text = "\(windowText) • \(floorText)"

        if room.isComplete {
            statusBadge.text = "Manage Details"
            statusBadge.textColor = .systemGreen
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            statusBadge.text = "Add Details"
            statusBadge.textColor = .systemRed
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }
    }

    private func loadImage(filename: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }

    @objc private func deleteTapped() {
        guard let room = room else { return }
        delegate?.didTapDelete(room: room)
    }
}
