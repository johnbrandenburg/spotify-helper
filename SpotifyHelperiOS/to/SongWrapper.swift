//
//  SongWrapper.swift
//  SpotifyHelperiOS
//
//  Created by John Brandenburg on 8/20/18.
//  Copyright © 2018 TechLabs LLC. All rights reserved.
//

import UIKit

class SongWrapper: NSObject {
    
    static let TOP50ENDPOINT = "https://api.spotify.com/v1/me/top/tracks"
    
    var previous: String?
    var next: String?
    var limit: Int64?
    var total: Int64?
    var href: String?
    var items: [Song]?
    
    init(songHref: String, token: String) {
        super.init()
        let dict: NSDictionary = SongWrapper.getSongs(songHref: songHref, token: token)
        self.href = dict["href"] as? String
        self.next = dict["next"] as? String
        self.previous = dict["previous"] as? String
        self.limit = dict["limit"] as? Int64
        self.total = dict["total"] as? Int64
        
        self.items = []
        if let songs = dict["items"] as? [[String: Any]] {
            for song in songs {
                let newSong: Song = Song(json: song)
                newSong.album = SongWrapper.getAlbum(anyAlbum: song["album"] as! [String: Any], token: token)
                newSong.artists = SongWrapper.getArtists(anyArtists: song["artists"] as! NSArray)
                self.items?.append(newSong)
            }
        }
    }
    
    public func addNext(top50Response: NSDictionary, token: String) {
        self.href = top50Response["href"] as? String
        self.next = top50Response["next"] as? String
        self.previous = top50Response["previous"] as? String
        self.limit = top50Response["limit"] as? Int64
        self.total = top50Response["total"] as? Int64
        
        if let songs = top50Response["items"] as? [[String: Any]] {
            for song in songs {
                let newSong: Song = Song(json: song)
                newSong.album = SongWrapper.getAlbum(anyAlbum: song["album"] as! [String: Any], token: token)
                newSong.artists = SongWrapper.getArtists(anyArtists: song["artists"] as! NSArray)
                self.items?.append(newSong)
            }
        }
    }
    
    public static func getAlbum(anyAlbum: [String: Any], token: String) -> Album {
        return Album(json: anyAlbum, token: token)
    }
    
    public static func getArtists(anyArtists: NSArray) -> [Artist] {
        var artistArray: [Artist] = [];
        for rawArtist in anyArtists {
            artistArray.append(Artist(json: rawArtist as! [String: Any]))
        }
        return artistArray
    }
    
    public static func getSongs(songHref: String, token: String) -> NSDictionary {
        var request = URLRequest(url: NSURL(string: songHref)! as URL)
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        let data = try? NSURLConnection.sendSynchronousRequest(request, returning: response)
        return try! JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
    }
}
