//
//  GameHighlightsViewController.swift
//  Sports
//
//  Created by Wesley St. John on 2/28/22.
//

import UIKit

protocol GameHighlightsViewControllerDelegate: AnyObject {
    func closeButtonTapped(_ sender: GameHighlightsViewController)
    func halftimeReached(_ sender: GameHighlightsViewController)
}

class GameHighlightsViewController: BaseViewController {

    // MARK: Properties
    weak var delegate: GameHighlightsViewControllerDelegate?

    private let fieldImageView = UIImageView()
    private let keeperView = HighlightPlayerView()
    private let shooterView = HighlightPlayerView()
    private let passerView = HighlightPlayerView()
    private let otherAttackerViews = [HighlightPlayerView(),
                                      HighlightPlayerView(),
                                      HighlightPlayerView()]
    private let defenderViews = [HighlightPlayerView(),
                                 HighlightPlayerView(),
                                 HighlightPlayerView(),
                                 HighlightPlayerView()]
    private let ballImageView = UIImageView()

    private let hudView = HighlightHUDView()
    private let xButton = UIButton()

    private let goalTextImageView = UIImageView()
    private let goalPlayerView = PlayerHighlightProfileView()

    private lazy var zones: GameHighlightZones = {
        return GameHighlightZones()
    }()

    // MARK: Debug Views
    private let showZones = false
    private let fieldZone = UIView()
    private let goalZone = UIView()
    private let keeperZone = UIView()
    private let oneAttackerZone = UIView()
    private let twoAttackerZone1 = UIView()
    private let twoAttackerZone2 = UIView()
    private let threeAttackerZone1 = UIView()
    private let threeAttackerZone2 = UIView()
    private let threeAttackerZone3 = UIView()
    private let fourAttackerZone1 = UIView()
    private let fourAttackerZone2 = UIView()
    private let fourAttackerZone3 = UIView()
    private let fourAttackerZone4 = UIView()
    private let oneDefenderZone = UIView()
    private let twoDefenderZone1 = UIView()
    private let twoDefenderZone2 = UIView()
    private let threeDefenderZone1 = UIView()
    private let threeDefenderZone2 = UIView()
    private let threeDefenderZone3 = UIView()
    private let fourDefenderZone1 = UIView()
    private let fourDefenderZone2 = UIView()
    private let fourDefenderZone3 = UIView()
    private let fourDefenderZone4 = UIView()

    private var highlightIndex = 0
    private var haveReachedHalftime = false

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

        let width = UIScreen.main.bounds.size.width
        fieldImageView.image = UIImage(named: "field_full")?.resizedTopAlignedToFill(newWidth: width)
        fieldImageView.contentMode = .top

        ballImageView.image = UIImage(named: "icon_ball")
        xButton.setImage(UIImage(named: "button_icon_x"), for: .normal)
        xButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        xButton.alpha = 0.5

        goalTextImageView.image = UIImage(named: "icon_goalText")
        goalTextImageView.isHidden = true
        goalPlayerView.isHidden = true

