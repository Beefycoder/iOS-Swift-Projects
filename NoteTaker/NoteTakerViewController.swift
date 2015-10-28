//
//  NoteTakerNoteTaker.swift
//  NoteTaker
//
//  Created by Pat Butler on 2015-10-01.
//  Copyright © 2015 RPG Ventures. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class NoteTakerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notesArray: [Note] = []
    
    var audioPlayer = AVAudioPlayer()

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 65.0
    
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //CREATE THE CONTEXT VAR THAT WILL BE USED TO RETRIEVE THE SAVED CORE DATA
    //this all has to be done in viewWillAppear so it shows up
    
    //1. in the first line we create a context var that that grabs the managedObjectContext from the App delegate class. we use the context var to let us save and retrieve data...in this case, we are fetching or retrieving the data from core data
    //2. we create a request variable which will hold the search criteria we want from core data, and here we want all the data from the Note entity
    //3. store in the notesArray array the objects from the fetch request, the url and name attributes, cast as a Note array because executeFetchRequest has a type thats anyObject, and if we don’t cast it as a note array we won’t be able to store that in our notesArray
    //4. reload the table data, which refreshes all the data so its up to date
    //now our objects from core data are stored into the notesArray ready to be displayed,

    
    override func viewWillAppear(animated: Bool) {
        
        let context  = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext    //1
        let request = NSFetchRequest(entityName: "Note")                                                    //2
        self.notesArray = (try! context.executeFetchRequest(request)) as! [Note]                            //3
        
        self.tableView.reloadData()                                                                         //4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let sound = notesArray[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel!.text = sound.name
        
        let font = UIFont(name: "Baskerville-BoldItalic", size: 28)
        cell.textLabel?.font = font
        return cell
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
    
    //THIS IS HOW TO FETCH THE SOUND FROM CORE DATA AND PLAY IT
    // 1. create a variable called sound and set it to the row the user taps on
    // 2. create a baseString, which accesses the users home directory path, storing it in a baseString var
    // 3. create a pathComponents var that contains the baseString (users home directory), and the sound.url (the sound associated with the row the user tapped on)..the 2 things we need to retrieve the sound
    // 4. lets initialize the pathComponants var to an NSURL
    // 5. create a session variable to hold the audio context of the app, we do this to set the audio context for the app and to express to the system our intentions for the app’s audio behavior.
    // 6. set the session to playback so the volume on the iphone just uses AVAudioSessionCategoryPlayback,.. instead of using AVAudioSessionCategoryPlayAndRecord that we set in the NewNoteViewController class for recording...setting to playback increase the volumn quite a bit, because its dedicated to just playing the audio, not recording
    // 7. set the audioPlayer to the audioNSURL (location of the sound)...and we try to do these 2 lines of code in the do catch, because these calls can throw an error, and we handle that is the catch block by printing out the type of error we get if any
    // 8. play the sound
    // 9. deselect the row so it dosent remain highlighted highlighted
    // remember, this all fires when the user taps the row
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        let sound = notesArray[indexPath.row]                               //1
        let baseString : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String                                                          //2
        let pathComponents = [baseString, sound.url]                        //3
        let audioNSURL = NSURL.fileURLWithPathComponents(pathComponents)!   //4
        let session = AVAudioSession.sharedInstance()                       //5
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)         //6
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: audioNSURL) //7
        } catch let fetchError as NSError {
            print("Fetch error: \(fetchError.localizedDescription)")
        }
        
        self.audioPlayer.play()                                             //8
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)         //9
        
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRowsInSection(section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
                let image : UIImage = UIImage(named: "Check mark")!
                cell.imageView!.image = image
            }
        }
    }
    
    
    
    //DELETE AN OBJECT FROM THE CORE DATA STORE, AND DELETE IT FROM THE TABLEVIEW
    //1. check if the editing style is for Delete
    //2. create an app delegate variable
    //3. create a context variable with the type of NSManagedObjectContext, assign it appDell variable...now we can use the context var to delete objects from core data
    //4. use that context variable and call deleteObject on it to delete the note from the core data store
    //5. then we remove the object from the notesArray with removeAtIndex
    //6. try to save all the deletion changes we just made to the core data store, in the do catch, if there was a problem updating core data with this deletion change, then lets catch the error on the catch block, and print out what went wrong
    //7. finally remove the deleted item from the tableView, with some animation
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:                                                                               //1
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate     //2
            let context: NSManagedObjectContext = appDel.managedObjectContext                       //3
            context.deleteObject(notesArray[indexPath.row] as NSManagedObject)                      //4
            notesArray.removeAtIndex(indexPath.row)                                                 //5
            
            do {
                try context.save()
                
            } catch let deleteError as NSError {
                print("Delete Error: \(deleteError.localizedDescription)")
            }                                                                                       //6
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)             //7
        default:
            return
        }
    }
    
    
    
}









