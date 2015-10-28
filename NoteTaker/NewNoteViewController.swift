//
//  NewNoteViewController.swift
//  NoteTaker
//
//  Created by Pat Butler on 2015-10-01.
//  Copyright © 2015 RPG Ventures. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NewNoteViewController: UIViewController {
    
    //*** required *** init now requires an optional question mark ? at the start of the init declaration
    // Setting up an audio recorder takes a little bit more work than setting up an audio player
    // we need to initialize the recorder components before we can use them
    // 1. create a baseString, which is just accessing the users home directory path and storing it in baseString
    // 2. the  NSUUID().UUIDString call is a string formatter that creates unique strings, we assign it to the audioURL so the audio files are unique, and just add the file type to the end of it
    // 3. create a pathComponents var, that contains the baseString (users home director), and the audioURL
    // 4. create an NSURL object, and put in it the pathComponents var (which has the baseString and audioURL)
    // 5. create a session var to hold the audio context of the app, which means we are going assign certain settings for recording
    // 6. create a recordSettings var that will hold our recoding settings that we choose for the recorder, like the sampleRateKey, the number of channels we want the recorder to have, and the audio quailty as well, all that gets stored into the recordettings variable
    // 7. add to the session var the type of recording session we want..here its PlayAndRecord, and we try to set that setting in the do catch construct, because creating an audio session can throw an error, so we need to handle that using the keyword "try", and if there is an error, we print out its description in the catch block so we know what went wrong
    // And we store into the audioRecorder, the audioNSURL, which has the path of the recording, and the record settings we just set in the recordSettings variable (so all the info we created above gets put into the audioRecorder)... And we try to do that in the do catch construct again, because grabbing an audio file from a path can throw an error if the file is not there for some reason.
    // 8. set the audio metering to true, which enables a metering scale of the audio input, that we will access later to show the audio level input and display that in a percentage to the user
    // 9. we call the prepareToRecord() which creates an audio file and prepares the system for recording.
    // 10. this Super init gets set last here...we call the inits super class to access its functionality here (has to do with subclassing)
    
    //Apple introduced failable initializers.. which are, initializers that can return nil instead of an instance. You define a failable initializer by putting a question mark ? after the init declaration
    
    required init?(coder aDecoder: NSCoder) {
        
        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String  //1
        self.audioURL = NSUUID().UUIDString + ".m4a"                                         //2
        let pathComponents = [baseString, self.audioURL]                                    //3
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)!                   //4
        let session = AVAudioSession.sharedInstance()                                       //5
        
        let recordSettings = [                                                              //6
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 2 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)                    //7
            self.audioRecorder = try AVAudioRecorder(URL: audioNSURL, settings: recordSettings)
        } catch let initError as NSError {
            print("Initialization error: \(initError.localizedDescription)")
        }
        
        self.audioRecorder.meteringEnabled = true                                           //8
        self.audioRecorder.prepareToRecord()                                                //9
    
        super.init(coder: aDecoder)                                                         //10
    }
  
    
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var recordOutlet: UIButton!
  
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var peakImageView: UIImageView!
    @IBOutlet weak var averageImageView: UIImageView!
    
    
    var audioRecorder: AVAudioRecorder!
    var audioURL: String
    var audioPlayer = AVAudioPlayer()
    
    let timeInterval: NSTimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordOutlet.layer.shadowOpacity = 1.0
        recordOutlet.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //HOW TO SAVE THE SOUND AND LABEL TEXT TO CORE DATA
    // 1. the first line we create a context var and then go to the the App delegate class, and grab from that class the managedObjectContext object…this is the the managed object context for the application (which is bound to the persistent store coordinator, which means its the main var we use to manage the variables in core data.) we use the context var to let us save and retrieve the data...in this case, save data
    // 2. we create the new core data note variable, which will hold the users recordings and titles for us, and pass in the context var, to manage the data.. (the "Note" entity name has to match exactly to what we created in the core data file)
    // 3. store the users typed text into the core data name property of the newly created note var (and again, core data calls properties attributes)
    // 4. set the audioURL string we created above to the core data url attribute (attribute and property are synomonous)
    // 5. try to save sound url and name to core data using the do catch, if theres a problem saving, we handle the error…here well print out the type of error we get
    // 6. Then Dismiss ViewController
    
    @IBAction func save(sender: AnyObject) {
        
        
        if noteTextField.text != "" {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext                     //1
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note    //2
        note.name = noteTextField.text!                                                                                     //3
        note.url = audioURL                                                                                                 //4
        
        do {                                                                                                                //5
            try context.save()
        } catch let saveError as NSError {
            print("Saving error: \(saveError.localizedDescription)")
        }
        }
        self.dismissViewControllerAnimated(true, completion: nil)                                                            //6
        
    }
   
    
    @IBAction func record(sender: AnyObject) {
        
        let mic = UIImage(named: "record button.png") as UIImage!
        recordOutlet.setImage(mic, forState: .Normal)
    
        recordOutlet.layer.shadowOpacity = 1.0
        recordOutlet.layer.shadowOffset = CGSize(width: 5.0, height: 4.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
        
        if audioRecorder.recording {
            audioRecorder.stop()
            
            let mic = UIImage(named: "Mic button.png") as UIImage!
            recordOutlet.setImage(mic, forState: .Normal)
            
        } else {
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setActive(true)
                audioRecorder.record()
            } catch let recordError as NSError {
                print("Recording Error: \(recordError.localizedDescription)")
            }
        }
    }
    
    @IBAction func touchDownRecord(sender: AnyObject) {
        
        audioPlayer = getAudioPlayerFile("startRecordSound", type: "m4a")
        audioPlayer.play()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "updateAudioMeter:", userInfo: nil, repeats: true)
        timer.fire()
        
        recordOutlet.layer.shadowOpacity = 0.9
        recordOutlet.layer.shadowOffset = CGSize(width: -2.0, height: -2.0)
        recordOutlet.layer.shadowRadius = 5.0
        recordOutlet.layer.shadowColor = UIColor.blackColor().CGColor
        
    }
  
    
    // A function to update the meters and to update the label too
    
   func updateAudioMeter(timer: NSTimer) {
        if audioRecorder.recording {
            
            let dFormat = "%02d"
            let min:Int = Int(audioRecorder.currentTime / 60)
            let sec:Int = Int(audioRecorder.currentTime % 60)
            let timeString = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            timeLabel.text = timeString
            audioRecorder.updateMeters()
            let averageAudio = audioRecorder.averagePowerForChannel(0) * -1
            let peakAudio = audioRecorder.peakPowerForChannel(0) * -1
            let progressViewAverage = Int(averageAudio)        //   /100 if using a float
            let peakViewAverage = Int(peakAudio)               //    /100 if using float
            
            averageRadial(progressViewAverage, peak: peakViewAverage)
            
            
        } else if !audioRecorder.recording {
            
           averageImageView.image = UIImage(named: "average0radial.png")
            peakImageView.image = UIImage(named: "peak0value.png")
            crossfadeTransition()
            
        }
        
    }
    
    
    // A function that grabs any audio file path and creates the audio player
    
    func getAudioPlayerFile(file: String, type: String) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch let audioPlayerError as NSError {
            print("Failed to initialize player error: \(audioPlayerError.localizedDescription)")
        }
        return audioPlayer!
    }

    func averageRadial (average: Int, peak: Int) {
        
        switch average {
        case average: averageImageView.image = UIImage(named: "average\(String(average))radial")
            crossfadeTransition()
        
        default: averageImageView.image = UIImage(named: "average10radial.png")
            crossfadeTransition()
            
        }
        
        switch peak {
        case peak: peakImageView.image = UIImage(named: "peak\(String(peak))value")
            crossfadeTransition()
        default: peakImageView.image = UIImage(named: "peak10value.png")
            crossfadeTransition()
        }
        
    }
    
    func crossfadeTransition() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.addAnimation(transition, forKey: nil)
        
    }
    
    
    
    
    
    
    
}
