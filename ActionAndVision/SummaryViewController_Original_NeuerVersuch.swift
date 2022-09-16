/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller to show the game summary.
*/

import UIKit
import MessageUI
import Charts


class SummaryViewController_Original_NeuerVersuch: UIViewController {

    @IBOutlet weak var MaxKnee: UILabel!
    @IBOutlet weak var MinKnee: UILabel!
    @IBOutlet weak var MaxHip: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var MinHip: UILabel!
    @IBOutlet weak var MaxElbow: UILabel!
    @IBOutlet weak var MinElbow: UILabel!
    
    private let gameManager = GameManager.shared
    
    
 //   var lineChart = LineChartView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  //      lineChart.delegate = self
        self.updateUI()
        
        //print("Output Test")
    }
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        lineChart.center = view.center
        view.addSubview(lineChart)
        
        var entries = [ChartDataEntry]()
        
        for x in 0..<10 {
            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
        }
        
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data

    }

}
    */
    
    
    
    
    
    
    private func updateUI() {
        
        
        print("Output Test 2")
        print("Test Array: ", ArrKniewinkel)
        
        let ElbowMax = ArrElbowAngle.max()
        let HipMax = ArrHipAngle.max()
        let KneeMax = ArrKniewinkel.max()
        
        
//        let stats = gameManager.playerStats
        backgroundImage.image = gameManager.previewImage
        //displayTrajectories()
        // Speed label attributed string
        TrajectorySpeedArray.removeAll(where: {$0 == 0.0} )
        let sumArray3 = TrajectorySpeedArray.reduce(0, +)
        let avgSpeedArrayValue = sumArray3 / Double(TrajectorySpeedArray.count)
        //print("TrajectorySpeedArray: ", TrajectorySpeedArray)
        HeightArray.removeAll(where: {$0 == 0.0} )
        let sumArray2 = HeightArray.reduce(0, +)
        let avgHeightArrayValue = sumArray2 / Double(HeightArray.count)
        let SpeedCalculated = ((HumanHight - 23) / 100.0) / avgHeightArrayValue
//        let speedValueFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28.0, weight: .bold)]
        let speedValueText = round(avgSpeedArrayValue * SpeedCalculated * 3.6 * 100) / 100
//        let speedValueText = NSMutableAttributedString(string: "\(round(stats.avgSpeed * 100) / 100)", attributes: speedValueFont)
//        let speedUnitFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0, weight: .bold)]
//        speedValueText.append(NSAttributedString(string: " km/h", attributes: speedUnitFont))
        ThrowAngleArray.removeAll(where: {$0 == 0.0} )
        let sumArray = ThrowAngleArray.reduce(0, +)
        let avgArrayValue = sumArray / Double(ThrowAngleArray.count)
        // set attributed text on a UILabel
//        speedValue.text = "\(round(speedValueText * 100) / 100) km/h"
//        angleValue1.text = "\(round(avgArrayValue * 100) / 100)°"
//        scoreValue.text = "\(ThrowNumber + 1)"
        
        
        

         
         
        
        
        
         //Funktioniert nicht
         /*
        let myArray: [CGFloat] = ArrKniewinkel
             let arrayKey = "arrayKey"
             let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL // Save in Documents
             let myURL = url.appendingPathComponent("export.txt")
        
        let data = NSMutableData()
       let archiver = NSKeyedArchiver(forWritingWith: data)
       archiver.encode(myArray, forKey: arrayKey)
       archiver.finishEncoding()
       data.write(to: myURL, atomically: true)
        */

        
        // Die Zeilen waren eigentlich nicht auskommentiert
//        let ThrowOne = round(TrajectorySpeedArray[0] * SpeedCalculated * 3.6 * 100) / 100
//        let ThrowTwo = round(TrajectorySpeedArray[1] * SpeedCalculated * 3.6 * 100) / 100
//        let ThrowThree = round(TrajectorySpeedArray[2] * SpeedCalculated * 3.6 * 100) / 100
//        SingleThrowSpeed1.text = "1.: \(ThrowOne) km/h"
//        SingleThrowSpeed2.text = "2.: \(ThrowTwo) km/h"
//        SingleThrowSpeed3.text = "3.: \(ThrowThree) km/h"
    }
    

    private func displayTrajectories() {
        let stats = gameManager.playerStats
        // Display trajectories
        // Fetch saved throw paths from playerStats and draw each throw on a TrajectoryView.
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
            trajectoryView.addPath(path)
        }
    }
}
