/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller responsible for the game flow.
     The game flow consists of the following tasks:
     - player detection
     - trajectory detection
     - player action classification
     - release angle, release speed and score computation
*/

import UIKit
import AVFoundation
import Vision
var ThrowAngle = 0.0
var HumanHight = 172.0
var ThrowNumber = 0
var avgHeightArrayValueGameManager = 0.0
var poseObservations2 = [VNTrajectoryObservation]()
var results: [VNTrajectoryObservation]?
var FirstPoint = CGPoint(x: 0 , y: 0)
var SecondPoint = CGPoint(x: 0, y: 0)
var ArraySize: Int = 100
var ThrowAngleArray: [Double] = [Double](repeating: 0.0, count: ArraySize)
var HeightArray: [Double] = [Double](repeating: 0.0, count: ArraySize)
var TrajectorySpeedArray: [Double] = [Double](repeating: 0.0, count: ArraySize)
// NEUE VARIABLEN
var KnieWinkel: CGFloat = 0.0
var KnieFlexion: CGFloat = 0.0
var ArrKniewinkel = [CGFloat]()
var stringArray = [String]()
var string: String = ""

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

let Balken = (screenHeight - (screenWidth / (16 / 9))) / 2

class DrawRectangle: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else {
            print("could not get graphics context")
            return
        }

        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(2)
        context.stroke(rect.insetBy(dx: 10, dy: 10))
    }
}


class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var HipNameLabel: UILabel!
    @IBOutlet weak var ShoulderNameLabel: UILabel!
    @IBOutlet weak var KneeNameLabel: UILabel!
    @IBOutlet weak var ElbowNameLabel: UILabel!
    
    @IBOutlet weak var UpperBodyreleaseNameLabel: UILabel!
    @IBOutlet weak var LowerLegreleaseNameLabel: UILabel!
    @IBOutlet weak var UpperArmreleaseNameLabel: UILabel!
    @IBOutlet weak var UpperlegreleaseNameLabel: UILabel!
    @IBOutlet weak var LowerArmreleaseNameLabel: UILabel!
    @IBOutlet var beanBags: [UIImageView]!
    @IBOutlet weak var gameStatusLabel: OverlayLabel!
    @IBOutlet weak var releaseAngle1Label: UILabel!
    @IBOutlet weak var releaseAngle2Label: UILabel!
    @IBOutlet weak var releaseAngle3Label: UILabel!
    @IBOutlet weak var releaseAngle4Label: UILabel!
    @IBOutlet weak var releaseAngle5Label: UILabel!
    @IBOutlet weak var JointAngle1Label: UILabel!
    @IBOutlet weak var JointAngle2Label: UILabel!
    @IBOutlet weak var JointAngle3Label: UILabel!
    @IBOutlet weak var JointAngle4Label: UILabel!
    @IBOutlet weak var metricsStackView: UIStackView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedStackView: UIStackView!
    @IBOutlet weak var throwTypeImage: UIImageView!
    @IBOutlet weak var dashboardView: DashboardView!
    @IBOutlet weak var underhandThrowView: ProgressView!
    @IBOutlet weak var overhandThrowView: ProgressView!
    @IBOutlet weak var underlegThrowView: ProgressView!
    @IBOutlet weak var ThrowAngleLabel: UILabel!
    private let gameManager = GameManager.shared
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    private var playerDetected = false
    private var isBagInTargetRegion = false
    private var throwRegion = CGRect.null
    private var targetRegion = CGRect.null
    private let trajectoryView = TrajectoryView()
    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView = JointSegmentView()
    private var noObservationFrameCount = 0
    private var trajectoryInFlightPoseObservations = 0
    private var showSummaryGesture: UITapGestureRecognizer!
    private let trajectoryQueue = DispatchQueue(label: "com.ActionAndVision.trajectory", qos: .userInteractive)
    private let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    private let trajectoryDetectionMinConfidence: VNConfidence = 0.9
    private let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1
    private lazy var detectTrajectoryRequest: VNDetectTrajectoriesRequest! =
                        VNDetectTrajectoriesRequest(frameAnalysisSpacing: .zero, trajectoryLength:  GameConstants.trajectoryLength)
    func HideLabel() {
        if ShowElbow == false {
            JointAngle1Label.isHidden = true
            ElbowNameLabel.isHidden = true
        }
        else {
            JointAngle1Label.isHidden = false
            ElbowNameLabel.isHidden = false
        }
        if ShowKnee == false {
            JointAngle2Label.isHidden = true
            KneeNameLabel.isHidden = true
        }
        else {
            JointAngle2Label.isHidden = false
            KneeNameLabel.isHidden = false
        }
        if ShowShoulder == false {
            JointAngle3Label.isHidden = true
            ShoulderNameLabel.isHidden = true
        }
        else {
            JointAngle3Label.isHidden = false
            ShoulderNameLabel.isHidden = false
        }
        if ShowHip == false {
            JointAngle4Label.isHidden = true
            HipNameLabel.isHidden = true
        }
        else {
            JointAngle4Label.isHidden = false
            HipNameLabel.isHidden = false
        }
        if OtherAngles == false {
            releaseAngle1Label.isHidden = true
            releaseAngle2Label.isHidden = true
            releaseAngle3Label.isHidden = true
            releaseAngle4Label.isHidden = true
            releaseAngle5Label.isHidden = true
            UpperBodyreleaseNameLabel.isHidden = true
            LowerLegreleaseNameLabel.isHidden = true
            UpperArmreleaseNameLabel.isHidden = true
            UpperlegreleaseNameLabel.isHidden = true
            LowerArmreleaseNameLabel.isHidden = true
        }
        else {
            releaseAngle1Label.isHidden = false
            releaseAngle2Label.isHidden = false
            releaseAngle3Label.isHidden = false
            releaseAngle4Label.isHidden = false
            releaseAngle5Label.isHidden = false
            UpperBodyreleaseNameLabel.isHidden = false
            LowerLegreleaseNameLabel.isHidden = false
            UpperArmreleaseNameLabel.isHidden = false
            UpperlegreleaseNameLabel.isHidden = false
            LowerArmreleaseNameLabel.isHidden = false
        }
        
    }
    //Variables - KPIs
    var lastThrowMetrics: ThrowMetrics {
        get {
            return gameManager.lastThrowMetrics
        }
        set {
            gameManager.lastThrowMetrics = newValue
        }
    }
    

    var playerStats: PlayerStats {
        get {
            return gameManager.playerStats
        }
        set {
            gameManager.playerStats = newValue
        }
    }
//MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
        showSummaryGesture = UITapGestureRecognizer(target: self, action: #selector(handleShowSummaryGesture(_:)))
        showSummaryGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(showSummaryGesture)
        HideLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameStatusLabel.perform(transition: .fadeIn, duration: 0.25)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        detectTrajectoryRequest = nil
    }

    func getScoreLabelAttributedStringForScore(_ score: Int) -> NSAttributedString {
        let totalScore = NSMutableAttributedString(string: "Gesamtpunktzahl ", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65)])
        totalScore.append(NSAttributedString(string: "\(score)", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]))
        totalScore.append(NSAttributedString(string: "/40", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65)]))
        return totalScore
    }

    func setUIElements() {
        resetKPILabels()
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        playerBoundingBox.isHidden = true
        view.addSubview(playerBoundingBox)
        view.addSubview(jointSegmentView)
        view.addSubview(trajectoryView)
        gameStatusLabel.text = "Wartet auf Spieler"
        // Set throw type counters
        underhandThrowView.throwType = .underhand
        overhandThrowView.throwType = .overhand
        underlegThrowView.throwType = .underleg
    }

    func resetKPILabels() {
        // Reset Speed and throwType image
        dashboardView.speed = 0
        throwTypeImage.image = nil
        // Hode KPI labels
        dashboardView.isHidden = true
        speedStackView.isHidden = true
        metricsStackView.isHidden = true
    }
    

    func updateKPILabels() {
        // Show KPI labels
        dashboardView.isHidden = false
        speedStackView.isHidden = false
        metricsStackView.isHidden = false
        // Update text for KPI labels
        speedLabel.text = "\(lastThrowMetrics.releaseSpeed)"
        releaseAngle1Label.text = "\(lastThrowMetrics.releaseAngle1)°"
        releaseAngle2Label.text = "\(lastThrowMetrics.releaseAngle2)°"
        releaseAngle3Label.text = "\(lastThrowMetrics.releaseAngle3)°"
        releaseAngle4Label.text = "\(lastThrowMetrics.releaseAngle4)°"
        releaseAngle5Label.text = "\(lastThrowMetrics.releaseAngle5)°"
        JointAngle1Label.text = "\(lastThrowMetrics.JointAngle1)°"
        JointAngle2Label.text = "\(lastThrowMetrics.JointAngle2)°"
        JointAngle3Label.text = "\(lastThrowMetrics.JointAngle3)°"
        JointAngle4Label.text = "\(lastThrowMetrics.JointAngle4)°"
        // Update throw type counters
        throwTypeImage.image = UIImage(named: lastThrowMetrics.throwType.rawValue)
        switch lastThrowMetrics.throwType {
        case .overhand:
            overhandThrowView.incrementThrowCount()
        case .underhand:
            underhandThrowView.incrementThrowCount()
        case .underleg:
            underlegThrowView.incrementThrowCount()
        default:
            break
        }
        // Update score labels
    }

    func updateBoundingBox(_ boundingBox: BoundingBoxView, withRect rect: CGRect?) -> (Double,Double) {
        // Update the frame for player bounding box
        boundingBox.frame = rect ?? .zero
        boundingBox.perform(transition: (rect == nil ? .fadeOut : .fadeIn), duration: 0.1)
        
        // TEST PRINT
        //print("Test123")
        
        return (boundingBox.frame.width, boundingBox.frame.height)
    }
    


    func humanBoundingBox(for observation: VNHumanBodyPoseObservation) -> CGRect {
        var box = CGRect.zero
        var normalizedBoundingBox = CGRect.null
        // Process body points only if the confidence is high.
        guard observation.confidence > bodyPoseDetectionMinConfidence, let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return box
        }
        // Only use point if human pose joint was detected reliably.
        for (_, point) in points where point.confidence > bodyPoseRecognizedPointMinConfidence {
            normalizedBoundingBox = normalizedBoundingBox.union(CGRect(origin: point.location, size: .zero))
        }
        if !normalizedBoundingBox.isNull {
            box = normalizedBoundingBox
        }
        // Fetch body joints from the observation and overlay them on the player.
        let joints = getBodyJointsFor(observation: observation)
        DispatchQueue.main.async {
            self.jointSegmentView.joints = joints
            
            // TEST PRINT
            //print("TestTest")
            //self.playerStats.storeObservation(observation)
            //var KnieWinkel: Double
            //KnieWinkel = 10

                let (rightHip, rightKnee, rightAnkle) = KneeJoints(for: observation)
                let xDistA = (rightKnee.x - rightAnkle.x)
                let yDistA = (rightKnee.y - rightAnkle.y)
                let a = sqrt((xDistA * xDistA) + (yDistA * yDistA))

                let xDistB = (rightHip.x - rightAnkle.x)
                let yDistB = (rightHip.y - rightAnkle.y)
                let b = sqrt((xDistB * xDistB) + (yDistB * yDistB))

                let xDistC = (rightKnee.x - rightHip.x)
                let yDistC = (rightKnee.y - rightHip.y)
                let c = sqrt((xDistC * xDistC) + (yDistC * yDistC))

            //KnieWinkel = (((acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c)))))*(180))/(3.14159))
            KnieWinkel = acos(((a*a)+(c*c)-(b*b))/(2*a*c))
            KnieWinkel=KnieWinkel * 180/3.14159
            //KnieWinkel = KnieWinkel*100
            KnieWinkel = round(KnieWinkel)
            //KnieWinkel = KnieWinkel/100
            
            KnieFlexion = 180 - KnieWinkel
            
            // Test 4
            print("Test Kniewinkel: ", KnieWinkel)
            print("Test KnieFlexion: ", KnieFlexion)

            
            ArrKniewinkel.append(KnieWinkel)
            print("Count: ", ArrKniewinkel.count)
            
            let frames = 633
            
            if (ArrKniewinkel.count == frames){
            print("Test Array: ", ArrKniewinkel)
                
                for i in 1...frames-1 {
                    //let str = ArrKniewinkel.description[i]
                    let string = String(format: "%.2f", ArrKniewinkel[i])
                    stringArray.append(string)
                }
             
                /*
                print("Test StringArray: ", stringArray)
                
                
                let myArray: [CGFloat] = ArrKniewinkel
                     let arrayKey = "arrayKey"
                     let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL // Save in Documents
                     let myURL = url.appendingPathComponent("export")
                
                let data = NSMutableData()
               let archiver = NSKeyedArchiver(forWritingWith: data)
               archiver.encode(myArray, forKey: arrayKey)
               archiver.finishEncoding()
               data.write(to: myURL, atomically: true)
                */
                
                
                
                
            /*
            //Test Export

                let str = stringArray.joined(separator: ", ")
                
                
                let filename = getDocumentsDirectory().appendingPathComponent("output.txt")



                do {
                    try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
/*
                func getDocumentsDirectory() -> URL {
                    let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
                    return paths[0]
                }
                */
                func getDocumentsDirectory() -> URL {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentsDirectory = paths[0]
                    return documentsDirectory
                }
                 */
                
            }
            

            
            //print("Count: ", ArrKniewinkel.count)
            /*
            let (rightKnee, rightHip) = upperlegJoints(for: observation)
            print("Test: ", rightKnee.angleFromHorizontal(to: rightHip))
            //print("Test: ", joints.rightKnee)
             */
        }
        // Store the body pose observation in playerStats when the game is in TrackThrowsState.
        // We will use these observations for action classification once the throw is complete.
        if gameManager.stateMachine.currentState is GameManager.TrackThrowsState {
            playerStats.storeObservation(observation)
            if trajectoryView.inFlight {
                trajectoryInFlightPoseObservations += 1
            }
           
        }
        return box
    }

    // Define regions to filter relavant trajectories for the game
    // throwRegion: Region to the right of the player to detect start of throw
    // targetRegion: Region around the board to determine end of throw
    func resetTrajectoryRegions() {
        let boardRegion = gameManager.boardRegion
        let playerRegion = playerBoundingBox.frame
        let throwWindowXBuffer: CGFloat = 50
        let throwWindowYBuffer: CGFloat = 50
        let targetWindowXBuffer: CGFloat = 50
        let throwRegionWidth: CGFloat = 400
        throwRegion = CGRect(x: playerRegion.maxX + throwWindowXBuffer, y: 0, width: throwRegionWidth, height: playerRegion.maxY - throwWindowYBuffer)
        targetRegion = CGRect(x: boardRegion.minX - targetWindowXBuffer, y: 0,
                              width: boardRegion.width + 2 * targetWindowXBuffer, height: boardRegion.maxY)

    }

    // Adjust the throwRegion based on location of the bag.
    // Move the throwRegion to the right until we reach the target region.
    func updateTrajectoryRegions() {
        let trajectoryLocation = trajectoryView.fullTrajectory.currentPoint
        let didBagCrossCenterOfThrowRegion = trajectoryLocation.x > throwRegion.origin.x + throwRegion.width / 2
        guard !(throwRegion.contains(trajectoryLocation) && didBagCrossCenterOfThrowRegion) else {
            return
        }
        // Overlap buffer window between throwRegion and targetRegion
        let overlapWindowBuffer: CGFloat = 50
        if targetRegion.contains(trajectoryLocation) {
            // When bag is in target region, set the throwRegion to targetRegion.
            throwRegion = targetRegion
        } else if trajectoryLocation.x + throwRegion.width / 2 - overlapWindowBuffer < targetRegion.origin.x {
            // Move the throwRegion forward to have the bag at the center.
            throwRegion.origin.x = trajectoryLocation.x - throwRegion.width / 2
        }
        trajectoryView.roi = throwRegion
        
    }
    
    func processTrajectoryObservations(_ controller: CameraViewController, _ results: [VNTrajectoryObservation]) {
        if self.trajectoryView.inFlight && results.count < 1 {
            // The trajectory is already in flight but VNDetectTrajectoriesRequest doesn't return any trajectory observations.
            self.noObservationFrameCount += 1
            if self.noObservationFrameCount > GameConstants.noObservationFrameLimit {
                // Ending the throw as we don't see any observations in consecutive GameConstants.noObservationFrameLimit frames.
                self.updatePlayerStats(controller)
            }
        } else {
            for path in results where path.confidence > trajectoryDetectionMinConfidence {
                // VNDetectTrajectoriesRequest has returned some trajectory observations.
                // Process the path only when the confidence is over 90%.
                self.trajectoryView.duration = path.timeRange.duration.seconds
                self.trajectoryView.points = path.detectedPoints
                self.trajectoryView.perform(transition: .fadeIn, duration: 0.25)
                if !self.trajectoryView.fullTrajectory.isEmpty {
                    // Hide the previous throw metrics once a new throw is detected.
                    if !self.dashboardView.isHidden {
                        self.resetKPILabels()
                    }
                    self.updateTrajectoryRegions()
                    if self.trajectoryView.isThrowComplete {
                        // Update the player statistics once the throw is complete.
                        self.updatePlayerStats(controller)
                    }
                }
                self.noObservationFrameCount = 0
            }
        }
        
    }