        fieldZone.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
        goalZone.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        keeperZone.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        oneAttackerZone.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        twoAttackerZone1.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        twoAttackerZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        threeAttackerZone1.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        threeAttackerZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        threeAttackerZone3.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        fourAttackerZone1.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        fourAttackerZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        fourAttackerZone3.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        fourAttackerZone4.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        oneDefenderZone.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        twoDefenderZone1.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        twoDefenderZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        threeDefenderZone1.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        threeDefenderZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        threeDefenderZone3.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        fourDefenderZone1.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        fourDefenderZone2.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.5)
        fourDefenderZone3.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        fourDefenderZone4.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    override func constructSubviewHierarchy() {
        super.constructSubviewHierarchy()

        view.addAutoLayoutSubview(fieldImageView)

        setupDebugZoneViews()

        view.addSubview(ballImageView)
        view.addSubview(keeperView)
        view.addSubview(shooterView)
        view.addSubview(passerView)
        for otherAttackerView in otherAttackerViews {
            view.addSubview(otherAttackerView)
        }
        for defenderView in defenderViews {
            view.addSubview(defenderView)
        }

        view.addAutoLayoutSubview(hudView)
        view.addAutoLayoutSubview(xButton)

        view.addAutoLayoutSubview(goalTextImageView)
        view.addAutoLayoutSubview(goalPlayerView)

        _ = setupHighlight(index: 0)
    }

    func setupDebugZoneViews() {

        guard showZones else { return }

        view.addSubview(fieldZone)
        view.addSubview(goalZone)
        view.addSubview(keeperZone)
        view.addSubview(oneAttackerZone)
        view.addSubview(twoAttackerZone1)
        view.addSubview(twoAttackerZone2)
        view.addSubview(threeAttackerZone1)
        view.addSubview(threeAttackerZone2)
        view.addSubview(threeAttackerZone3)
        view.addSubview(fourAttackerZone1)
        view.addSubview(fourAttackerZone2)
        view.addSubview(fourAttackerZone3)
        view.addSubview(fourAttackerZone4)
        view.addSubview(oneDefenderZone)
        view.addSubview(twoDefenderZone1)
        view.addSubview(twoDefenderZone2)
        view.addSubview(threeDefenderZone1)
        view.addSubview(threeDefenderZone2)
        view.addSubview(threeDefenderZone3)
        view.addSubview(fourDefenderZone1)
        view.addSubview(fourDefenderZone2)
        view.addSubview(fourDefenderZone3)
        view.addSubview(fourDefenderZone4)

        fieldZone.frame = zones.field
        goalZone.frame = zones.goal
        keeperZone.frame = zones.keeper
        oneAttackerZone.frame = zones.oneAttackerStart
        twoAttackerZone1.frame = zones.twoAttackerStart[0]
        twoAttackerZone2.frame = zones.twoAttackerStart[1]
        threeAttackerZone1.frame = zones.threeAttackerStart[0]
        threeAttackerZone2.frame = zones.threeAttackerStart[1]
        threeAttackerZone3.frame = zones.threeAttackerStart[2]
        fourAttackerZone1.frame = zones.fourAttackerStart[0]
        fourAttackerZone2.frame = zones.fourAttackerStart[1]
        fourAttackerZone3.frame = zones.fourAttackerStart[2]
        fourAttackerZone4.frame = zones.fourAttackerStart[3]
        oneDefenderZone.frame = zones.oneDefenderStart
        twoDefenderZone1.frame = zones.twoDefenderStart[0]
        twoDefenderZone2.frame = zones.twoDefenderStart[1]
        threeDefenderZone1.frame = zones.threeDefenderStart[0]
        threeDefenderZone2.frame = zones.threeDefenderStart[1]
        threeDefenderZone3.frame = zones.threeDefenderStart[2]
        fourDefenderZone1.frame = zones.fourDefenderStart[0]
        fourDefenderZone2.frame = zones.fourDefenderStart[1]
        fourDefenderZone3.frame = zones.fourDefenderStart[2]
        fourDefenderZone4.frame = zones.fourDefenderStart[3]
    }

    override func constructSubviewLayoutConstraints() {
        super.constructSubviewLayoutConstraints()

        NSLayoutConstraint.activate(
            fieldImageView.topAnchor.constraint(equalTo: view.topAnchor),
            fieldImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            fieldImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            hudView.topAnchor.constraint(equalTo: view.topAnchor, constant: GlassSpacing.small),
            hudView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: GlassSpacing.small),
            xButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            xButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            xButton.widthAnchor.constraint(equalToConstant: 40.0),
            xButton.heightAnchor.constraint(equalToConstant: 40.0),
            goalTextImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goalTextImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                       constant: 0.5),
            goalPlayerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goalPlayerView.topAnchor.constraint(equalTo: goalTextImageView.bottomAnchor,
                                                constant: GlassSpacing.medium)
        )
    }

    @objc func closeButtonTapped() {
        delegate?.closeButtonTapped(self)
    }
}

extension GameHighlightsViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if highlightIndex == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playHighlight(index: self.highlightIndex)
            }
        }
    }
}

extension GameHighlightsViewController {

