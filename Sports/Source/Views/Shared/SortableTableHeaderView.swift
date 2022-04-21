//
//  SortableTableHeaderView.swift
//  Sports
//
//  Created by Wesley St. John on 12/30/21.
//

import UIKit

protocol SortableTableHeaderViewDelegate: AnyObject {
    func columnTapped(_ column: SortableTableHeaderView.Model.Column)
}

class SortableTableHeaderView: BaseView {

    private let stackView: UIStackView = .init(axis: .horizontal)

    weak var delegate: SortableTableHeaderViewDelegate?

    var model: Model = .init() {
        didSet { applyModel() }
    }

    private func applyModel() {

        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        stackView.removeAllArrangedSubviews()

        for col in model.columns {
            let button = GlassLinkButton()
            button.setTitle(col.displayName, for: .normal)
            button.contentHorizontalAlignment = .left
            stackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: col.width).activate()
            button.onTap = { [weak self] in
                self?.delegate?.columnTapped(col)
            }
        }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(frame: .zero)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        stackView.distribution = .fillProportionally
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()
        addAutoLayoutSubview(stackView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

//        let standardWidth = 33.0
        NSLayoutConstraint.activate(
            stackView.constraints(pinningTo: self, insets: .init(floatLiteral: 4.0))
//            positionLabel.widthAnchor.constraint(equalToConstant: standardWidth),
//            nameLabel.widthAnchor.constraint(equalToConstant: 100.0),
//            overallLabel.widthAnchor.constraint(equalToConstant: standardWidth),
//            ageLabel.widthAnchor.constraint(equalToConstant: standardWidth),
//            salaryLabel.widthAnchor.constraint(equalToConstant: standardWidth)
        )
    }
}

extension SortableTableHeaderView {
    struct Model {

        var columns: [Column] = []

        struct Column {
            var id: String = ""
            var displayName: String = ""
            var width: CGFloat = 0.0
        }
    }
}

class TableHeaderView: BaseTableViewHeaderFooterView {

    private var headerView: UIView = .init()

    weak var delegate: SortableTableHeaderViewDelegate?

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        headerView = makeHeaderView()

        addAutoLayoutSubview(headerView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate([
            headerView.constraints(pinningTo: safeAreaLayoutGuide, edges: .all),
        ])
    }

    private func makeHeaderView() -> UIView {
        let model = SortableTableHeaderView.Model(columns: [
            .init(id: "ranking", displayName: "#", width: 33.0),
            .init(id: "displayName", displayName: "Team", width: 100.0),
            .init(id: "wins", displayName: "W", width: 33.0),
            .init(id: "draws", displayName: "D", width: 33.0),
            .init(id: "losses", displayName: "L", width: 33.0),            
            .init(id: "points", displayName: "Pts", width: 33.0),
            .init(id: "goalsFor", displayName: "GF", width: 33.0),
            .init(id: "goalsAgainst", displayName: "GA", width: 33.0),
            .init(id: "goalsDifferential", displayName: "GD", width: 33.0)
        ])

        let view = SortableTableHeaderView(model: model)
        view.backgroundColor = GlassColor.gray20.uiColor
        view.delegate = self
        return view
    }

}

extension TableHeaderView: SortableTableHeaderViewDelegate {

    func columnTapped(_ column: SortableTableHeaderView.Model.Column) {
        delegate?.columnTapped(column)
    }
}