//MARK: Draw Trajectory
    func updatePlayerStats(_ controller: CameraViewController) {
        let finalBagLocation = trajectoryView.finalBagLocation
        playerStats.storePath(self.trajectoryView.fullTrajectory.cgPath)
        trajectoryView.resetPath()
        let stats = gameManager.playerStats
        let paths = stats.throwPaths
        let frame = view.bounds
        for path in paths {
            let trajectoryView = TrajectoryView(frame: frame)
            trajectoryView.translatesAutoresizingMaskIntoConstraints = false
                // Add each trajectoryView as subview to current view.
            view.addSubview(trajectoryView)
            // Add contraints to make sure trajectoryView is within the safe area.
            NSLayoutConstraint.activate([
                trajectoryView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
                trajectoryView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
                trajectoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                trajectoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ])
            ThrowNumber = playerStats.throwCount
            
            trajectoryView.addPath(path)
        }
        lastThrowMetrics.updateThrowType(playerStats.getLastThrowType())
        // Compute the speed in mph
        // trajectoryView.speed is in points/second, convert that to meters/second by multiplying the pointToMeterMultiplier.
        // 1 meters/second = 3.6 kilometers/hour
        let releaseSpeed = round(trajectoryView.speed * gameManager.pointToMeterMultiplier * 3.6 * 100) / 100
        let releaseAngle1 = round(playerStats.getReleaseAngle1() * 100) / 100
        let releaseAngle2 = round(playerStats.getReleaseAngle2() * 100) / 100
        let releaseAngle3 = round(playerStats.getReleaseAngle3() * 100) / 100
        let releaseAngle4 = round(playerStats.getReleaseAngle4() * 100) / 100
        let releaseAngle5 = round(playerStats.getReleaseAngle5() * 100) / 100
        let JointAngle1 = round(playerStats.getJointAngle1() * 100) / 100
        let JointAngle2 = round(playerStats.getJointAngle2() * 100) / 100
        let JointAngle3 = round(playerStats.getJointAngle3() * 100) / 100
        let JointAngle4 = round(playerStats.getJointAngle4() * 100) / 100
        let distanceWholeBody = playerStats.getDistanceNoseAnkle()
        lastThrowMetrics.updateMetrics(speed: releaseSpeed, angle1: releaseAngle1, angle2: releaseAngle2, angle3: releaseAngle3, angle4: releaseAngle4, angle5: releaseAngle5, angle6: JointAngle1, angle7: JointAngle2, angle8: JointAngle3, angle9: JointAngle4, newDistance: distanceWholeBody)
        self.gameManager.stateMachine.enter(GameManager.ThrowCompletedState.self)
        let i = ThrowNumber
        HeightArray[i] = Double(distanceWholeBody)
        TrajectorySpeedArray[i] = Double(trajectoryView.speed)
        let sumArray = HeightArray.reduce(0, +)
        avgHeightArrayValueGameManager = sumArray / (Double(ThrowNumber + 1))
        print("distanceWholeBody: ", distanceWholeBody)
        print("avgHeight: ", avgHeightArrayValueGameManager)
        //Zum Testen
        print("Test: ", JointAngle1)

        self.gameManager.pointToMeterMultiplier = ((HumanHight - 23) / 100.0) / avgHeightArrayValueGameManager
    }
    
