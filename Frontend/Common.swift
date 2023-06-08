//
//  Event.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/2.
//

import Swift
import SwiftUI
import Foundation
import SwiftyJSON

struct MyDate: Decodable, Hashable {
    var localDate: String
    var localTime: String?
}

struct Event: Decodable, Hashable {
    struct Icon: Decodable, Hashable {
        var url: String
    }
    
    var date: MyDate
    var icon: Icon
    var event: String
    var genre: String
    var venue: String
    var id: String
}

extension JSON: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}

//var BASE_URL: String = "http://localhost:8001"
var BASE_URL: String = "https://csci571-assignment9-pyyybf.wl.r.appspot.com"

var googleLocationAPI = "https://maps.googleapis.com/maps/api/geocode/json"
var GOOGLE_API_KEY = ""
var ipinfoAPI = "https://ipinfo.io/?token="
