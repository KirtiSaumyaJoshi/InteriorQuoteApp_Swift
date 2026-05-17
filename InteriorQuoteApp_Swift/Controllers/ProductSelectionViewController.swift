//
//  ProductSelectionViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import UIKit

protocol ProductSelectionDelegate: AnyObject {
    func didSelectProduct(_ product: Product)
}

class ProductSelectionViewController: UIViewController {

    weak var delegate: ProductSelectionDelegate?

    var products: [Product] = []

    var windowWidthMM: Double?
    var windowHeightMM: Double?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Product"
        view.backgroundColor = .systemGroupedBackground

        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProductSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductCell else {
            return UITableViewCell()
        }

        let product = products[indexPath.row]

        if let width = windowWidthMM,
           let height = windowHeightMM {

            let result = ProductConstraintChecker.check(
                product: product,
                widthMM: width,
                heightMM: height
            )

            cell.configure(with: product, compatibility: result)

        } else {

            let result = ProductCompatibilityResult(
                isCompatible: true,
                message: "Compatible"
            )

            cell.configure(with: product, compatibility: result)
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let product = products[indexPath.row]

        if let width = windowWidthMM,
           let height = windowHeightMM {

            let result = ProductConstraintChecker.check(
                product: product,
                widthMM: width,
                heightMM: height
            )

            if !result.isCompatible {
                let alert = UIAlertController(
                    title: "Product Not Compatible",
                    message: result.message,
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
        }

        delegate?.didSelectProduct(product)
        navigationController?.popViewController(animated: true)
    }
}
