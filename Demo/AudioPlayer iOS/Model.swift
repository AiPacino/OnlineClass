//
//  Model.swift
//  Demo
//
//  Created by 刘兆娜 on 16/4/14.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation

class Album {
    var id: String = ""
    var name: String = ""
    var author: String = ""
    var image: String = ""
    var songs = [Song]()
    
    var hasImage: Bool {
        get {
            return !image.isEmpty
        }
    }
}

class Song {
    var name: String = ""
    var desc: String = ""
    var date: String = ""
    var url: String = ""
    var album: Album!
}