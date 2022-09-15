//
//  ViewController.swift
//  MyGraphs
//
//  Created by Florian Klenk on 23.06.22.
//

import UIKit
import Charts




class SummaryViewController: UIViewController, ChartViewDelegate {
    

    var lineChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        lineChart.delegate = self


        
    }
    
    private func updateUI() {
        
        print("Output Test 2")
        print("Test Array: ", ArrKniewinkel)
        
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        // Eigentlich oben drüber .heigth?
        
        lineChart.center = view.center
        view.addSubview(lineChart)
        
        
        var entries = [ChartDataEntry]()
        
        var knee_Angle = ArrKniewinkel
        
        //var linda = [48.0, 49.0, 49.0, 50.0, 51.0, 52.0, 53.0, 56.0, 57.0, 60.0, 63.0, 68.0, 70.0, 75.0, 77.0, 82.0, 87.0, 91.0, 93.0, 98.0, 106.0, 111.0, 118.0, 125.0, 131.0, 136.0, 135.0, 138.0, 138.0, 136.0, 134.0, 128.0, 120.0, 116.0, 107.0, 101.0, 93.0, 88.0, 86.0, 82.0, 77.0, 71.0, 67.0, 62.0, 59.0, 54.0, 51.0, 49.0, 48.0, 47.0, 47.0, 47.0, 48.0, 49.0, 51.0, 52.0, 54.0, 57.0, 60.0, 64.0, 69.0, 73.0, 77.0, 84.0, 88.0, 93.0, 96.0, 101.0, 108.0, 113.0, 117.0, 121.0, 127.0, 131.0, 130.0, 126.0, 122.0, 117.0, 111.0, 105.0, 98.0, 91.0, 85.0, 80.0, 73.0, 68.0, 64.0, 61.0, 56.0, 53.0, 51.0, 49.0, 49.0, 48.0, 47.0, 48.0, 49.0, 50.0, 53.0, 56.0, 59.0, 62.0, 68.0, 72.0, 78.0, 82.0, 87.0, 93.0, 94.0, 102.0, 105.0, 111.0, 114.0, 119.0, 125.0, 127.0, 126.0, 124.0, 118.0, 113.0, 107.0, 99.0, 92.0, 86.0, 79.0, 73.0, 67.0, 64.0, 61.0, 56.0, 53.0, 50.0, 48.0, 48.0, 47.0, 46.0, 47.0, 49.0, 50.0, 53.0, 56.0, 62.0, 66.0, 69.0, 75.0, 80.0, 85.0, 91.0, 93.0, 99.0, 104.0, 111.0, 115.0, 119.0, 124.0, 125.0, 125.0, 121.0, 116.0, 112.0, 104.0, 97.0, 89.0, 82.0, 75.0, 70.0, 64.0, 60.0, 56.0, 53.0, 49.0, 49.0, 48.0, 47.0, 47.0, 49.0, 51.0, 54.0, 56.0, 61.0, 66.0, 69.0, 75.0, 79.0, 85.0, 90.0, 95.0, 100.0, 106.0, 110.0, 114.0, 119.0, 125.0, 126.0, 124.0, 121.0, 114.0, 108.0, 103.0, 93.0, 87.0, 80.0, 74.0, 68.0, 63.0, 61.0, 57.0, 54.0, 50.0, 49.0, 48.0, 48.0, 47.0, 48.0, 48.0, 50.0, 51.0, 54.0, 56.0, 59.0, 64.0, 69.0, 75.0, 80.0, 85.0, 92.0, 95.0, 102.0, 104.0, 110.0, 113.0, 116.0, 119.0, 124.0, 126.0, 123.0, 119.0, 115.0, 110.0,  80.0, 74.0, 69.0, 65.0]
        
        for x in 0..<knee_Angle.count {
            entries.append(ChartDataEntry(x: Double(x), y: Double(knee_Angle[x])))
        }
        
        
        let set = LineChartDataSet(entries: entries)
        //set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
        

    }
        
}
