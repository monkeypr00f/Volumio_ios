//
//  BrowseTableViewController.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 11.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

/// This is the common base class for browse table view controllers.
class BrowseTableViewController: UITableViewController,
    ObservesNotifications, ShowsNotices
{
    var observers: [AnyObject] = []

    // MARK: - Common Table View Cells

    func tableView(_ tableView: UITableView,
        cellForTitle item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)

        cell.textLabel?.text = item.localizedTitle
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForTrack item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let anyCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        guard let cell = anyCell as? TrackTableViewCell
            else { fatalError() }

        cell.trackTitle.text = item.localizedTitle
        cell.trackArtist.text = item.localizedArtistAndAlbum
        cell.trackImage.setAlbumArt(for: item)
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForRadio item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let anyCell = tableView.dequeueReusableCell(withIdentifier: "radio", for: indexPath)
        guard let cell = anyCell as? RadioTableViewCell
            else { fatalError() }

        cell.radioTitle.text = item.localizedTitle
        cell.radioImage.setAlbumArt(for: item)
        return cell
    }

    func tableView(_ tableView: UITableView,
        cellForFolder item: Item,
        forRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let anyCell = tableView.dequeueReusableCell(withIdentifier: "folder", for: indexPath)
        guard let cell = anyCell as? FolderTableViewCell
            else { fatalError() }

        cell.folderTitle.text = item.localizedTitle
        cell.folderImage.setAlbumArt(for: item)
        return cell
    }

}
