/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This view controller allows to choose the video source used by the app.
     It can be either a camera or a prerecorded video file.
*/

import UIKit
import AVFoundation
import SwiftUI

var ShowElbow = false
var ShowShoulder = false
var ShowHip = false
var ShowKnee = false
var ShowRectangle = false
var OtherAngles = false


class SourcePickerViewController: UIViewController {
  

    private let gameManager = GameManager.shared

    override func viewDidLoad() {

            
  
    }
    
    @IBOutlet weak var ElbowSwitch: UISwitch!
    @IBOutlet weak var ShoulderSwitch: UISwitch!
    @IBOutlet weak var HipSwitch: UISwitch!
    @IBOutlet weak var KneeSwitch: UISwitch!
    @IBOutlet weak var RectangleSwitch: UISwitch!
    @IBOutlet weak var OtherAnglesSwitch: UISwitch!
    
    @IBAction func ConfirmOtherAngles(_ sender: Any) {
        if OtherAnglesSwitch.isOn {
            OtherAngles = true
            OtherAnglesSwitch.setOn(true, animated: true)
        }
        else {
            OtherAngles = false
            OtherAnglesSwitch.setOn(false, animated: false)
        }
        print(OtherAngles)
    }
    
    
    @IBAction func ConfirmRectangle(_ sender: Any) {
        if RectangleSwitch.isOn {
            ShowRectangle = true
            RectangleSwitch.setOn(true, animated: true)
        }
        else {
            ShowRectangle = false
            RectangleSwitch.setOn(false, animated: false)
        }
        print(ShowRectangle)
    }
    
    @IBAction func ConfirmElbow(_ sender: Any) {
        
        if ElbowSwitch.isOn {
         ShowElbow = true
            ElbowSwitch.setOn(true, animated: true)
        }
        else {
            ShowElbow = false
            ElbowSwitch.setOn(false, animated: false)
        }
        print(ShowElbow)
    }
    
    @IBAction func ConfirmShoulder(_ sender: Any) {
        if ShoulderSwitch.isOn {
            ShowShoulder = true
            ShoulderSwitch.setOn(true, animated: true)
        }
        else {
            ShowShoulder = false
            ElbowSwitch.setOn(false, animated: false)
        }
        print(ShowShoulder)
    }
    
    @IBAction func ConfirmHip(_ sender: Any) {
        if HipSwitch.isOn {
          ShowHip = true
            HipSwitch.setOn(true, animated: true)
        }
        else {
            ShowHip = false
            HipSwitch.setOn(false, animated: false)
        }
        print(ShowHip)
    }
    
 
    @IBAction func ConfirmKnee(_ sender: Any) {
        if KneeSwitch.isOn {
          ShowKnee = true
            KneeSwitch.setOn(true, animated: true)
        }
        else {
            ShowKnee = false
            KneeSwitch.setOn(false, animated: false)
        }
        print(ShowKnee)
    }
    
    
    
    
    

    
    

    @IBOutlet weak var HightSlider: UISlider!
    @IBOutlet weak var HightLabel: UILabel!
    
    @IBAction func ChangeHightSlider(_ sender: UISlider) {
      HightLabel.text = String(Int(sender.value))
        HumanHight = Double(HightLabel.text!) ?? 0.0
        print("HumanHight: ", HumanHight)
    }

    
    
    
    
    @IBAction func handleUploadVideoButton(_ sender: Any) {
        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie], asCopy: true)
        docPicker.delegate = self
        present(docPicker, animated: true)
    }
    
    @IBAction func revertToSourcePicker(_ segue: UIStoryboardSegue) {
        // This is for unwinding to this controller in storyboard.
        gameManager.reset()
    }
}

extension SourcePickerViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        gameManager.recordedVideoSource = nil
    }
    
    func  documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        gameManager.recordedVideoSource = AVAsset(url: url)
        performSegue(withIdentifier: "ShowRootControllerSegue", sender: self)
    }
}
