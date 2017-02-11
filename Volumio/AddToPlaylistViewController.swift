//
//  AddToPlaylistViewController.swift
//  Volumio
//
//  Created by Federico Sintucci on 07/11/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class AddToPlaylistViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
    ObservesNotifications
{
    var observers: [AnyObject] = []
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var titleTextField: UITextField!

    var track: TrackObject?

    var playlists: [Any] = []

    func playlistTitle(at index: Int) -> String? {
        return playlists[safe: index] as? String
    }
    
    // MARK: - View Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()

        track = VolumioIOManager.shared.currentTrack

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        titleTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerObserver(forName: .listPlaylists) { (notification) in
            self.clearAllNotice()

            guard let playlists = notification.object as? [Any]
                else { return }
            self.update(playlists: playlists)
        }

        pleaseWait()
    }
    override func viewDidAppear(_ animated: Bool) {
        if !VolumioIOManager.shared.isConnected && !VolumioIOManager.shared.isConnecting {
            dismiss(animated: true, completion: nil)
        }
        else {
            VolumioIOManager.shared.listPlaylist()
        }
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        unregisterObservers()

        super.viewDidDisappear(animated)
    }

    // MARK: - View Update

    func update(playlists: [Any]? = nil) {
        if let playlists = playlists {
            self.playlists = playlists
        }
        tableView.reloadData()
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(
            withIdentifier: "playlist",
            for: indexPath
        )
        guard let cell = reusableCell as? AddToPlaylistTableViewCell
            else { fatalError() }

        cell.playlistTitle = playlistTitle(at: indexPath.row)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playlistTitle = playlistTitle(at: indexPath.row),
              let currentTrackUri = track?.uri,
              let currentTrackService = track?.service
            else { return }

        VolumioIOManager.shared.addToPlaylist(
            name: playlistTitle,
            uri: currentTrackUri,
            service: currentTrackService
        )

        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let playlistTitle = titleTextField.text,
              let currentTrackTitle = track?.title,
              let currentTrackUri = track?.uri,
              let currentTrackService = track?.service
            else { return true }

        VolumioIOManager.shared.createPlaylist(
            name: playlistTitle,
            title: currentTrackTitle,
            uri: currentTrackUri,
            service: currentTrackService
        )

        titleTextField.resignFirstResponder()

        dismiss(animated: true, completion: nil)

        return false
    }

    @IBAction func closeButton(_ sender: UIButton) {
        clearAllNotice()

        dismiss(animated: true, completion: nil)
    }

}
