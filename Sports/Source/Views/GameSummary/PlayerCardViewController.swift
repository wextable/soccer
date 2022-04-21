//
//  PlayerCardViewController.swift
//  Sports
//
//  Created by Wesley St. John on 4/19/22.
//

import UIKit

protocol PlayerCardViewControllerDelegate: AnyObject {
    func playerSelected(withID id: String, sender: PlayerCardViewController)
}

class PlayerCardViewController: BaseViewController {

    // MARK: Properties

    weak var delegate: PlayerCardViewControllerDelegate?

    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView =  UICollectionView(frame: .zero, collectionViewLayout: .init())
    enum Section: Int, Hashable {
        case players
    }
    enum Row: Hashable {
        case player(PlayerCardView.Model)
    }
    typealias CollectionViewDataSource = UICollectionViewDiffableDataSource<Section, Row>
    private var collectionViewDataSource: CollectionViewDataSource?

    var model: Model { didSet { applyModel() } }

    private func applyModel() {
        guard let collectionViewDataSource = collectionViewDataSource else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()

        snapshot.appendSections([.players])
        snapshot.appendItems(model.playerCardModels.map({ .player($0) }), toSection: .players)

        collectionViewDataSource.apply(snapshot, animatingDifferences: true) { }
    }

    // MARK: Initialization

    init(model: Model = .init()) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        applyModel()
    }

    // MARK: Construction

    override func constructView() {
        super.constructView()
        view.backgroundColor = .clear

        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 6
        flowLayout.itemSize = CGSize(width: 100, height: 110)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(PlayerCardCell.self)
        collectionViewDataSource = .init(collectionView: collectionView) { [weak self] in
            self?.collectionview(cellForRow: $2, at: $1)
        }
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(collectionView)
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        collectionView.constraints(pinningTo: view).activate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyModel()
    }

    private func collectionview(cellForRow row: Row, at indexPath: IndexPath) -> UICollectionViewCell? {
        switch row {
        case .player(let cellModel):
            guard let cellModel = model.playerCardModels.first(where: { $0 == cellModel }) else {
                return nil
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerCardCell.reuseIdentifier,
                                                          for: indexPath) as? PlayerCardCell
            cell?.model = cellModel
            return cell
        }
    }

}

extension PlayerCardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < model.playerCardModels.count else { return }
        delegate?.playerSelected(withID: model.playerCardModels[indexPath.item].id,
                                 sender: self)
    }
}

extension PlayerCardViewController {
    struct Model {
        var playerCardModels: [PlayerCardView.Model] = []
    }
}
