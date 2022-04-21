////
////  DebugPanelContainerViewController.swift
////  DebugPanel
////
////  Created by Bharath Rao on 15/01/21.
////  Copyright © 2021 Walmart. All rights reserved.
////
//
//#if DEBUG
//import UIKit
//import WalmartPlatform
//
//public protocol DebugPanelClosable: AnyObject {
//    /// Handles close action
//    func close()
//}
//
///// Model which defines debug panel entry
//public protocol DebugPanelModelProvider {
//    /// Debug panel identifier, Ex: networkLog
//    var identifier: String { get }
//    /// Name of the entry that will be show in the debug panel list
//    var name: String { get }
//    /// Description of the debug panel entry
//    var description: String { get }
//    /// Debug view provider
//    var provider: UIViewController { get }
//}
//
//struct Module: Hashable {
//    let model: DebugPanelModelProvider
//
//    init(_ model: DebugPanelModelProvider) {
//        self.model = model
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(model.identifier)
//    }
//
//    static func == (lhs: Module, rhs: Module) -> Bool {
//        return lhs.model.identifier == rhs.model.identifier &&
//            lhs.model.name == rhs.model.name &&
//            lhs.model.description == rhs.model.description &&
//            lhs.model.provider == rhs.model.provider
//    }
//}
//
//public final class DebugPanelContainerViewController: BaseViewController {
//
//    /// Diffable data source
//    private var tableViewDataSource: ContainerTableViewDiffable?
//
//    /// Diffable Data Source Snapshot
//    private var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Module>()
//
//    /// Tableview
//    private lazy var tableView: UITableView = {
//        return UITableView(frame: .zero, style: .plain)
//    }()
//
//    /// DebugPanelCancellable delegate
//    public weak var delegate: DebugPanelClosable?
//
//    /// Header label
//    private let headerLabel: GlassLabel = {
//        let label = GlassLabel()
//        label.numberOfLines = 0
//        label.font = GlassFont.body2().uiFont
//        label.textColor = GlassColor.gray140.uiColor
//        label.textAlignment = .center
//        return label
//    }()
//
//    /// Stack view with vertical axis
//    private let stackView = UIStackView(axis: .vertical)
//
//    /// Model
//    private var model: GridModel = GridModel() {
//        didSet {
//            // Update model & refresh UI
//            applyModel()
//        }
//    }
//
//    public init(setupDefaultModules: Bool) {
//        super.init(nibName: nil, bundle: nil)
//        // Register modules and middleware
//
//        guard setupDefaultModules
//        else {
//            return
//        }
//    }
//
//    public override func constructView() {
//        super.constructView()
//        navigationItem.title = "Debug Panel 🛠"
//
//        // Label
//        headerLabel.text =
//        """
//        One stop shop to access your features for debugging.
//
//        <Content to be updated>
//        """
//        constructBarButton()
//        constructStackView()
//        constructTableView()
//    }
//
//    public override func constructSubviewHierarchy() {
//        super.constructSubviewHierarchy()
//        view.backgroundColor = .white
//        view.addAutoLayoutSubview(stackView)
//        stackView.addArrangedSubview(headerLabel)
//        view.addAutoLayoutSubview(tableView)
//    }
//
//    public override func constructSubviewLayoutConstraints() {
//        super.constructSubviewLayoutConstraints()
//        NSLayoutConstraint.activate(
//            // StackView
//            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: GlassSpacing.small),
//            stackView.constraints(pinningTo: view, edges: .horizontal, insets: .init(GlassSpacing.small)),
//            // TableView
//            tableView.constraints(pinningTo: view, edges: .horizontal),
//            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: GlassSpacing.small),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
//                                              constant: -GlassSpacing.small)
//        )
//    }
//
//    public func registerModule(debugPanelModel: DebugPanelModelProvider) {
//        model.cellItems.append(Module(debugPanelModel))
//    }
//
//    public func select(identifier: String) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            // Find the row which matches the type
//            guard let selectedRow = self?.model.cellItems.firstIndex(where: { $0.model.identifier == identifier }),
//                  let selectedSection = self?.snapshot.indexOfSection(.features),
//                  let debugPanelTableView = self?.tableView
//            else {
//                return
//            }
//            let indexPath = IndexPath(row: selectedRow, section: selectedSection)
//            self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//            // Select the row for matching DebugPanelModuleType
//            self?.tableView(debugPanelTableView, didSelectRowAt: indexPath)
//        }
//    }
//
//    public func addCellItems(items: [DebugPanelModelProvider]) {
//        for item in items {
//            model.cellItems.append(Module(item))
//        }
//    }
//}
//
//extension DebugPanelContainerViewController {
//    private func constructBarButton() {
//        let doneButton = UIBarButtonItem(title: "Done",
//                                         style: .done,
//                                         target: self,
//                                         action: #selector(doneButtonTapped))
//        navigationItem.rightBarButtonItems = [doneButton]
//    }
//
//    private func constructStackView() {
//        // StackView
//        stackView.spacing = GlassSpacing.small
//        stackView.alignment = .center
//        stackView.backgroundColor = .white
//    }
//
//    private func constructTableView() {
//        // TableView
//        tableView.register(DebugPanelContainerCell.self)
//        tableViewDataSource = .init(tableView: tableView) { tableView, indexPath, item -> UITableViewCell? in
//            let cell: DebugPanelContainerCell = tableView.dequeueCell(for: indexPath)
//            cell.model = .init(title: item.model.name, subtitle: item.model.description)
//            return cell
//        }
//        tableView.delegate = self
//        applyModel()
//    }
//
//    private func applyModel(animated: Bool = true) {
//        guard let tableViewDataSource = tableViewDataSource else {
//            return
//        }
//        snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Module>()
//        snapshot.appendSections([.features])
//        snapshot.appendItems(model.cellItems.map { $0 }, toSection: .features)
//        tableViewDataSource.apply(snapshot, animatingDifferences: animated) { }
//    }
//
//    func constructCloseBarButton(for viewController: UIViewController) {
//        let closeButton = UIBarButtonItem(title: "Close",
//                                          style: .done,
//                                          target: self,
//                                          action: #selector(closeButtonTapped))
//        viewController.navigationItem.rightBarButtonItems = [closeButton]
//    }
//}
//
//// MARK: Actions
//extension DebugPanelContainerViewController {
//    @objc func doneButtonTapped() {
//        // Trigger action to close debug panel
//        delegate?.close()
//    }
//
//    @objc func closeButtonTapped() {
//        // Dismiss presented feature
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//// MARK: UITableViewDelegate
//extension DebugPanelContainerViewController: UITableViewDelegate {
//
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return GlassSpacing.large
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        guard let item = tableViewDataSource?.itemIdentifier(for: indexPath),
//              let section = tableViewDataSource?.snapshot().sectionIdentifier(containingItem: item)
//        else {
//            return
//        }
//        switch section {
//        case .features:
//            // Add close bar button on the view controller
//            constructCloseBarButton(for: item.model.provider)
//            let navController = GlassNavigationController(rootViewController: item.model.provider)
//            present(navController, animated: true, completion: nil)
//        }
//    }
//}
//
//// MARK: Tableview data source
//extension DebugPanelContainerViewController {
//    // Tableview sections
//    private enum SectionIdentifier: String, Hashable {
//        case features = "Features"
//    }
//
//    // Tableview diffable data source
//    private class ContainerTableViewDiffable: UITableViewDiffableDataSource<SectionIdentifier, Module> {
//        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//            return snapshot().sectionIdentifiers[section].rawValue
//        }
//    }
//}
//
//// MARK: Model
//extension DebugPanelContainerViewController {
//    /// Model
//    struct GridModel {
//        // Cell items
//        var cellItems = [Module]()
//    }
//}
//#endif