//MARK: Throw Angle
    func getThrowAngle() -> Double{
        playerStats.storePath(self.trajectoryView.fullTrajectory.cgPath)
        trajectoryView.resetPath()
        let stats = gameManager.playerStats
        let paths = stats.throwPaths
        let frame = view.bounds
        for path in paths {
            let trajectoryView = TrajectoryView(frame: frame)
            trajectoryView.translatesAutoresizingMaskIntoConstraints = false
                // Add each trajectoryView as subview to current view.
            view.addSubview(trajectoryView)
            // Add contraints to make sure trajectoryView is within the safe area.
            NSLayoutConstraint.activate([
                trajectoryView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
                trajectoryView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
                trajectoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                trajectoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ])
            let Points = path.getPathElementsPoints()
            if Points.indices.contains(0){
                FirstPoint = Points[0]
            }
            if Points.indices.contains(1){
            SecondPoint = Points[1]
            }
            ThrowAngle = FirstPoint.angleFromHorizontal(to: SecondPoint)
            }
//        let Balken = (screenHeight - (screenWidth / (16 / 9))) / 2
        if ShowRectangle == true {
        let myView1 = DrawRectangle(frame: CGRect(x: FirstPoint.x, y: FirstPoint.y + Balken, width: 30, height: 30))
                myView1.alpha = 0.5
                self.view.addSubview(myView1)
        let myView2 = DrawRectangle(frame: CGRect(x: SecondPoint.x, y: SecondPoint.y + Balken, width: 30, height: 30))
                myView2.alpha = 0.5
                self.view.addSubview(myView2)
        }
        return(ThrowAngle)
        }

    
    func computeScore(_ finalBagLocation: CGPoint) -> Scoring {
        let heightBuffer: CGFloat = 100
        let boardRegion = gameManager.boardRegion
        // In some cases trajectory observation may not end exactly on the board and end a few pixels above the board.
        // This can happen especially when the bag bounces on the board. Filtering conditions can be adjusted to get those observations as well.
        // Defining extended regions for board and the hole with a heightBuffer to cover these cases.
        let extendedBoardRegion = CGRect(x: boardRegion.origin.x, y: boardRegion.origin.y - heightBuffer,
                                        width: boardRegion.width, height: boardRegion.height + heightBuffer)
        let holeRegion = gameManager.holeRegion
        let extendedHoleRegion = CGRect(x: holeRegion.origin.x, y: holeRegion.origin.y - heightBuffer,
                                        width: holeRegion.width, height: holeRegion.height + heightBuffer)
        if !extendedBoardRegion.contains(finalBagLocation) {
            // Bag missed the board
            return Scoring.zero
        } else if extendedHoleRegion.contains(finalBagLocation) {
            // Bag landed in the hole
            return lastThrowMetrics.throwType == .underleg ? Scoring.fifteen : Scoring.three
        } else {
            // Bag landed on the board
            return lastThrowMetrics.throwType == .underleg ? Scoring.five : Scoring.one
        }
    }
}

