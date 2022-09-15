/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is a collection of common data types, constants and helper functions used in the app.
*/

import UIKit
import Vision




enum ThrowType: String, CaseIterable {
    case overhand = "Überhalb der Schulter"
    case underleg = "Unter dem Bein"
    case underhand = "Unterhalb der Schulter"
    case none = "keine Wurfart"
}

enum Scoring: Int {
    case zero = 0
    case one = 1
    case three = 3
    case five = 5
    case fifteen = 15
}
struct ThrowMetrics {
    var ThrowAngle = 0.0
    var releaseSpeed = 0.0
    var releaseAngle1 = 0.0
    var JointAngle1 = 0.0
    var JointAngle2 = 0.0
    var JointAngle3 = 0.0
    var JointAngle4 = 0.0
    var releaseAngle2 = 0.0
    var releaseAngle3 = 0.0
    var releaseAngle4 = 0.0
    var releaseAngle5 = 0.0
    var distanceWholeBody = 0.00000
    var throwType = ThrowType.none
    var finalBagLocation: CGPoint = .zero

    mutating func updateThrowType(_ type: ThrowType) {
        throwType = type
    }

    mutating func updateFinalBagLocation(_ location: CGPoint) {
        finalBagLocation = location
    }

    mutating func updateMetrics(speed: Double, angle1: Double, angle2: Double, angle3: Double, angle4: Double, angle5: Double, angle6: Double, angle7: Double, angle8: Double, angle9: Double, newDistance: Double) {
        releaseSpeed = speed
        releaseAngle1 = angle1
        releaseAngle2 = angle2
        releaseAngle3 = angle3
        releaseAngle4 = angle4
        releaseAngle5 = angle5
        JointAngle1 = angle6
        JointAngle2 = angle7
        JointAngle3 = angle8
        JointAngle4 = angle9
        distanceWholeBody = newDistance
        //Test 2
        print("Test 2: ", JointAngle1)
        
    }
}

struct PlayerStats {
    var throwCount = 0
    var topSpeed = 0.0
    var avgSpeed = 0.0
    var releaseAngle1 = 0.0
    var JointAngle1 = 0.0
    var JointAngle2 = 0.0
    var JointAngle3 = 0.0
    var JointAngle4 = 0.0
    var releaseAngle2 = 0.0
    var releaseAngle3 = 0.0
    var releaseAngle4 = 0.0
    var releaseAngle5 = 0.0
    var avgJointAngle1 = 0.0
    var avgJointAngle2 = 0.0
    var avgJointAngle3 = 0.0
    var avgJointAngle4 = 0.0
    var avgThrowAngle = 0.0
    var avgReleaseAngle1 = 0.0
    var avgReleaseAngle2 = 0.0
    var avgReleaseAngle3 = 0.0
    var avgReleaseAngle4 = 0.0
    var avgReleaseAngle5 = 0.0
    var distanceWholeBody = 0.000000
    
    var poseObservations = [VNHumanBodyPoseObservation]()
    var throwPaths = [CGPath]()
    
    mutating func reset() {
        topSpeed = 0
        avgSpeed = 0
        throwCount = 0
        JointAngle1 = 0
        JointAngle2 = 0
        JointAngle3 = 0
        JointAngle4 = 0
        distanceWholeBody = 0
        releaseAngle1 = 0
        releaseAngle2 = 0
        releaseAngle3 = 0
        releaseAngle4 = 0
        releaseAngle5 = 0
        poseObservations = []
    }

    mutating func resetObservations() {
        poseObservations = []
    }

