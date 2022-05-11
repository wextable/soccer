//
//  DebugMenuViewController.swift
//  Sports
//
//  Created by Wesley St. John on 5/2/22.
//

import UIKit

protocol DebugMenuViewControllerDelegate: AnyObject {
    func settingUpdated(_ setting: DebugMenuViewController.Model.Setting, newValue: String)
    func cancelTapped(_ sender: DebugMenuViewController)
    func resetTapped(_ sender: DebugMenuViewController)
    func saveTapped(_ sender: DebugMenuViewController)
}

class DebugMenuViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: DebugMenuViewControllerDelegate?

    private let tableView: UITableView = .init()
    enum Section: Int, Hashable {
        case gameAI
        case xp
        case condition
        case teamAI
        case injury
    }
    enum Row: Hashable {
        case setting(DebugMenuViewController.Model.Setting)
    }
    typealias TableViewDataSource = UITableViewDiffableDataSource<Section, Row>
    private var tableViewDataSource: TableViewDataSource?
    private let saveButtonContainer = BaseView()
    private let saveButton = GlassPrimaryButton(buttonStyle: GlassButtonStyle.large)

    var model: Model { didSet { applyModel() } }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        view.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                 target: self,
                                                 action: #selector(cancel))
        navigationItem.rightBarButtonItem = .init(title: "Reset all",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(reset))

        tableViewDataSource = .init(tableView: tableView) { [weak self] in
            self?.tableview(cellForRow: $2, at: $1)
        }
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorStyle = .none

        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(tableView)
        saveButtonContainer.addAutoLayoutSubview(saveButton)
        view.addAutoLayoutSubview(saveButtonContainer)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButtonContainer.topAnchor),
            saveButtonContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            saveButtonContainer.heightAnchor.constraint(equalToConstant: 60),
            saveButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            saveButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            saveButton.centerXAnchor.constraint(equalTo: saveButtonContainer.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: saveButtonContainer.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.topAnchor.constraint(equalTo: saveButtonContainer.topAnchor,
                                            constant: GlassSpacing.xSmall)
        )

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModel()
    }

    private func tableview(cellForRow row: Row, at indexPath: IndexPath) -> UITableViewCell? {
        switch row {
        case .setting(let settingModel):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "settingCell")
            var configuration = UIListContentConfiguration.valueCell()
            configuration.text = "\(settingModel.name): \(settingModel.displayValue)"
            configuration.secondaryText = settingModel.description
            cell.contentConfiguration = configuration
            return cell
        }
    }

    @objc private func cancel() {
        delegate?.cancelTapped(self)
    }

    @objc private func reset() {
        delegate?.resetTapped(self)
    }

    @objc private func save() {
        delegate?.saveTapped(self)
    }
}

// MARK: - UITableViewDelegate

extension DebugMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let section = Section(rawValue: indexPath.section) else { return }

        var setting = Model.Setting()
        switch section {
        case .gameAI: setting = model.gameAISettings[indexPath.row]
        case .xp: setting = model.xpSettings[indexPath.row]
        case .condition: setting = model.conditionSettings[indexPath.row]
        case .teamAI: setting = model.teamAISettings[indexPath.row]
        case .injury: setting = model.injurySettings[indexPath.row]
        }

        getTextFromAlert(title: setting.name,
                         message: setting.description,
                         initialValue: setting.displayValue) { [weak self] newValue in
            guard let newValue = newValue,
                  let self = self else {
                      return
                  }
            self.delegate?.settingUpdated(setting, newValue: newValue)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section) else { return nil }

        let title: String
        switch sectionType {
        case .gameAI: title = "    Game AI"
        case .xp: title = "    XP"
        case .condition: title = "    Condition"
        case .teamAI: title = "    Team AI"
        case .injury: title = "    Injuries"
        }

        let label = GlassLabel(style: .heading)
        label.text = title
        label.backgroundColor = .white

        return label
    }
}

extension DebugMenuViewController {
    private func getTextFromAlert(title: String,
                                  message: String,
                                  initialValue: String,
                                  completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = initialValue
        }

        let ok = UIAlertAction(title: "OK", style: .default) { action in
            completion(alert.textFields?.first?.text)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(nil)
        }
        alert.addAction(ok)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
}

extension DebugMenuViewController {
    struct Model {

        struct Setting: Hashable {
            enum ValueType {
                case wholeNumber
                case decimalNumber
            }

            var name: String = ""
            var displayValue: String = ""
            var type: ValueType = .wholeNumber
            var description: String = ""
        }

        var title: String = "Game Config"
        var gameAISettings: [Setting] = []
        var xpSettings: [Setting] = []
        var conditionSettings: [Setting] = []
        var teamAISettings: [Setting] = []
        var injurySettings: [Setting] = []
    }

    private func applyModel() {
        title = model.title

        guard let tableViewDataSource = tableViewDataSource else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()

        snapshot.appendSections([.gameAI, .xp, .condition, .teamAI, .injury])
        snapshot.appendItems(model.gameAISettings.map({ .setting($0) }), toSection: .gameAI)
        snapshot.appendItems(model.xpSettings.map({ .setting($0) }), toSection: .xp)
        snapshot.appendItems(model.conditionSettings.map({ .setting($0) }), toSection: .condition)
        snapshot.appendItems(model.teamAISettings.map({ .setting($0) }), toSection: .teamAI)
        snapshot.appendItems(model.injurySettings.map({ .setting($0) }), toSection: .injury)

        tableViewDataSource.apply(snapshot, animatingDifferences: true) { }
    }
}