extension GameViewController: GameStateChangeObserver {
    func gameManagerDidEnter(state: GameManager.State, from previousState: GameManager.State?) {
        switch state {
        case is GameManager.DetectedPlayerState:
            playerDetected = true
            playerStats.reset()
            playerBoundingBox.perform(transition: .fadeOut, duration: 1.0)
            gameStatusLabel.text = "Start"
            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
                self.gameManager.stateMachine.enter(GameManager.TrackThrowsState.self)
            }
        case is GameManager.TrackThrowsState:
            resetTrajectoryRegions()
            trajectoryView.roi = throwRegion
        case is GameManager.ThrowCompletedState:
            dashboardView.speed = lastThrowMetrics.releaseSpeed
            dashboardView.animateSpeedChart()
            getThrowAngle()
            let i = ThrowNumber
            ThrowAngleArray[i] = Double(ThrowAngle)
            ThrowAngleLabel.text = "\(ThrowAngle)°"
            playerStats.adjustMetrics(speed: lastThrowMetrics.releaseSpeed,
                                      releaseAngle1: lastThrowMetrics.releaseAngle1, throwType: lastThrowMetrics.throwType, releaseAngle2: lastThrowMetrics.releaseAngle2, releaseAngle3: lastThrowMetrics.releaseAngle3, releaseAngle4: lastThrowMetrics.releaseAngle4, releaseAngle5: lastThrowMetrics.releaseAngle5, JointAngle1: lastThrowMetrics.JointAngle1, JointAngle2: lastThrowMetrics.JointAngle2, JointAngle3: lastThrowMetrics.JointAngle3, JointAngle4: lastThrowMetrics.JointAngle4, distanceWholeBody: lastThrowMetrics.distanceWholeBody, ThrowAngle: lastThrowMetrics.ThrowAngle)
            playerStats.resetObservations()
            trajectoryInFlightPoseObservations = 0
            self.updateKPILabels()
            
            
            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
                if self.playerStats.throwCount == GameConstants.maxThrows {
                    self.gameManager.stateMachine.enter(GameManager.ShowSummaryState.self)
                } else {
                    self.gameManager.stateMachine.enter(GameManager.TrackThrowsState.self)
                }
            }
        default:
            break
        }
    }
}