    mutating func adjustMetrics(speed: Double, releaseAngle1: Double, throwType: ThrowType, releaseAngle2: Double, releaseAngle3: Double, releaseAngle4: Double, releaseAngle5:Double, JointAngle1: Double, JointAngle2: Double, JointAngle3: Double, JointAngle4: Double, distanceWholeBody: Double, ThrowAngle: Double ) {
        throwCount += 1
        avgSpeed = (avgSpeed * Double(throwCount - 1) + speed) / Double(throwCount)
        avgThrowAngle = (avgThrowAngle * Double(throwCount - 1) + ThrowAngle) / Double(throwCount)
        avgReleaseAngle1 = (avgReleaseAngle1 * Double(throwCount - 1) + releaseAngle1) / Double(throwCount)
        avgJointAngle1 = (avgJointAngle1 * Double(throwCount - 1) + JointAngle1) / Double(throwCount)
        avgJointAngle2 = (avgJointAngle2 * Double(throwCount - 1) + JointAngle2) / Double(throwCount)
        avgJointAngle3 = (avgJointAngle3 * Double(throwCount - 1) + JointAngle3) / Double(throwCount)
        avgJointAngle4 = (avgJointAngle4 * Double(throwCount - 1) + JointAngle4) / Double(throwCount)
        avgReleaseAngle2 = (avgReleaseAngle2 * Double(throwCount - 1) + releaseAngle2) / Double(throwCount)
        avgReleaseAngle3 = (avgReleaseAngle3 * Double(throwCount - 1) + releaseAngle3) / Double(throwCount)
        avgReleaseAngle4 = (avgReleaseAngle4 * Double(throwCount - 1) + releaseAngle4) / Double(throwCount)
        avgReleaseAngle5 = (avgReleaseAngle5 * Double(throwCount - 1) + releaseAngle5) / Double(throwCount)
        if speed > topSpeed {
            topSpeed = speed
        }
    }

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if poseObservations.count >= GameConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getReleaseAngle1() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightElbow, rightWrist) = upperarmJoints(for: observation)
            // Release angle is computed by measuring the angle forearm (elbow to wrist) makes with the horizontal
            releaseAngle1 = rightElbow.angleFromHorizontal(to: rightWrist)
        }
        return releaseAngle1
    }
    
    mutating func getJointAngle1() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightWrist, rightElbow, rightShoulder) = ElbowJoints(for: observation)
            let xDistA = (rightElbow.x - rightShoulder.x)
            let yDistA = (rightElbow.y - rightShoulder.y)
            let a = sqrt((xDistA * xDistA) + (yDistA * yDistA))

            let xDistB = (rightWrist.x - rightShoulder.x)
            let yDistB = (rightWrist.y - rightShoulder.y)
            let b = sqrt((xDistB * xDistB) + (yDistB * yDistB))

            let xDistC = (rightElbow.x - rightWrist.x)
            let yDistC = (rightElbow.y - rightWrist.y)
            let c = sqrt((xDistC * xDistC) + (yDistC * yDistC))
            
            JointAngle1 = (((acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c)))))*(180))/(3.14159))
        }
        // Test 3
        print("Test 3: ", JointAngle1)
        return JointAngle1
    }
    
    
    mutating func getJointAngle2() -> Double {
        if !poseObservations.isEmpty{
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
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

            JointAngle2 = (((acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c)))))*(180))/(3.14159))
        }
        // Test 4
        print("Test 4: ", JointAngle2)
        return JointAngle2
    }
    
    
    mutating func getJointAngle3() -> Double {
        if !poseObservations.isEmpty{
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightElbow, rightShoulder, rightHip) = ShoulderJoints(for: observation)
            let xDistA = (rightShoulder.x - rightHip.x)
            let yDistA = (rightShoulder.y - rightHip.y)
            let a = sqrt((xDistA * xDistA) + (yDistA * yDistA))

            let xDistB = (rightElbow.x - rightHip.x)
            let yDistB = (rightElbow.y - rightHip.y)
            let b = sqrt((xDistB * xDistB) + (yDistB * yDistB))

            let xDistC = (rightShoulder.x - rightElbow.x)
            let yDistC = (rightShoulder.y - rightElbow.y)
            let c = sqrt((xDistC * xDistC) + (yDistC * yDistC))

            JointAngle3 = (((acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c)))))*(180))/(3.14159))
        }
        // Test 5
        print("Test 5: ", JointAngle3)
        return JointAngle3
    }
    
    mutating func getJointAngle4() -> Double {
        if !poseObservations.isEmpty{
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightShoulder, rightHip, rightKnee) = HipJoints(for: observation)
            let xDistA = (rightHip.x - rightKnee.x)
            let yDistA = (rightHip.y - rightKnee.y)
            let a = sqrt((xDistA * xDistA) + (yDistA * yDistA))

            let xDistB = (rightShoulder.x - rightKnee.x)
            let yDistB = (rightShoulder.y - rightKnee.y)
            let b = sqrt((xDistB * xDistB) + (yDistB * yDistB))

            let xDistC = (rightHip.x - rightShoulder.x)
            let yDistC = (rightHip.y - rightShoulder.y)
            let c = sqrt((xDistC * xDistC) + (yDistC * yDistC))

            JointAngle4 = (((acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c)))))*(180))/(3.14159))
        }
        // Test 6
        print("Test 6: ", JointAngle4)
        return JointAngle4
    }
    
    
    mutating func getDistanceNoseAnkle() -> Double {
        if !poseObservations.isEmpty{
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
        let (rightAnkle, nose) =  fullBodyJoints(for: observation)
            let nose2 = VNImagePointForNormalizedPoint(nose, 1920, 1080)
            let rightAnkle2 = VNImagePointForNormalizedPoint(rightAnkle, 1920, 1080)
        distanceWholeBody = Double(hypot(rightAnkle2.x - nose2.x, rightAnkle2.y - nose2.y))
        }
        return(distanceWholeBody)
        
    }
        
        
    mutating func getReleaseAngle2() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightKnee, rightHip) = upperlegJoints(for: observation)
            releaseAngle2 = rightKnee.angleFromHorizontal(to: rightHip)
        }
        return releaseAngle2
    }

    mutating func getReleaseAngle3() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightElbow, rightShoulder) = lowerarmJoints(for: observation)
            releaseAngle3 = rightElbow.angleFromHorizontal(to: rightShoulder)
        }
        return releaseAngle3
    }
    
    mutating func getReleaseAngle4() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightKnee, rightAnkle) = lowerlegJoints(for: observation)
            releaseAngle4 = rightKnee.angleFromHorizontal(to: rightAnkle)
        }
        return releaseAngle4
    }
    
    mutating func getReleaseAngle5() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightShoulder, rightHip) = upperbodyJoints(for: observation)
            releaseAngle5 = rightShoulder.angleFromHorizontal(to: rightHip)
        }
        return releaseAngle5
    }
    
    mutating func getLastThrowType() -> ThrowType {
        guard let actionClassifier = try? PlayerActionClassifier(configuration: MLModelConfiguration()),
              let poseMultiArray = prepareInputWithObservations(poseObservations),
              let predictions = try? actionClassifier.prediction(poses: poseMultiArray),
              let throwType = ThrowType(rawValue: predictions.label.capitalized) else {
            return .none
        }
        return throwType
    }
}

