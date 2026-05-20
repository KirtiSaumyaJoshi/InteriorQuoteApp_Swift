//
//  RoomCell.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 8/5/2026.
//

import UIKit

protocol RoomCellDelegate: AnyObject {
    func didTapDelete(room: Room)
    func didTapQuoteToggle(room: Room)
}

class RoomCell: UITableViewCell {

    weak var delegate: RoomCellDelegate?
    private var room: Room?

    private let roomImageView   = UIImageView()
    private let titleLabel      = UILabel()
    private let subtitleLabel   = UILabel()
    private let photoStatusLabel = UILabel()
    private let statusBadge     = UILabel()
    private let deleteButton    = UIButton(type: .system)
    private let quoteButton     = UIButton(type: .system)
    let quoteCostLabel          = UILabel()   // internal — kept internal so list can update it

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Layout

    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = false
        clipsToBounds = false

        // Image
        roomImageView.contentMode  = .scaleAspectFill
        roomImageView.clipsToBounds = true
        roomImageView.layer.cornerRadius = 12
        roomImageView.backgroundColor = .secondarySystemBackground

        // Labels
        titleLabel.font = .boldSystemFont(ofSize: 17)

        subtitleLabel.font      = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        photoStatusLabel.font      = .systemFont(ofSize: 13)
        photoStatusLabel.textColor = .secondaryLabel

        // Quote cost label (shown below subtitle when in quote)
        quoteCostLabel.font      = .boldSystemFont(ofSize: 14)
        quoteCostLabel.textColor = .systemIndigo
        quoteCostLabel.isHidden  = true

        // Status badge
        statusBadge.font           = .boldSystemFont(ofSize: 12)
        statusBadge.textAlignment  = .center
        statusBadge.layer.cornerRadius = 14
        statusBadge.clipsToBounds  = true

        // Buttons
        deleteButton.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        quoteButton.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        quoteButton.tintColor = .secondaryLabel
        quoteButton.addTarget(self, action: #selector(quoteTapped), for: .touchUpInside)

        // Vertical action buttons (cart on top, trash below)
        let actionStack = UIStackView(arrangedSubviews: [quoteButton, deleteButton])
        actionStack.axis      = .vertical
        actionStack.spacing   = 6
        actionStack.alignment = .center

        // Text stack
        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            photoStatusLabel,
            quoteCostLabel
        ])
        textStack.axis    = .vertical
        textStack.spacing = 4

        // Main row
        let mainStack = UIStackView(arrangedSubviews: [roomImageView, textStack, actionStack])
        mainStack.axis      = .horizontal
        mainStack.spacing   = 12
        mainStack.alignment = .center

        contentView.addSubview(mainStack)
        contentView.addSubview(statusBadge)

        mainStack.translatesAutoresizingMaskIntoConstraints   = false
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

            quoteButton.widthAnchor.constraint(equalToConstant: 34),
            quoteButton.heightAnchor.constraint(equalToConstant: 34),

            deleteButton.widthAnchor.constraint(equalToConstant: 34),
            deleteButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: - Configure

    func configure(with room: Room, isInQuote: Bool) {
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
        let floorText  = room.hasFloor ? "Floor added" : "No floor"
        subtitleLabel.text = "\(windowText) • \(floorText)"

        if room.isComplete {
            statusBadge.text            = "Manage Details"
            statusBadge.textColor       = .systemGreen
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            statusBadge.text            = "Add Details"
            statusBadge.textColor       = .systemRed
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }

        // Cart button state
        setQuoteSelected(isInQuote, room: room)
    }

    /// Updates the cart icon + cost label without a full reconfigure
    func setQuoteSelected(_ selected: Bool, room: Room) {
        let iconName = selected ? "cart.fill.badge.plus" : "cart.badge.plus"
        quoteButton.setImage(UIImage(systemName: iconName), for: .normal)
        quoteButton.tintColor = selected ? .systemGreen : .secondaryLabel

        if selected {
            let cost = room.quoteCost()
            quoteCostLabel.text   = cost > 0
                ? String(format: "Room quote: $%.2f", cost)
                : "Room quote: pending measurements"
            quoteCostLabel.isHidden = false
        } else {
            quoteCostLabel.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func deleteTapped() {
        guard let room = room else { return }
        delegate?.didTapDelete(room: room)
    }

    @objc private func quoteTapped() {
        guard let room = room else { return }
        delegate?.didTapQuoteToggle(room: room)
    }

    // MARK: - Image helper

    private func loadImage(filename: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}
