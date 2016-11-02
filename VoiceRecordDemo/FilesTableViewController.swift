//
//  FilesTableViewController.swift
//  VoiceRecordDemo
//
//  Created by qiuhong on 01/11/2016.
//  Copyright © 2016 CETCME. All rights reserved.
//

import UIKit
import AVFoundation

class FilesTableViewController: UITableViewController {
    
    var fileArray: [String]?
    var audioPlayer: AVAudioPlayer!
    
    var speakerSwitchIsOn = true
    
    var noDataLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.tableFooterView = UIView()
        
        noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 15)
        noDataLabel.text = "NO DATA"
        noDataLabel.backgroundColor = UIColor.lightGray
        noDataLabel.textColor = UIColor.darkGray
        noDataLabel.textAlignment = .center
        
        let fileManager = FileManager.default
        let mydir1 = NSHomeDirectory() + "/Documents"
        fileArray = fileManager.subpaths(atPath: mydir1)
        print("files: \(fileArray)")
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let fileArray = fileArray {
//            noDataLabel.removeFromSuperview()
            return fileArray.count
        } else {
//            tableView.superview?.addSubview(noDataLabel)
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fileArray?[indexPath.row]
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let audioURLString = NSHomeDirectory() + "/Documents/" + fileArray![indexPath.row]
        let audioURL = URL(fileURLWithPath: audioURLString)
        startPlaying(audioUrl: audioURL)
    }
    
    
    func startPlaying(audioUrl: URL) {
       
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioUrl)
            //切换扬声器和听筒
            if speakerSwitchIsOn {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } else {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            }
            audioPlayer.play()
            print("play!!")
        } catch {
        }
        
    }
    
    func deleteFile(audioUrl: URL) {
        do {
            try FileManager.default.removeItem(at: audioUrl)
        } catch {
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let audioURLString = NSHomeDirectory() + "/Documents/" + fileArray![indexPath.row]
            let audioURL = URL(fileURLWithPath: audioURLString)
            deleteFile(audioUrl: audioURL)
            
            fileArray?.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
                        
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