struct GameConstants {
    static let maxThrows = 100
    static let newGameTimer = 5
    static let boardLength = 1.20
    static let trajectoryLength = 16
    static let maxPoseObservations = 45
    static let noObservationFrameLimit = 20
    static let maxDistanceWithCurrentTrajectory: CGFloat = 250
    static let maxTrajectoryInFlightPoseObservations = 10
}

let jointsOfInterest: [VNHumanBodyPoseObservation.JointName] = [
    .rightWrist,
    .rightElbow,
    .rightShoulder,
    .rightHip,
    .rightKnee,
    .rightAnkle,
    //.nose
]

func fullBodyJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightAnkle = CGPoint(x: 0, y: 0)
    var nose = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightAnkle, nose)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightAnkle:
            rightAnkle = point.location
        case .nose:
            nose = point.location
        default:
            break
        }
    }
     
    return (rightAnkle, nose)
 
}

func upperarmJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightWrist = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightElbow, rightWrist)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightElbow:
            rightElbow = point.location
        case .rightWrist:
            rightWrist = point.location
        default:
            break
        }
    }
     
    return (rightElbow, rightWrist)
}

func KneeJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightHip = CGPoint(x: 0, y: 0)
    var rightKnee = CGPoint(x: 0, y: 0)
    var rightAnkle = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightHip, rightKnee, rightAnkle)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightHip:
            rightHip = point.location
        case .rightKnee:
            rightKnee = point.location
        case . rightAnkle:
            rightAnkle = point.location
        default:
            break
        }
    }
    /*
    // Test Knie
    print("Test Knie: ", rightKnee)
    // Test Hüfte
    print("Test Huefte: ", rightHip)
    // Test Sprunggelenk
    print("Test Sprunggelenk: ", rightAnkle)
     */
    return (rightHip, rightKnee, rightAnkle)
}

func ElbowJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightWrist = CGPoint(x: 0, y: 0)
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightShoulder = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightWrist, rightElbow, rightShoulder)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightWrist:
            rightWrist = point.location
        case .rightElbow:
            rightElbow = point.location
        case . rightShoulder:
            rightShoulder = point.location
        default:
            break
        }
    }
     
    return (rightWrist, rightElbow, rightShoulder)
}

func ShoulderJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightShoulder = CGPoint(x: 0, y: 0)
    var rightHip = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightElbow, rightShoulder, rightHip)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightElbow:
            rightElbow = point.location
        case .rightShoulder:
            rightShoulder = point.location
        case . rightHip:
            rightHip = point.location
        default:
            break
        }
    }
    
    return (rightElbow, rightShoulder, rightHip)
}

func HipJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightShoulder = CGPoint(x: 0, y: 0)
    var rightHip = CGPoint(x: 0, y: 0)
    var rightKnee = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightShoulder, rightHip, rightKnee)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightShoulder:
            rightShoulder = point.location
        case .rightHip:
            rightHip = point.location
        case . rightKnee:
            rightKnee = point.location
        default:
            break
        }
    }
    return (rightShoulder, rightHip, rightKnee)
}

func upperlegJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightKnee = CGPoint(x: 0, y: 0)
    var rightHip = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightKnee, rightHip)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightKnee:
            rightKnee = point.location
        case .rightHip:
            rightHip = point.location
        default:
            break
        }
    }
     
    return (rightKnee, rightHip)
}

func distance2( rightKnee: CGPoint, rightHip: CGPoint, distanceUpperLeg: Double) -> CGFloat {
    let xDist = rightKnee.x - rightHip.x
    let yDist = rightKnee.y - rightHip.y
    let distanceUpperLeg = CGFloat(sqrt(xDist * xDist + yDist * yDist))
    return(distanceUpperLeg)
}


func lowerlegJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightKnee = CGPoint(x: 0, y: 0)
    var rightAnkle = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightAnkle, rightKnee)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightAnkle:
            rightKnee = point.location
        case .rightKnee:
            rightAnkle = point.location
        default:
            break
        }
    }
     
    return (rightKnee, rightAnkle)
}

func lowerarmJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightShoulder = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightElbow, rightShoulder)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightShoulder:
            rightElbow = point.location
        case .rightElbow:
            rightShoulder = point.location
        default:
            break
        }
    }
     
    return(rightElbow, rightShoulder)
}


func upperbodyJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
    var rightShoulder = CGPoint(x: 0, y: 0)
    var rightHip = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightShoulder, rightHip)
    }
    
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightShoulder:
            rightHip = point.location
        case .rightHip:
            rightShoulder = point.location
        default:
            break
        }
    }
     
    return (rightShoulder, rightHip)
}

