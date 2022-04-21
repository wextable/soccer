//
//  Copyright © 2020-present Walmart. All rights reserved.
//

#if DEBUG
import UIKit

public class LoggingTableViewCell: BaseTableViewCell {

    static let suggestedHeight: CGFloat = 300
    let mainView = UIView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let descriptionLabel = UILabel()

    public override func constructSubviewLayoutConstraints() {
        contentView.addAutoLayoutSubview(mainView)
        mainView.addAutoLayoutSubview(titleLabel)
        mainView.addAutoLayoutSubview(dateLabel)
        mainView.addAutoLayoutSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                              constant: GlassSpacing.xSmall),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                               constant: -GlassSpacing.xSmall),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                          constant: GlassSpacing.xSmall),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                             constant: -GlassSpacing.xSmall),
            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor,
                                                constant: GlassSpacing.xSmall),
            titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor,
                                            constant: GlassSpacing.xSmall),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor,
                                                 constant: -GlassSpacing.xSmall),
            dateLabel.topAnchor.constraint(equalTo: mainView.topAnchor,
                                           constant: GlassSpacing.xSmall),
            dateLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                                constant: -GlassSpacing.xSmall),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                  constant: GlassSpacing.xSmall),
            descriptionLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                                       constant: -GlassSpacing.xSmall),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: mainView.bottomAnchor,
                                                     constant: -GlassSpacing.xSmall)
        ])
    }

    public override func constructView() {
        self.backgroundColor = GlassColor.blue150.uiColor
        contentView.backgroundColor = GlassColor.gray10.uiColor
        mainView.backgroundColor = .white
        mainView.roundCorners(radius: 4)
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .black
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        dateLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = .black
        titleLabel.numberOfLines = 1
        dateLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 50
    }

    func setup(title: String?, date: String?, description: String?) {
        if let title = title, !title.isEmpty {
            titleLabel.text = title
        } else {
            titleLabel.text = "----"
        }
        dateLabel.text = date
        descriptionLabel.text = description
    }

    func animateSwipeHint() {
        showHintFromRight()
    }

    private func showHintFromRight() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0.3,
            options: [.curveEaseIn],
            animations: {
                self.contentView.transform = CGAffineTransform(translationX: 30, y: 0)
            }
        )
    }
}
#endif
