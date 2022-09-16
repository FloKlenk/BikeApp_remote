//
//  ViewController.swift
//  MyGraphs
//
//  Created by Florian Klenk on 23.06.22.
//

import UIKit
import Charts

class SummaryViewControllerElbow: UIViewController, ChartViewDelegate {
    var lineChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        // Eigentlich oben drüber .heigth?
        
        lineChart.center = view.center
        view.addSubview(lineChart)
        
        var entries = [ChartDataEntry]()
        
        var hip_angle = [49.0, 48.0, 47.0, 48.0, 49.0, 50.0]
        
        //var linda = ArrKniewinkel
        
        for x in 0..<hip_angle.count {
            entries.append(ChartDataEntry(x: Double(x), y: Double(hip_angle[x])))
        }
        
        
        let set = LineChartDataSet(entries: entries)
        //set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data

    }

}