func getBodyJointsFor(observation: VNHumanBodyPoseObservation) -> ([VNHumanBodyPoseObservation.JointName: CGPoint]) {
    var joints = [VNHumanBodyPoseObservation.JointName: CGPoint]()
    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return joints
    }
    
    // Verbindet die Punkte miteinander, auch wenn nicht direkt berechnet
    //Erkennt also alle Punkte am Körper
    for (key, point) in identifiedPoints {
        guard point.confidence > 0.1 else { continue }
        if jointsOfInterest.contains(key) {
            joints[key] = point.location
        }
    }
     
    return joints
}

// MARK: - Pipeline warmup

func warmUpVisionPipeline() {
    // In order to preload the models and all associated resources
    // we perform all Vision requests used in the app on a small image (we use one of the assets bundled with our app).
    // This allows to avoid any model loading/compilation costs later when we run these requests on real time video input.
    guard let image = #imageLiteral(resourceName: "Score1").cgImage,
          let detectorModel = try? GameBoardDetector(configuration: MLModelConfiguration()).model,
          let boardDetectionRequest = try? VNCoreMLRequest(model: VNCoreMLModel(for: detectorModel)) else {
        return
    }
    let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try? handler.perform([bodyPoseRequest, boardDetectionRequest])
}

// MARK: - Activity Classification Helpers

func prepareInputWithObservations(_ observations: [VNHumanBodyPoseObservation]) -> MLMultiArray? {
    let numAvailableFrames = observations.count
    let observationsNeeded = 45
    var multiArrayBuffer = [MLMultiArray]()

    for frameIndex in 0 ..< min(numAvailableFrames, observationsNeeded) {
        let pose = observations[frameIndex]
        do {
            let oneFrameMultiArray = try pose.keypointsMultiArray()
            multiArrayBuffer.append(oneFrameMultiArray)
        } catch {
            continue
        }
    }
    
    // If poseWindow does not have enough frames (45) yet, we need to pad 0s
    if numAvailableFrames < observationsNeeded {
        for _ in 0 ..< (observationsNeeded - numAvailableFrames) {
            do {
                let oneFrameMultiArray = try MLMultiArray(shape: [1, 3, 18], dataType: .double)
                try resetMultiArray(oneFrameMultiArray)
                multiArrayBuffer.append(oneFrameMultiArray)
            } catch {
                continue
            }
        }
    }
    return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
}

func resetMultiArray(_ predictionWindow: MLMultiArray, with value: Double = 0.0) throws {
    let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
    pointer.initialize(repeating: value)
}

// MARK: - Helper extensions

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
    func angleFromHorizontal(to point: CGPoint) -> Double {
        let angle = atan2(point.y - y, point.x - x)
        let deg = abs(angle * (180.0 / CGFloat.pi))
        return Double(round(100 * deg) / 100)
    }
}

extension CGAffineTransform {
    static var verticalFlip = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
}

extension UIBezierPath {
    convenience init(cornersOfRect borderRect: CGRect, cornerSize: CGSize, cornerRadius: CGFloat) {
        self.init()
        let cornerSizeH = cornerSize.width
        let cornerSizeV = cornerSize.height
        // top-left
        move(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerSizeV + cornerRadius))
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi,
               endAngle: -CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.minY))
        // top-right
        move(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.minY))
        addLine(to: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: -CGFloat.pi / 2,
               endAngle: 0,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.minY + cornerSizeV + cornerRadius))
        // bottom-right
        move(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerSizeV - cornerRadius))
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: 0,
               endAngle: CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.maxY))
        // bottom-left
        move(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.maxY))
        addLine(to: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.maxY))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius,
                                   y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi / 2,
               endAngle: CGFloat.pi,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.maxY - cornerSizeV - cornerRadius))
    }
}

// MARK: - Errors

enum AppError: Error {
    case captureSessionSetup(reason: String)
    case createRequestError(reason: String)
    case videoReadingError(reason: String)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            print(error)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .createRequestError(let reason):
            title = "Error Creating Vision Request"
            message = reason
        case .videoReadingError(let reason):
            title = "Error Reading Recorded Video."
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        viewController.present(alert, animated: true)
    }
}
