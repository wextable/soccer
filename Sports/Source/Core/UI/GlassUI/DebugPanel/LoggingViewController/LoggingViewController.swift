////
////  Copyright © 2020-present Walmart. All rights reserved.
////
//
//#if DEBUG
//import UIKit
//import WalmartPlatform
//
///// A simple view controller that displays network interactions(logs) that are happening in the application.
//public class LoggingViewController: BaseViewController {
//
//    private let tableview = UITableView()
//    private let messageView = UIView()
//
//    private let viewModel: LoggingViewModel
//
//    private var cellHeightCache: [IndexPath: CGFloat] = [:]
//    private let searchController = UISearchController(searchResultsController: nil)
//    private lazy var pasteboard = UIPasteboard.general
//    private var loggingVCStatePersistence: LoggingVCStatePersistable
//
//    public init(viewModel: LoggingViewModel,
//                persistence: LoggingVCStatePersistable = DefaultPersistableState()) {
//        self.viewModel = viewModel
//        self.loggingVCStatePersistence = persistence
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    public override func constructSubviewLayoutConstraints() {
//        view.addAutoLayoutSubview(tableview)
//        NSLayoutConstraint.activate([
//            tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableview.topAnchor.constraint(equalTo: view.topAnchor),
//            tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    public override func constructView() {
//        setupNav()
//        setupMainView()
//        setupTableView()
//        setupSearch()
//    }
//
//    private func setupSearch() {
//        searchController.searchBar.barTintColor = .white
//        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "search"
//    }
//
//    private func setupNav() {
//        title = viewModel.title
//        let clearButton = UIBarButtonItem(title: "Clear",
//                                          style: .plain,
//                                          target: self,
//                                          action: #selector(presentClearAlert))
//        let shareAllButton = UIBarButtonItem(title: "Share",
//                                             style: .plain,
//                                             target: self,
//                                             action: #selector(shareAllAction))
//        navigationItem.leftBarButtonItems = [clearButton, shareAllButton]
//        navigationItem.searchController = searchController
//    }
//
//    private func setupMainView() {
//        view.backgroundColor = GlassColor.gray10.uiColor
//        tableview.backgroundColor = GlassColor.gray10.uiColor
//    }
//
//    private func setupTableView() {
//        tableview.dataSource = self
//        tableview.delegate = self
//        tableview.register(LoggingTableViewCell.self)
//        tableview.separatorStyle = .none
//    }
//
//    @objc private func clearDataAction(alertAction: UIAlertAction) {
//        clearData()
//    }
//
//    private func clearData(completion: (() -> Void)? = nil) {
//        viewModel.clearData { (result) in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                switch result {
//                case .success(let shouldUpdate):
//                    if shouldUpdate {
//                        self.tableview.reloadData()
//                    }
//                case .failure: break
//                }
//                completion?()
//            }
//        }
//    }
//
//    @objc private func presentClearAlert() {
//        let alertVC = UIAlertController(title: "Are you sure you want to clear this data",
//                                        message: "This action cannot be undone", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let clearAction = UIAlertAction(title: "Clear", style: .destructive, handler: clearDataAction(alertAction:))
//        alertVC.addAction(cancelAction)
//        alertVC.addAction(clearAction)
//        self.present(alertVC, animated: true, completion: nil)
//    }
//
//    @objc private func shareAllAction() {
//        let allPayloads = viewModel.allDisplayedEventPayloads
//        let activityVC = UIActivityViewController(activityItems: [allPayloads], applicationActivities: nil)
//        self.present(activityVC, animated: true, completion: nil)
//    }
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Fetch latest data
//        fetchData()
//    }
//
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        onboardingAnimation()
//    }
//
//    private func fetchData() {
//        viewModel.fetchData { (result) in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                switch result {
//                case .success(let shouldUpdate):
//                    if shouldUpdate {
//                        self.tableview.reloadData()
//                    }
//                case .failure: break
//                }
//            }
//        }
//    }
//
//    private func shouldShowOnBoardingAnimation() -> Bool {
//        if loggingVCStatePersistence.isLoggingVCOnboardingSeen {
//            return false
//        } else {
//            loggingVCStatePersistence.update(isOnboardingSeen: true)
//            return true
//        }
//    }
//
//    private func onboardingAnimation() {
//        guard shouldShowOnBoardingAnimation(), !viewModel.displayEventData.isEmpty,
//            let cell = tableview.cellForRow(at: IndexPath(item: 0, section: 0)) as? LoggingTableViewCell else {
//                return
//        }
//        cell.animateSwipeHint()
//
//    }
//
//    private func update(withSearchText searchText: String) {
//        cellHeightCache = [:]
//        viewModel.filter(byText: searchText)
//        tableview.reloadData()
//    }
//
//    private func showMessage(withText text: String) {
//        let messageView = QuickMessageView()
//        messageView.alpha = 0
//        messageView.setup(text: text)
//        view.addAutoLayoutSubview(messageView)
//        messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//        messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
//
//        UIView.animate(
//            withDuration: 0.5,
//            animations: {
//                messageView.alpha = 1
//            },
//            completion: { _ in
//                UIView.animate(
//                    withDuration: 0.5,
//                    delay: 0.5,
//                    animations: {
//                        messageView.alpha = 0
//                    },
//                    completion: { _ in
//                        messageView.removeFromSuperview()
//                    }
//                )
//            }
//        )
//    }
//
//    private func addToPasteBoard(indexPath: IndexPath) {
//        guard indexPath.row < viewModel.displayEventData.count else { return }
//        let item = viewModel.displayEventData[indexPath.row]
//        pasteboard.string = item.entireText
//        showMessage(withText: "Added to Pasteboard")
//    }
//}
//
//extension LoggingViewController: UITableViewDataSource {
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.displayEventData.count
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard indexPath.row < viewModel.displayEventData.count,
//        let cell = tableView.dequeueReusableCell(withIdentifier: LoggingTableViewCell.reuseIdentifier,
//                                                 for: indexPath) as? LoggingTableViewCell else {
//                                                    return UITableViewCell()
//        }
//        let item = viewModel.displayEventData[indexPath.row]
//        cell.setup(title: item.eventName, date: item.formattedDate, description: item.payload)
//        cell.selectionStyle = .none
//        return cell
//    }
//}
//
//extension LoggingViewController: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let height = cellHeightCache[indexPath] {
//            return height
//        } else {
//            return UITableView.automaticDimension
//        }
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        addToPasteBoard(indexPath: indexPath)
//    }
//
//    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if cellHeightCache[indexPath] == nil {
//           cellHeightCache[indexPath] = cell.bounds.height
//        }
//    }
//
//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return LoggingTableViewCell.suggestedHeight
//    }
//
//    // swiftlint:disable:next line_length
//    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] (_, _, _) in
//            guard let self = self, indexPath.row < self.viewModel.displayEventData.count else { return }
//            let item = self.viewModel.displayEventData[indexPath.row]
//            let itemInfo = item.entireText
//            let activityVC = UIActivityViewController(activityItems: [itemInfo], applicationActivities: nil)
//            self.present(activityVC, animated: true, completion: nil)
//        }
//        shareAction.backgroundColor = GlassColor.blue50.uiColor
//        let copyAction = UIContextualAction(style: .normal, title: "Copy") { [weak self] (_, _, _) in
//            self?.addToPasteBoard(indexPath: indexPath)
//
//        }
//        copyAction.backgroundColor = GlassColor.blue150.uiColor
//
//        return UISwipeActionsConfiguration(actions: [shareAction, copyAction])
//    }
//}
//
//extension LoggingViewController: UISearchResultsUpdating {
//    public func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
//        update(withSearchText: text)
//    }
//}
//
//class QuickMessageView: BaseView {
//
//    private let textLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    override func constructSubviewLayoutConstraints() {
//        self.addAutoLayoutSubview(textLabel)
//        NSLayoutConstraint.activate([
//            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GlassSpacing.xSmall),
//            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GlassSpacing.xSmall),
//            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: GlassSpacing.xxSmall),
//            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -GlassSpacing.xxSmall)
//        ])
//
//        self.heightAnchor.constraint(greaterThanOrEqualToConstant: GlassSpacing.medium).isActive = true
//        self.widthAnchor.constraint(greaterThanOrEqualToConstant: GlassSpacing.mediumSmall).isActive = true
//    }
//
//    override func constructView() {
//        backgroundColor = .white
//        textLabel.textColor = .black
//        self.roundCorners(radius: GlassSpacing.xxSmall)
//    }
//
//    func setup(text: String) {
//        textLabel.text = text
//    }
//}
//
//public class LoggingViewModel {
//
//    let logger: Loggable
//    let title: String
//
//    public init(logger: Loggable, title: String = "") {
//        self.logger = logger
//        self.title = title
//    }
//
//    private var eventData: [EventTrackable] = [] {
//        didSet {
//            displayEventData = eventData
//        }
//    }
//
//    private(set) var displayEventData: [EventTrackable] = []
//
//    func filter(byText text: String) {
//        if text == "" {
//            displayEventData = eventData
//        } else {
//            let searchText = text.lowercased()
//            displayEventData = eventData.filter { data in
//                let text = data.entireText.lowercased()
//                return text.contains(searchText)
//            }
//        }
//    }
//
//    var allDisplayedEventPayloads: String {
//        let allTextPayloads = displayEventData.map { $0.entireText }
//        return allTextPayloads.joined(separator: "\n")
//    }
//
//    func fetchData(completion: (Result<Bool, Error>) -> Void) {
//        logger.fetchLog(completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let events):
//                self.eventData = events
//                completion(.success(true))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        })
//    }
//
//    func clearData(completion: (Result<Bool, Error>) -> Void) {
//        logger.clearLog { [weak self] (result) in
//            guard let self = self else { return }
//            switch result {
//            case .success(let shouldUpdate):
//                self.eventData = []
//                completion(.success(shouldUpdate))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//}
//
//extension LoggingViewController {
//    var testHooks: TestHooks {
//        return TestHooks(target: self)
//    }
//
//    struct TestHooks {
//        private let target: LoggingViewController
//
//        fileprivate init(target: LoggingViewController) {
//            self.target = target
//        }
//
//        var tableview: UITableView {
//            return target.tableview
//        }
//
//        func clearData(completion: @escaping (() -> Void)) {
//            target.clearData(completion: completion)
//        }
//
//        var pasteBoard: UIPasteboard {
//            return target.pasteboard
//        }
//
//        var persistence: LoggingVCStatePersistable {
//            return target.loggingVCStatePersistence
//        }
//    }
//}
//
//public protocol LoggingVCStatePersistable {
//    var isLoggingVCOnboardingSeen: Bool { get }
//    func update(isOnboardingSeen: Bool)
//}
//
//public extension LoggingVCStatePersistable {
//    var isLoggingVCOnboardingSeen: Bool { return true }
//    func update(isOnboardingSeen: Bool) { }
//}
//
//public class DefaultPersistableState: LoggingVCStatePersistable {
//    public init() { }
//}
//#endif