    func startSecondHalf() {
        if setupHighlight(index: model.numFirstHalfHighlights) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playHighlight(index: self.model.numFirstHalfHighlights)
            }
        }
    }

    func setupHighlight(index: Int) -> Bool {
        guard index < model.highlightModels.count else {
            delegate?.closeButtonTapped(self)
            return false
        }

        guard index != model.numFirstHalfHighlights  || haveReachedHalftime else {
            delegate?.halftimeReached(self)
            haveReachedHalftime = true
            return false
        }

        let highlightModel = model.highlightModels[index]

        hudView.model = highlightModel.hudModel
        keeperView.model = highlightModel.keeperModel
        shooterView.model = highlightModel.shooterModel
        if let assisterModel = highlightModel.passerModel {
            passerView.model = assisterModel
            passerView.isHidden = false
        } else {
            passerView.isHidden = true
        }

        for view in otherAttackerViews {
            view.isHidden = true
        }
        for i in 0..<highlightModel.otherAttackerModels.count {
            otherAttackerViews[i].model = highlightModel.otherAttackerModels[i]
            otherAttackerViews[i].isHidden = false
        }

        for view in defenderViews {
            view.isHidden = true
        }
        for i in 0..<highlightModel.defenderModels.count {
            defenderViews[i].model = highlightModel.defenderModels[i]
            defenderViews[i].isHidden = false
        }

        if let scorerProfileModel = highlightModel.scorerProfileModel {
            goalPlayerView.model = scorerProfileModel
        }

        switch highlightModel.type {
        case .regular: setNormalStartingPositions(highlightModel: highlightModel)
        case .penalty: setPenaltyStartingPositions(highlightModel: highlightModel)
        }

        toggleZones(highlightModel: highlightModel)

        return true
    }

    func setNormalStartingPositions(highlightModel: Model.HighlightModel) {
        let playerSize = zones.playerSize
        let ballSize = zones.ballSize

        let keeperPosition = zones.randomKeeperStart()
        keeperView.frame = CGRect(x: keeperPosition.x - playerSize.width/2.0,
                                  y: keeperPosition.y,
                                  width: playerSize.width,
                                  height: playerSize.height)

        let highlightHasPass = highlightModel.passerModel != nil
        var numAttackers = 1
        if highlightHasPass {
            numAttackers += 1
        }
        numAttackers += highlightModel.otherAttackerModels.count

        let attackerPositions = zones.randomAttackerStarts(numAttackers: numAttackers)

        shooterView.frame = CGRect(x: attackerPositions[0].x - playerSize.width/2.0,
                                   y: attackerPositions[0].y - playerSize.height/2.0,
                                  width: playerSize.width,
                                  height: playerSize.height)


        if highlightHasPass {
            passerView.frame = CGRect(x: attackerPositions[1].x - playerSize.width/2.0,
                                      y: attackerPositions[1].y - playerSize.height/2.0,
                                      width: playerSize.width,
                                      height: playerSize.height)

            ballImageView.frame = CGRect(x: passerView.center.x - ballSize/2.0,
                                         y: passerView.frame.origin.y - ballSize * 0.5,
                                         width: ballSize,
                                         height: ballSize)
        } else {
            ballImageView.frame = CGRect(x: shooterView.center.x - ballSize/2.0,
                                         y: shooterView.frame.origin.y - ballSize * 0.5,
                                         width: ballSize,
                                         height: ballSize)
        }

        let startingPositionIndex = highlightHasPass ? 2 : 1
        for i in 0..<highlightModel.otherAttackerModels.count {
            let positionIndex = startingPositionIndex + i
            let view = otherAttackerViews[i]
            view.frame = CGRect(x: attackerPositions[positionIndex].x - playerSize.width/2.0,
                                y: attackerPositions[positionIndex].y - playerSize.height/2.0,
                                width: playerSize.width,
                                height: playerSize.height)
        }

        let numDefenders = highlightModel.defenderModels.count
        let defenderPositions = zones.randomDefenderPositions(numDefenders: numDefenders)
        for i in 0..<numDefenders {
            let view = defenderViews[i]
            view.frame = CGRect(x: defenderPositions[i].x - playerSize.width/2.0,
                                y: defenderPositions[i].y - playerSize.height/2.0,
                                width: playerSize.width,
                                height: playerSize.height)
        }
    }

    func setPenaltyStartingPositions(highlightModel: Model.HighlightModel) {
        let playerSize = zones.playerSize
        let ballSize = zones.ballSize

        let keeperPosition = zones.penaltyKeeperStart()
        keeperView.frame = CGRect(x: keeperPosition.x - playerSize.width/2.0,
                                  y: keeperPosition.y,
                                  width: playerSize.width,
                                  height: playerSize.height)

        let ballPosition = zones.penaltySpot
        ballImageView.frame = CGRect(x: ballPosition.x - ballSize/2.0,
                                     y: ballPosition.y - ballSize/2.0,
                                     width: ballSize,
                                     height: ballSize)

        let attackerPosition = zones.penaltyAttackerStart()
        shooterView.frame = CGRect(x: attackerPosition.x - playerSize.width/2.0,
                                   y: attackerPosition.y - playerSize.height/2.0,
                                   width: playerSize.width,
                                   height: playerSize.height)
    }

    func toggleZones(highlightModel: Model.HighlightModel) {

        oneAttackerZone.isHidden = true
        twoAttackerZone1.isHidden = true
        twoAttackerZone2.isHidden = true
        threeAttackerZone1.isHidden = true
        threeAttackerZone2.isHidden = true
        threeAttackerZone3.isHidden = true
        fourAttackerZone1.isHidden = true
        fourAttackerZone2.isHidden = true
        fourAttackerZone3.isHidden = true
        fourAttackerZone4.isHidden = true

        var numAttackers = 1
        if highlightModel.passerModel != nil {
            numAttackers += 1
        }
        numAttackers += highlightModel.otherAttackerModels.count
        switch numAttackers {
        case 1:
            oneAttackerZone.isHidden = false
        case 2:
            twoAttackerZone1.isHidden = false
            twoAttackerZone2.isHidden = false
        case 3:
            threeAttackerZone1.isHidden = false
            threeAttackerZone2.isHidden = false
            threeAttackerZone3.isHidden = false
        case 4:
            fourAttackerZone1.isHidden = false
            fourAttackerZone2.isHidden = false
            fourAttackerZone3.isHidden = false
            fourAttackerZone4.isHidden = false
        default:
            break
        }

        keeperZone.isHidden = false

        oneDefenderZone.isHidden = true
        twoDefenderZone1.isHidden = true
        twoDefenderZone2.isHidden = true
        threeDefenderZone1.isHidden = true
        threeDefenderZone2.isHidden = true
        threeDefenderZone3.isHidden = true
        fourDefenderZone1.isHidden = true
        fourDefenderZone2.isHidden = true
        fourDefenderZone3.isHidden = true
        fourDefenderZone4.isHidden = true

        let numDefenders = highlightModel.defenderModels.count
        switch numDefenders {
        case 1:
            oneDefenderZone.isHidden = false
        case 2:
            twoDefenderZone1.isHidden = false
            twoDefenderZone2.isHidden = false
        case 3:
            threeDefenderZone1.isHidden = false
            threeDefenderZone2.isHidden = false
            threeDefenderZone3.isHidden = false
        case 4:
            fourDefenderZone1.isHidden = false
            fourDefenderZone2.isHidden = false
            fourDefenderZone3.isHidden = false
            fourDefenderZone4.isHidden = false
        default:
            break
        }

    }

    func playHighlight(index: Int) {
        guard index < model.highlightModels.count else { return }
        let highlightModel = model.highlightModels[index]

        switch highlightModel.type {
        case .regular: animateRegularHighlight(highlightModel: highlightModel)
        case .penalty: animatePenaltyHighlight(highlightModel: highlightModel)
        }
    }

    func animateRegularHighlight(highlightModel: Model.HighlightModel) {
        if let passerModel = highlightModel.passerModel {
            animatePassThenShot(shooter: highlightModel.shooterModel,
                                passer: passerModel,
                                keeper: highlightModel.keeperModel,
                                result: highlightModel.result)
        } else {
            animateSoloShot(shooter: highlightModel.shooterModel,
                            keeper: highlightModel.keeperModel,
                            result: highlightModel.result)
        }

        animateOtherAttackers(attackers: highlightModel.otherAttackerModels)
        animateDefenders(defenders: highlightModel.defenderModels)
    }

    func animatePenaltyHighlight(highlightModel: Model.HighlightModel) {
        let shooter = highlightModel.shooterModel
        let shooterPosition = ballImageView.center
        let shooterMovement = CGPoint(x: shooterView.center.x - shooterPosition.x,
                                      y: shooterView.center.y - shooterPosition.y)
        let shooterDuration = shooterMovement.magnitude / (CGFloat(shooter.ratings.speed) * zones.attackerSpeedFactor)

        UIView.animate(withDuration: shooterDuration, delay: 1.75, options: .curveEaseIn) {
            self.shooterView.center = shooterPosition
        } completion: { _ in
            self.animateShot(shooter: shooter, result: highlightModel.result)
            self.animateKeeperPenaltyDefense(keeper: highlightModel.keeperModel)
        }
    }

    func animateKeeperPenaltyDefense(keeper: HighlightPlayerView.Model) {
        let keeperPosition = zones.randomKeeperStart()
        let keeperMovement = CGPoint(x: keeperView.center.x - keeperPosition.x,
                                    y: keeperView.center.y - keeperPosition.y)
        let keeperDuration = keeperMovement.magnitude / (CGFloat(keeper.ratings.goalkeeping) * zones.keeperDivingSpeedFactor)

        UIView.animate(withDuration: keeperDuration, delay: 0, options: .curveEaseOut) {
            self.keeperView.center = keeperPosition
        }
    }

    func animatePassThenShot(shooter: HighlightPlayerView.Model,
                             passer: HighlightPlayerView.Model,
                             keeper: HighlightPlayerView.Model,
                             result: Model.HighlightResult) {
        let shooterMovement = zones.randomAttackerMovement()
        let passerMovement = zones.randomAttackerMovement()

        let shooterDuration = shooterMovement.magnitude / (CGFloat(shooter.ratings.speed) * zones.attackerSpeedFactor)
        let passerDuration = passerMovement.magnitude / (CGFloat(passer.ratings.speed) * zones.attackerSpeedFactor)
        let maxDuration = max(shooterDuration, passerDuration)

        UIView.animate(withDuration: shooterDuration, delay: 0, options: .curveEaseIn) {
            self.shooterView.center = CGPoint(x: self.shooterView.center.x + shooterMovement.x,
                                              y: self.shooterView.center.y + shooterMovement.y)
        }

        UIView.animate(withDuration: passerDuration, delay: 0, options: .curveEaseIn) {
            self.passerView.center = CGPoint(x: self.passerView.center.x + passerMovement.x,
                                             y: self.passerView.center.y + passerMovement.y)
            self.ballImageView.center = CGPoint(x: self.passerView.center.x,
                                                y: self.passerView.frame.origin.y)
        }

        animateKeeper(keeper: keeper, ballPosition: ballImageView.center)

        DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) {
            self.animatePass(shooter: shooter,
                             passer: passer,
                             keeper: keeper,
                             result: result)
        }
    }

    func animateSoloShot(shooter: HighlightPlayerView.Model,
                         keeper: HighlightPlayerView.Model,
                         result: Model.HighlightResult) {
        let shooterMovement = zones.randomAttackerMovement()
        let shooterDuration = shooterMovement.magnitude / (CGFloat(shooter.ratings.speed) * zones.attackerSpeedFactor)

        let shotPosition = CGPoint(x: self.shooterView.center.x + shooterMovement.x,
                                   y: self.shooterView.center.y + shooterMovement.y)

        UIView.animate(withDuration: shooterDuration, delay: 0, options: .curveEaseIn) {
            self.shooterView.center = shotPosition
            self.ballImageView.center = shotPosition
        } completion: { _ in
            self.animateShot(shooter: shooter, result: result)
        }

        animateKeeper(keeper: keeper, ballPosition: shotPosition)
    }

    func animateKeeper(keeper: HighlightPlayerView.Model, ballPosition: CGPoint) {
        let ballOffsetFromCenterBackOfGoal = CGPoint(
            x: ballPosition.x - zones.centerBackOfGoal.x, // 300-400=-100
            y: ballPosition.y - zones.centerBackOfGoal.y  // 220-20=200
        )
        let slope = ballOffsetFromCenterBackOfGoal.y / ballOffsetFromCenterBackOfGoal.x // 200/-100=-2
        let keeperYOffsetFromOrigin = keeperView.frame.origin.y - zones.centerBackOfGoal.y // 50-20=30
        let keeperTargetOffsetXFromOrigin = keeperYOffsetFromOrigin / slope // 30/-2=-15
        let keeperOffsetFromOrigin = keeperView.frame.origin.x - zones.centerBackOfGoal.x // 420-400=20
        let keeperTargetX = zones.centerBackOfGoal.x + keeperTargetOffsetXFromOrigin // 400+(-15) = 385
        let keeperDistanceX = abs(keeperOffsetFromOrigin - keeperTargetOffsetXFromOrigin) // 20-(-15)=35
        let keeperDuration = keeperDistanceX / (CGFloat(keeper.ratings.goalkeeping) * 0.5)

        UIView.animate(withDuration: keeperDuration) {
            self.keeperView.center = CGPoint(x: keeperTargetX,
                                             y: self.keeperView.center.y)
        }
    }

    func animateOtherAttackers(attackers: [HighlightPlayerView.Model]) {
        for i in 0..<attackers.count {
            let attacker = attackers[i]
            let attackerView = otherAttackerViews[i]
            let movement = zones.randomOtherAttackerMovement()
            let duration = movement.magnitude / (CGFloat(attacker.ratings.speed) * zones.attackerSpeedFactor)

            UIView.animate(withDuration: duration, delay: 0) {
                attackerView.center = CGPoint(x: attackerView.center.x + movement.x,
                                              y: attackerView.center.y + movement.y)
            }
        }
    }

    func animateDefenders(defenders: [HighlightPlayerView.Model]) {

        let defenderPositions = zones.randomDefenderPositions(numDefenders: defenders.count)

        for i in 0..<defenders.count {
            let defender = defenders[i]
            let defenderView = defenderViews[i]
            let position = defenderPositions[i]
            let movement = CGPoint(x: defenderView.center.x - position.x,
                                   y: defenderView.center.y - position.y)
            let duration = movement.magnitude / (CGFloat(defender.ratings.speed) * zones.defenderSpeedFactor)

            UIView.animate(withDuration: duration, delay: 0) {
                defenderView.center = CGPoint(x: position.x,
                                              y: position.y)
            }
        }
    }

    func animatePass(shooter: HighlightPlayerView.Model,
                     passer: HighlightPlayerView.Model,
                     keeper: HighlightPlayerView.Model,
                     result: Model.HighlightResult) {

        let passOffset = CGPoint(x: ballImageView.center.x - shooterView.center.x,
                                 y: ballImageView.center.x - shooterView.center.y)
        let passDuration = passOffset.magnitude / (CGFloat(passer.ratings.passing) * zones.passSpeedFactor)

        UIView.animate(withDuration: passDuration, delay: 0, options: .curveEaseOut) {
            self.ballImageView.center = CGPoint(x: self.shooterView.center.x,
                                                y: self.shooterView.frame.origin.y)

        } completion: { _ in
            self.animatePostPass(shooter: shooter, passer: passer, result: result)
        }

        animateKeeper(keeper: keeper, ballPosition: ballImageView.center)
    }

    func animatePostPass(shooter: HighlightPlayerView.Model,
                         passer: HighlightPlayerView.Model,
                         result: Model.HighlightResult) {
        let shooterMovement = self.zones.randomAttackerMovementAfterPass()
        let shooterDuration = shooterMovement.magnitude / (CGFloat(shooter.ratings.speed) * zones.attackerSpeedFactor)

        UIView.animate(withDuration: shooterDuration, delay: 0, options: .curveEaseIn) {
            self.shooterView.center = CGPoint(x: self.shooterView.center.x + shooterMovement.x,
                                              y: self.shooterView.center.y + shooterMovement.y)
            self.ballImageView.center = CGPoint(x: self.shooterView.center.x,
                                                y: self.shooterView.frame.origin.y)

        } completion: { _ in
            self.animateShot(shooter: shooter, result: result)
        }
    }

    func animateShot(shooter: HighlightPlayerView.Model, result: Model.HighlightResult) {
        var ballPosition: CGPoint
        switch result {
        case .goal:
            ballPosition = zones.randomBackOfGoal(fromShotOrigin: ballImageView.center)
        case .miss:
            ballPosition = zones.randomMissBallPosition(fromShotOrigin: ballImageView.center)
        case .save:
            if let currentKeeperFrame = keeperView.layer.presentation()?.frame {
                keeperView.frame = currentKeeperFrame
            }
            keeperView.layer.removeAllAnimations()
            ballPosition = zones.randomSavePosition()
        }

        let shotOffset = CGPoint(x: ballImageView.center.x - ballPosition.x,
                                 y: ballImageView.center.x - ballPosition.y)
        let shotDuration = shotOffset.magnitude / (CGFloat(shooter.ratings.shooting) * zones.shotSpeedFactor)

        UIView.animate(withDuration: shotDuration, delay: 0, options: [.curveLinear, .beginFromCurrentState]) { // .curveEaseOut) {
            self.ballImageView.center = CGPoint(x: ballPosition.x,
                                                y: ballPosition.y + self.zones.ballSize / 2.0)
            if result == .save {
                self.keeperView.center = CGPoint(x: ballPosition.x,
                                                 y: ballPosition.y - self.zones.playerSize.height)
            }
        } completion: { _ in
            self.animatePostShot(result: result)
        }
    }

    func animatePostShot(result: Model.HighlightResult) {
        switch result {
        case .goal:
            self.animateInGoalCelebration()
        case .miss:
            self.goToNextHighlight(afterDelay: 1.0)
        case .save:
            if Int.random(in: 0..<100) < 33 {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                    self.ballImageView.center = CGPoint(
                        x: self.ballImageView.center.x + CGFloat.random(in: -40...40),
                        y: self.ballImageView.center.y + CGFloat.random(in: 10...80)
                    )
                } completion: { _ in
                    self.goToNextHighlight(afterDelay: 1.0)
                }
            } else {
                self.goToNextHighlight(afterDelay: 1.0)
            }
        }
    }

    func animateInGoalCelebration() {
        goalTextImageView.transform = .init(scaleX: 0, y: 0)
        goalTextImageView.isHidden = false
        UIView.animate(withDuration: 1.25,
                       delay: 0.2,
                       usingSpringWithDamping: 0.35,
                       initialSpringVelocity: 0.0,
                       options: []) {
            self.goalTextImageView.transform = .identity
        } completion: { _ in
            self.animatePlayerProfile()
        }
    }

    func animatePlayerProfile() {
        goalPlayerView.alpha = 0
        goalPlayerView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.goalPlayerView.alpha = 1
        } completion: { _ in
            self.animateOutGoalCelebration()
        }
    }

    func animateOutGoalCelebration() {
        UIView.animate(withDuration: 1.0, delay: 1.5) {
            self.goalTextImageView.alpha = 0
            self.goalPlayerView.alpha = 0
        } completion: { _ in
            self.goalTextImageView.isHidden = true
            self.goalTextImageView.alpha = 1
            self.goalPlayerView.isHidden = true
            self.goalPlayerView.alpha = 1

            self.goToNextHighlight(afterDelay: 0.3)
        }
    }

    func goToNextHighlight(afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.highlightIndex += 1
            if self.setupHighlight(index: self.highlightIndex) {
                self.playHighlight(index: self.highlightIndex)
            }
        }
    }
}

extension GameHighlightsViewController {
    struct Model {

        var highlightModels: [HighlightModel] = []
        var numFirstHalfHighlights: Int = 0

        struct HighlightModel {
            var type: HighlightType = .regular
            var result: HighlightResult = .goal
            var hudModel: HighlightHUDView.Model = .init()
            var keeperModel: HighlightPlayerView.Model = .init()
            var shooterModel: HighlightPlayerView.Model = .init()
            var passerModel: HighlightPlayerView.Model?
            var otherAttackerModels: [HighlightPlayerView.Model] = []
            var defenderModels: [HighlightPlayerView.Model] = []
            var scorerProfileModel: PlayerHighlightProfileView.Model?
        }

        enum HighlightType {
            case regular
            case penalty
        }

        enum HighlightResult {
            case goal
            case miss
            case save
        }
    }

    private func applyModel() {

    }
}

