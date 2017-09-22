//
//  ViewController.swift
//  iOSSystemSounds
//
//  Created by Wayne Yeh on 2017/9/21.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UITableViewController {
    var sounds = Sound.systemSounds
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = sounds[indexPath.row].fileName
        cell.imageView?.image = UIBarButtonSystemItem.play.image()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[indexPath.row]
        
        let url = sound.path as NSURL
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundID)
        
        let cell = tableView.cellForRow(at: indexPath) as? SoundCell
        cell?.imageView?.image = UIBarButtonSystemItem.pause.image()
        cell?.bar.progress = 1
        
        AudioServicesPlaySystemSound(soundID)
        
        UIView.animate(withDuration: sound.duration,
                       animations: {
                cell?.bar.layoutIfNeeded()
        }) { (finish) in
            DispatchQueue.main.async {
                cell?.bar.progress = 0
                cell?.imageView?.image = UIBarButtonSystemItem.play.image()
            }
        }
    }
    
    @IBAction func action(_ sender: Any) {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            let alert = UIAlertController( title: nil,
                                           message: "Please select one",
                                           preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil)
            alert.addAction(ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return
        }
        
        let sound = sounds[indexPath.row]
        
        let activity = UIActivityViewController(activityItems: [sound.fileName], applicationActivities: nil)
        self.present(activity,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func search(_ sender: Any) {
        self.tableView.tableHeaderView = searchController.searchBar
//        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }

        sounds.removeAll(keepingCapacity: false)
        guard let searchText = searchController.searchBar.text else { return }
        
        sounds = Sound.systemSounds.filter {
            $0.fileName.lowercased().contains(searchText.lowercased())
        }
        
        self.tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.tableHeaderView = nil
        searchController.isActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sounds = Sound.systemSounds
        self.tableView.tableHeaderView = nil
        self.tableView.reloadData()
        
        searchController.isActive = false
    }
}
