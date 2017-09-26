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
    var filterBookMark = false
    var filterText: String?
    let bookIcon = UIButtonType.infoLight.image()
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = true;
        searchController.searchBar.setImage(bookIcon, for: .bookmark, state: .normal)
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
        let sound = sounds[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = sound.fileName
        cell.imageView?.image = UIBarButtonSystemItem.play.image()
        cell.tintColor = sound.bookMarked ? UIColor.blue : UIColor.lightGray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[indexPath.row]
        
        let url = sound.path as NSURL
        var soundID:SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundID)
        
        let cell = tableView.cellForRow(at: indexPath) as? SoundCell
        cell?.imageView?.image = UIBarButtonSystemItem.play.image()?.withRenderingMode(.alwaysTemplate)
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
    
    override func tableView(_ tableView: UITableView,
                            accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var sound = sounds[indexPath.row]
        sound.bookMarked = !sound.bookMarked
        
        let cell = tableView.cellForRow(at: indexPath) as? SoundCell
        cell?.tintColor = sound.bookMarked ? UIColor.blue : UIColor.lightGray
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
        
        let activity = UIActivityViewController(activityItems: [sound.path.absoluteString, sound.path], applicationActivities: nil)
        self.present(activity,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func search(_ sender: Any) {
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.becomeFirstResponder()
        
        let icon = filterBookMark ? bookIcon?.withRenderingMode(.alwaysTemplate) : bookIcon
        searchController.searchBar.setImage(icon, for: .bookmark, state: .normal)
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }

        sounds.removeAll(keepingCapacity: false)
        guard let searchText = searchController.searchBar.text else { return }
        
        var array = Sound.systemSounds.filter {
            $0.fileName.lowercased().contains(searchText.lowercased())
        }
        
        if array.isEmpty {
            array = Sound.systemSounds
        }
        
        if filterBookMark {
            array = array.filter{
                $0.bookMarked
            }
        }
        
        sounds = array
        
        self.tableView.reloadData()
    }
}

extension ViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = filterText
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        self.tableView.tableHeaderView = nil
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterText = searchBar.text
        searchController.isActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sounds = Sound.systemSounds
        if filterBookMark {
            sounds = sounds.filter{
                $0.bookMarked
            }
        }
        self.tableView.reloadData()
        
        searchController.isActive = false
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        filterBookMark = !filterBookMark
        
        let icon = filterBookMark ? bookIcon?.withRenderingMode(.alwaysTemplate) : bookIcon
        searchController.searchBar.setImage(icon, for: .bookmark, state: .normal)
        
        self.updateSearchResults(for: searchController)
    }
}
