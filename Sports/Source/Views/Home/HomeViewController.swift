//
//  HomeViewController.swift
//  Sports
//
//  Created by Wesley St. John on 12/27/21.
//

import UIKit

protocol HomeViewControllerDelegate: AnyObject {
    func startGame()
    func loadGame()
}

class HomeViewController: StackViewController {

    // MARK: Properties
    weak var delegate: HomeViewControllerDelegate?

    private let label = GlassLabel(style: .heading)
    private let newButton = GlassPrimaryButton(buttonStyle: GlassButtonStyle.large)
    private let loadButton = GlassPrimaryButton(buttonStyle: GlassButtonStyle.large)

    var model: Model {
        didSet { applyModel() }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init()
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()

        label.numberOfLines = 0
        label.textAlignment = .center

        newButton.addTarget(self, action: #selector(newButtonTapped), for: .touchUpInside)
        loadButton.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)

        stackView.distribution = .fillProportionally
        stackView.spacing = GlassSpacing.small
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        stackView.addArrangedSubviews([
            label,
            newButton.paddedContainer(),
            loadButton.paddedContainer()
        ])
    }

    // MARK: Actions

    @objc private func newButtonTapped() {
        delegate?.startGame()
    }

    @objc private func loadButtonTapped() {
        delegate?.loadGame()
    }

}

extension HomeViewController {
    struct Model {
        var title: String = ""
        var mainDescription: String = ""
        var newLeagueButtonTitle: String?
        var loadLeagueButtonTitle: String?
    }

    private func applyModel() {
        title = model.title
        label.text = model.mainDescription
        newButton.setTitle(model.newLeagueButtonTitle, for: .normal)
        loadButton.setTitle(model.loadLeagueButtonTitle, for: .normal)
        loadButton.isHidden = (model.loadLeagueButtonTitle == nil)
        view.backgroundColor = .white
    }
}
