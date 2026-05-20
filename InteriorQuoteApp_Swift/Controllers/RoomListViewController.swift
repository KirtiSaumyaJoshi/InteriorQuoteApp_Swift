//
//  RoomListViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore

class RoomListViewController: UIViewController {

    var property: Property!

    private let db = Firestore.firestore()
    private var rooms: [Room] = []
    private var filteredRooms: [Room] = []

    // Tracks which rooms are toggled into the quote
    private var selectedQuoteRoomIds: Set<String> = []

    // MARK: - UI
    private let tableView   = UITableView()
    private let emptyLabel  = UILabel()
    private let searchController = UISearchController(searchResultsController: nil)

    // Quote panel (pinned to bottom)
    private let quotePanel          = UIView()
    private let quotePanelToggle    = UIButton(type: .system)   // chevron to collapse/expand
    private let quoteReceiptView    = UIView()                  // the scrollable receipt inside
    private let quoteWindowsStack   = UIStackView()
    private let quoteRoomsStack     = UIStackView()             // one section per room
    private let quoteTotalAmountLabel = UILabel()
    private let quoteEmptyLabel     = UILabel()
    private var quotePanelExpanded  = true
    private var quotePanelHeightConstraint: NSLayoutConstraint!

    private var isSearching: Bool {
        let text = searchController.searchBar.text ?? ""
        return searchController.isActive && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = property.propertyName
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupQuotePanel()
        setupSearchBar()
        fetchRooms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRooms()
    }