extension GameViewController: CameraViewControllerOutputDelegate {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: orientation, options: [:])
        if gameManager.stateMachine.currentState is GameManager.TrackThrowsState {
            DispatchQueue.main.async {
                // Get the frame of rendered view
                let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
                self.jointSegmentView.frame = controller.viewRectForVisionRect(normalizedFrame)
                self.trajectoryView.frame = controller.viewRectForVisionRect(normalizedFrame)
            }
            // Perform the trajectory request in a separate dispatch queue.
            
            
            //Eigentlich nicht auskommentiert
            /*
            trajectoryQueue.async {
                do {
                    try visionHandler.perform([self.detectTrajectoryRequest])
                    if let results = self.detectTrajectoryRequest.results {
                        DispatchQueue.main.async {
                            self.processTrajectoryObservations(controller, results)
                        }
                    }
                } catch {
                    AppError.display(error, inViewController: self)
                }
            }
             // Bis hierher
            */
        }
        // Body pose request is performed on the same camera queue to ensure the highlighted joints are aligned with the player.
        // Run bodypose request for additional GameConstants.maxPostReleasePoseObservations frames after the first trajectory observation is detected.
       
        
        //Erstellt jeden Frame eine Box
        if !(self.trajectoryView.inFlight && self.trajectoryInFlightPoseObservations >= GameConstants.maxTrajectoryInFlightPoseObservations) {
            do {
                try visionHandler.perform([detectPlayerRequest])
                if let result = detectPlayerRequest.results?.first {
                    let box = humanBoundingBox(for: result)
                    let boxView = playerBoundingBox
                    DispatchQueue.main.async {
                        let inset: CGFloat = -20.0
                        let viewRect = controller.viewRectForVisionRect(box).insetBy(dx: inset, dy: inset)
                        self.updateBoundingBox(boxView, withRect: viewRect)
                        if !self.playerDetected && !boxView.isHidden {
                            self.gameStatusLabel.alpha = 0
                            self.resetTrajectoryRegions()
                            self.gameManager.stateMachine.enter(GameManager.DetectedPlayerState.self)
                        }
                    }
                    // Hier versuchen Kniewinkel abzufangen
                    // playerStats.adjustMetrics(JointAngle1: lastThrowMetrics.JointAngle1)
                }
            } catch {
                AppError.display(error, inViewController: self)
            }
        } else {
            // Hide player bounding box
            DispatchQueue.main.async {
                if !self.playerBoundingBox.isHidden {
                    self.playerBoundingBox.isHidden = true
                    self.jointSegmentView.resetView()
                }
            }
        }
    }
}

extension GameViewController {
    @objc
    func handleShowSummaryGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.gameManager.stateMachine.enter(GameManager.ShowSummaryState.self)
        }
    }
}

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}
