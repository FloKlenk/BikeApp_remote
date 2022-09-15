//
//  ViewController.swift
//  MyGraphs
//
//  Created by Florian Klenk on 23.06.22.
//

import UIKit
import Charts

class SummaryViewControllerKnee: UIViewController, ChartViewDelegate {
    var lineChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        print("live")
        super.viewDidLayoutSubviews()
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        // Eigentlich oben drüber .heigth?
        
        lineChart.center = view.center
        view.addSubview(lineChart)
        
        
        var entries = [ChartDataEntry]()
        
        var knee_live = ArrKniewinkel
        
        
        for x in 0..<knee_live.count {
            entries.append(ChartDataEntry(x: Double(x), y: Double(knee_live[x])))
        }
        
        
        let set = LineChartDataSet(entries: entries)
        //set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data

    }

}