    // MARK: - Setup UI

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoomTapped)
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.dataSource    = self
        tableView.delegate      = self
        tableView.register(RoomCell.self, forCellReuseIdentifier: "RoomCell")
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 105
        tableView.backgroundColor   = .clear

        emptyLabel.text          = "No rooms added yet.\nTap + to add the first room."
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.textColor     = .secondaryLabel
        emptyLabel.font          = .systemFont(ofSize: 17)

        // Constraints will be finalised after quotePanel is added (see setupQuotePanel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Quote Panel

    private func setupQuotePanel() {
        quotePanel.translatesAutoresizingMaskIntoConstraints = false
        quotePanel.backgroundColor   = .systemBackground
        quotePanel.layer.cornerRadius = 24
        quotePanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        quotePanel.layer.shadowColor   = UIColor.black.cgColor
        quotePanel.layer.shadowOpacity = 0.10
        quotePanel.layer.shadowOffset  = CGSize(width: 0, height: -4)
        quotePanel.layer.shadowRadius  = 12

        view.addSubview(quotePanel)

        // ── Header row: title + collapse chevron ──────────────────────────────
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let titleStack = UIStackView()
        titleStack.axis    = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center

        let cartIcon = UIImageView(image: UIImage(systemName: "cart.fill"))
        cartIcon.tintColor = .systemIndigo
        cartIcon.contentMode = .scaleAspectFit
        cartIcon.translatesAutoresizingMaskIntoConstraints = false
        cartIcon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        cartIcon.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let panelTitleLabel = UILabel()
        panelTitleLabel.text      = "Quote Summary"
        panelTitleLabel.font      = .boldSystemFont(ofSize: 18)
        panelTitleLabel.textColor = .label

        titleStack.addArrangedSubview(cartIcon)
        titleStack.addArrangedSubview(panelTitleLabel)

        quotePanelToggle.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        quotePanelToggle.tintColor = .secondaryLabel
        quotePanelToggle.addTarget(self, action: #selector(toggleQuotePanel), for: .touchUpInside)
        quotePanelToggle.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleStack)
        headerView.addSubview(quotePanelToggle)
        titleStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            quotePanelToggle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            quotePanelToggle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52)
        ])

        // ── Scrollable receipt ────────────────────────────────────────────────
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        quoteReceiptView.translatesAutoresizingMaskIntoConstraints = false

        // Rooms stack (one sub-section per room)
        quoteRoomsStack.axis    = .vertical
        quoteRoomsStack.spacing = 0
        quoteRoomsStack.translatesAutoresizingMaskIntoConstraints = false

        // Empty state
        quoteEmptyLabel.text          = "Tap the cart icon on a room to add it to the quote."
        quoteEmptyLabel.font          = .systemFont(ofSize: 14)
        quoteEmptyLabel.textColor     = .tertiaryLabel
        quoteEmptyLabel.textAlignment = .center
        quoteEmptyLabel.numberOfLines = 0
        quoteEmptyLabel.translatesAutoresizingMaskIntoConstraints = false

        // Divider
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // Total row
        let totalLabel = UILabel()
        totalLabel.text      = "TOTAL"
        totalLabel.font      = .systemFont(ofSize: 15, weight: .heavy)
        totalLabel.textColor = .label

        quoteTotalAmountLabel.text          = "$0.00"
        quoteTotalAmountLabel.font          = .systemFont(ofSize: 22, weight: .heavy)
        quoteTotalAmountLabel.textColor     = .systemIndigo
        quoteTotalAmountLabel.textAlignment = .right

        let totalRow = UIStackView(arrangedSubviews: [totalLabel, quoteTotalAmountLabel])
        totalRow.axis         = .horizontal
        totalRow.distribution = .equalSpacing
        totalRow.alignment    = .center

        // Receipt inner stack
        let receiptInner = UIStackView(arrangedSubviews: [
            quoteRoomsStack,
            quoteEmptyLabel,
            divider,
            totalRow
        ])
        receiptInner.axis    = .vertical
        receiptInner.spacing = 0
        receiptInner.translatesAutoresizingMaskIntoConstraints = false

        quoteReceiptView.addSubview(receiptInner)
        scroll.addSubview(quoteReceiptView)

        NSLayoutConstraint.activate([
            receiptInner.topAnchor.constraint(equalTo: quoteReceiptView.topAnchor, constant: 8),
            receiptInner.leadingAnchor.constraint(equalTo: quoteReceiptView.leadingAnchor, constant: 20),
            receiptInner.trailingAnchor.constraint(equalTo: quoteReceiptView.trailingAnchor, constant: -20),
            receiptInner.bottomAnchor.constraint(equalTo: quoteReceiptView.bottomAnchor, constant: -16),

            quoteReceiptView.topAnchor.constraint(equalTo: scroll.topAnchor),
            quoteReceiptView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            quoteReceiptView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            quoteReceiptView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            quoteReceiptView.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        // ── Assemble panel ────────────────────────────────────────────────────
        let panelStack = UIStackView(arrangedSubviews: [headerView, scroll])
        panelStack.axis = .vertical
        panelStack.translatesAutoresizingMaskIntoConstraints = false

        quotePanel.addSubview(panelStack)

        let collapsedHeight: CGFloat = 52   // header only
        let expandedHeight: CGFloat  = 300

        quotePanelHeightConstraint = quotePanel.heightAnchor.constraint(equalToConstant: expandedHeight)

        NSLayoutConstraint.activate([
            panelStack.topAnchor.constraint(equalTo: quotePanel.topAnchor),
            panelStack.leadingAnchor.constraint(equalTo: quotePanel.leadingAnchor),
            panelStack.trailingAnchor.constraint(equalTo: quotePanel.trailingAnchor),
            panelStack.bottomAnchor.constraint(equalTo: quotePanel.bottomAnchor),

            quotePanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quotePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quotePanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            quotePanelHeightConstraint,

            // Table sits above the panel
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: quotePanel.topAnchor)
        ])

        _ = collapsedHeight   // silence unused warning; used in toggleQuotePanel
        updateQuoteSummary()
    }

    @objc private func toggleQuotePanel() {
        quotePanelExpanded.toggle()
        let newHeight: CGFloat = quotePanelExpanded ? 300 : 52
        quotePanelHeightConstraint.constant = newHeight

        let chevron = quotePanelExpanded ? "chevron.down" : "chevron.up"
        quotePanelToggle.setImage(UIImage(systemName: chevron), for: .normal)

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Quote Summary

    private func updateQuoteSummary() {
        // Clear old room sections
        quoteRoomsStack.arrangedSubviews.forEach {
            quoteRoomsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let selectedRooms = rooms.filter { selectedQuoteRoomIds.contains($0.id) }
        quoteEmptyLabel.isHidden = !selectedRooms.isEmpty

        var grandTotal: Double = 0

        for room in selectedRooms {
            let roomSection = makeRoomQuoteSection(room)
            quoteRoomsStack.addArrangedSubview(roomSection)
            grandTotal += room.quoteCost()
        }

        quoteTotalAmountLabel.text = String(format: "$%.2f", grandTotal)
    }

    /// Builds a receipt section for one room: header + window lines + floor line
    private func makeRoomQuoteSection(_ room: Room) -> UIView {
        let container = UIView()
        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Room name header
        stack.addArrangedSubview(makeReceiptRoomHeader(name: room.name))

        // Window lines
        let quotedWindows = room.windows.filter { $0.isIncludedInQuote }

        if quotedWindows.isEmpty {
            let noWindows = makeReceiptNote("No windows in quote")
            stack.addArrangedSubview(noWindows)
        } else {
            for window in quotedWindows {
                let area   = window.area()
                let cost   = window.cost()
                let detail = area > 0
                    ? String(format: "%.2f m² × $%.2f/m²", area, window.pricePerSqm ?? 0)
                    : "Missing measurements"
                stack.addArrangedSubview(
                    makeReceiptLineItem(name: window.name, detail: detail, amount: area > 0 ? cost : nil)
                )
            }
        }

        // Floor line
        if room.isFloorIncludedInQuote, let floor = room.floors.first {
            let area   = floor.area()
            let cost   = floor.cost()
            let detail = String(format: "%.2f m² × $%.2f/m²", area, floor.pricePerSqm ?? 0)
            stack.addArrangedSubview(
                makeReceiptLineItem(name: floor.productName ?? "Floor", detail: detail, amount: cost)
            )
        } else if !room.isFloorIncludedInQuote {
            stack.addArrangedSubview(makeReceiptNote("Floor excluded from quote"))
        } else if room.hasFloor {
            stack.addArrangedSubview(makeReceiptNote("Floor: missing product/price"))
        }

        return container
    }

    // MARK: - Receipt helpers (mirrors AddRoomViewController style)

    private func makeReceiptRoomHeader(name: String) -> UIView {
        let container = UIView()

        let sep = UIView()
        sep.backgroundColor = .separator

        let label = UILabel()
        label.text      = name.uppercased()
        label.font      = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .secondaryLabel

        container.addSubview(sep)
        container.addSubview(label)
        sep.translatesAutoresizingMaskIntoConstraints   = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sep.topAnchor.constraint(equalTo: container.topAnchor),
            sep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
            label.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            container.heightAnchor.constraint(equalToConstant: 32)
        ])

        return container
    }

    private func makeReceiptNote(_ text: String) -> UIView {
        let label = UILabel()
        label.text          = text
        label.font          = .systemFont(ofSize: 13)
        label.textColor     = .tertiaryLabel
        label.textAlignment = .center

        let wrapper = UIView()
        wrapper.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -6)
        ])
        return wrapper
    }

    private func makeReceiptLineItem(name: String, detail: String, amount: Double?) -> UIView {
        let container = UIView()

        let nameLabel        = UILabel()
        nameLabel.text       = name
        nameLabel.font       = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor  = .label

        let detailLabel      = UILabel()
        detailLabel.text     = detail
        detailLabel.font     = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabel

        let leftStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        leftStack.axis    = .vertical
        leftStack.spacing = 2

        let amountLabel           = UILabel()
        amountLabel.text          = amount != nil ? String(format: "$%.2f", amount!) : "–"
        amountLabel.font          = .systemFont(ofSize: 15, weight: .medium)
        amountLabel.textColor     = amount != nil ? .label : .tertiaryLabel
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [leftStack, amountLabel])
        row.axis      = .horizontal
        row.alignment = .center
        row.spacing   = 12

        let sep           = UIView()
        sep.backgroundColor = .separator.withAlphaComponent(0.5)

        container.addSubview(row)
        container.addSubview(sep)
        row.translatesAutoresizingMaskIntoConstraints = false
        sep.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),

            sep.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            sep.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        return container
    }

    // MARK: - Search bar

    private func setupSearchBar() {
        searchController.searchResultsUpdater              = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder             = "Search rooms"
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }

    // MARK: - Firestore fetch

    private func fetchRooms() {
        db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    self.showAlert(title: "Loading Failed", message: error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.rooms = []
                    self.filteredRooms = []
                    self.updateEmptyState()
                    self.tableView.reloadData()
                    return
                }

                var loadedRooms: [Room] = []
                let dispatchGroup = DispatchGroup()

                for document in documents {
                    let data = document.data()
                    guard let name = data["name"] as? String else { continue }

                    let imageUrl = data["imageUrl"] as? String
                    let hasPhoto = !(imageUrl?.isEmpty ?? true)
                    let roomRef  = self.db.collection("properties")
                        .document(self.property.id)
                        .collection("rooms")
                        .document(document.documentID)

                    var windowCount = 0
                    var hasFloor    = false
                    var loadedWindows: [WindowSpace] = []
                    var loadedFloors:  [FloorSpace]  = []
                    var floorIncluded = true

                    dispatchGroup.enter()
                    let innerGroup = DispatchGroup()

                    // Fetch windows (with full pricing so quote can be computed)
                    innerGroup.enter()
                    roomRef.collection("windows").getDocuments { snapshot, _ in
                        let docs = snapshot?.documents ?? []
                        windowCount = docs.count
                        loadedWindows = docs.compactMap { doc in
                            let d = doc.data()
                            guard let wname = d["name"] as? String else { return nil }
                            return WindowSpace(
                                id: doc.documentID,
                                name: wname,
                                widthMM:  d["widthMM"]  as? Double,
                                heightMM: d["heightMM"] as? Double,
                                imageUrl: d["imageUrl"] as? String,
                                productId:   d["productId"]   as? String,
                                productName: d["productName"] as? String,
                                pricePerSqm: d["pricePerSqm"] as? Double,
                                isIncludedInQuote: d["isIncludedInQuote"] as? Bool ?? false
                            )
                        }
                        innerGroup.leave()
                    }

                    // Fetch floor
                    innerGroup.enter()
                    roomRef.collection("floors").document("mainFloor").getDocument { snapshot, _ in
                        if let d = snapshot?.data(),
                           let w = d["widthMM"] as? Double,
                           let depth = d["depthMM"] as? Double {
                            hasFloor = true
                            floorIncluded = d["isIncludedInQuote"] as? Bool ?? true
                            loadedFloors = [FloorSpace(
                                id: "mainFloor",
                                widthMM:     w,
                                depthMM:     depth,
                                productId:   d["productId"]   as? String,
                                productName: d["productName"] as? String,
                                pricePerSqm: d["pricePerSqm"] as? Double,
                                isIncludedInQuote: floorIncluded
                            )]
                        }
                        innerGroup.leave()
                    }

                    innerGroup.notify(queue: .main) {
                        let isComplete = hasPhoto && windowCount > 0 && hasFloor

                        let room = Room(
                            id: document.documentID,
                            name: name,
                            imageUrl: imageUrl,
                            windows: loadedWindows,
                            floors:  loadedFloors,
                            isComplete: isComplete,
                            windowCount: windowCount,
                            hasFloor: hasFloor,
                            isFloorIncludedInQuote: floorIncluded
                        )
                        loadedRooms.append(room)
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.rooms         = loadedRooms
                    self.filteredRooms = loadedRooms

                    // Re-apply any existing quote selections after a refresh
                    // (selections that were removed because the room no longer exists get cleaned up)
                    self.selectedQuoteRoomIds = self.selectedQuoteRoomIds.filter { id in
                        loadedRooms.contains { $0.id == id }
                    }

                    self.updateEmptyState()
                    self.tableView.reloadData()
                    self.updateQuoteSummary()
                }
            }
    }

    // MARK: - Delete

    private func confirmDeleteRoom(_ room: Room) {
        let alert = UIAlertController(
            title: "Delete Room?",
            message: "This will delete \(room.name), including its windows and floor details. This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteRoom(room)
        })
        present(alert, animated: true)
    }

    private func deleteRoom(_ room: Room) {
        let roomRef = db.collection("properties")
            .document(property.id)
            .collection("rooms")
            .document(room.id)

        let group = DispatchGroup()
        group.enter()
        deleteSubcollection(roomRef.collection("windows")) { group.leave() }
        group.enter()
        deleteSubcollection(roomRef.collection("floors")) { group.leave() }

        group.notify(queue: .main) {
            roomRef.delete { error in
                if let error = error {
                    self.showAlert(title: "Delete Failed", message: error.localizedDescription)
                    return
                }
                self.rooms.removeAll         { $0.id == room.id }
                self.filteredRooms.removeAll { $0.id == room.id }
                self.selectedQuoteRoomIds.remove(room.id)
                self.updateEmptyState()
                self.tableView.reloadData()
                self.updateQuoteSummary()
            }
        }
    }

    private func deleteSubcollection(_ collection: CollectionReference,
                                     completion: @escaping () -> Void) {
        collection.getDocuments { snapshot, _ in
            let group = DispatchGroup()
            snapshot?.documents.forEach { doc in
                group.enter()
                doc.reference.delete { _ in group.leave() }
            }
            group.notify(queue: .main) { completion() }
        }
    }

    // MARK: - Empty state

    private func updateEmptyState() {
        let visibleRooms = isSearching ? filteredRooms : rooms
        if rooms.isEmpty {
            emptyLabel.text   = "No rooms added yet.\nTap + to add the first room."
            emptyLabel.isHidden = false
        } else if visibleRooms.isEmpty {
            emptyLabel.text   = "No matching rooms found."
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func addRoomTapped() {
        let addRoomVC = AddRoomViewController()
        addRoomVC.property = property
        navigationController?.pushViewController(addRoomVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension RoomListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredRooms.count : rooms.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RoomCell", for: indexPath) as? RoomCell else {
            return UITableViewCell()
        }

        let room     = isSearching ? filteredRooms[indexPath.row] : rooms[indexPath.row]
        let inQuote  = selectedQuoteRoomIds.contains(room.id)
        cell.configure(with: room, isInQuote: inQuote)
        cell.delegate      = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedRoom = isSearching ? filteredRooms[indexPath.row] : rooms[indexPath.row]
        let addRoomVC = AddRoomViewController()
        addRoomVC.property    = property
        addRoomVC.roomToEdit  = selectedRoom
        navigationController?.pushViewController(addRoomVC, animated: true)
    }
}

// MARK: - RoomCellDelegate

extension RoomListViewController: RoomCellDelegate {

    func didTapDelete(room: Room) {
        confirmDeleteRoom(room)
    }

    func didTapQuoteToggle(room: Room) {
        if selectedQuoteRoomIds.contains(room.id) {
            selectedQuoteRoomIds.remove(room.id)
        } else {
            selectedQuoteRoomIds.insert(room.id)
        }

        // Refresh only the affected cell for performance
        let source = isSearching ? filteredRooms : rooms
        if let index = source.firstIndex(where: { $0.id == room.id }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? RoomCell {
            cell.setQuoteSelected(selectedQuoteRoomIds.contains(room.id), room: room)
        }

        updateQuoteSummary()
    }
}

// MARK: - UISearchResultsUpdating

extension RoomListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?
            .lowercased()
            .trimmingCharacters(in: .whitespaces),
              !searchText.isEmpty else {
            filteredRooms = rooms
            updateEmptyState()
            tableView.reloadData()
            return
        }

        filteredRooms = rooms.filter { $0.name.lowercased().contains(searchText) }
        updateEmptyState()
        tableView.reloadData()
    }
}
