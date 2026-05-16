//
//  ProductCell.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import UIKit

class ProductCell: UITableViewCell {

    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()

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

        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 18

        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 12
        productImageView.backgroundColor = .secondarySystemBackground
        productImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
        productImageView.tintColor = .secondaryLabel

        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 2

        priceLabel.font = .boldSystemFont(ofSize: 15)
        priceLabel.textColor = .systemGreen

        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            priceLabel,
            descriptionLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 5

        let mainStack = UIStackView(arrangedSubviews: [
            productImageView,
            textStack
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            productImageView.widthAnchor.constraint(equalToConstant: 82),
            productImageView.heightAnchor.constraint(equalToConstant: 82)
        ])
    }

    func configure(with product: Product, compatibility: ProductCompatibilityResult) {
        titleLabel.text = product.title
        priceLabel.text = "$\(product.pricePerSquareMeter)/m²"
        descriptionLabel.text = product.description
        descriptionLabel.numberOfLines = 3

        if compatibility.isCompatible {
            priceLabel.textColor = .systemGreen
        } else {
            priceLabel.textColor = .systemRed
        }

        if !product.imageUrl.isEmpty,
           let url = URL(string: product.imageUrl) {
            loadImage(from: url)
        } else {
            productImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
            productImageView.tintColor = .secondaryLabel
        }

        selectionStyle = .none
    }

    private func loadImage(from url: URL) {
        productImageView.image = UIImage(systemName: "photo")?.withRenderingMode(.alwaysTemplate)
        productImageView.tintColor = .secondaryLabel

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                self.productImageView.image = image
            }
        }.resume()
    }
}
