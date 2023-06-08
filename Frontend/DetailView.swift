//
//  DetailView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/30.
//

import Alamofire
import Kingfisher
import SwiftUI
import SwiftyJSON

struct DetailView: View {
    
    var id : String
    
    let detailsAPI = "\(BASE_URL)/api/details"
    let venuesAPI = "\(BASE_URL)/api/venues"
    let artistsAPI = "\(BASE_URL)/api/artists"
    
    @State var detailsLoading = true
    @State var eventDetail: JSON = JSON()
    @State var ifFav = true
    @State var artists: [JSON] = []
    @State var venue: JSON = JSON()
    @State var venueLat: Double = 0
    @State var venueLon: Double = 0
    
    var body: some View {
        HStack {
            if $detailsLoading.wrappedValue {
                VStack(alignment: .center) {
                    Spacer()
                    ProgressView() {
                        Text("Please wait...")
                    }
                    Spacer()
                }.padding(.top, 200)
            } else {
                TabView {
                    EventsView(event: eventDetail, ifFav: ifFav).tabItem {
                        Label("Events", systemImage: "text.bubble.fill")
                    }.padding(.top, 20)
                    
                    ArtistsView(artists: artists).tabItem {
                        Label("Artist/Team", systemImage: "guitars.fill")
                    }
                    
                    VenueView(
                        eventName: eventDetail["name"].string ?? "",
                        venue: venue,
                        latitude: venueLat,
                        longitude: venueLon
                    ).tabItem {
                        Label("Venue", systemImage: "location.fill")
                    }.padding(.top, 50)
                }
                    
            }
        }.onAppear() {
            getDetails()
        }
    }
    
    func getDetails() {
        var request = URLRequest(url: URL(string: detailsAPI)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request = try! URLEncoding.default.encode(request, with: ["id": id])
        
        AF.request(request).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                if (jsonData["success"].boolValue){
                    self.eventDetail = jsonData["content"]
                }
            case .failure(let error):
                print("Error!!!")
                print(error.localizedDescription)
            }
            let favIdList = UserDefaults.standard.array(forKey: "favIdList") as? [String] ?? []
            self.ifFav = favIdList.contains(eventDetail["id"].stringValue)
            getArtists()
        }
    }
    
    func getArtists() {
        let artistNames = eventDetail["artist"].array ?? []
        if(!eventDetail["musicRelated"].boolValue) {
            getVenues()
            return
        }
        artists = Array(repeating: JSON(), count: artistNames.count)
        for (index, artist) in artistNames.enumerated() {
            var request = URLRequest(url: URL(string: artistsAPI)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request = try! URLEncoding.default.encode(request, with: ["keyword": artist.stringValue])
            
            AF.request(request).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    if (jsonData["success"].boolValue){
                        self.artists[index] = jsonData["content"]
                    }
                case .failure(let error):
                    print("Error!!!")
                    print(error.localizedDescription)
                }
                if(index == artistNames.count - 1) {
                    getVenues()
                }
            }
        }
    }
    
    func getVenues() {
        var request = URLRequest(url: URL(string: venuesAPI)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request = try! URLEncoding.default.encode(request, with: ["keyword": eventDetail["venue"].stringValue])
        
        AF.request(request).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                if (jsonData["success"].boolValue) {
                    self.venue = jsonData["content"]
                }
            case .failure(let error):
                print("Error!!!")
                print(error.localizedDescription)
            }
            let params = [
                "address": venue["address"].stringValue,
                "key": GOOGLE_API_KEY
            ]
            
            var request = URLRequest(url: URL(string: googleLocationAPI)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request = try! URLEncoding.default.encode(request, with: params)
            
            AF.request(request).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    if(jsonData["status"] != "ZERO_RESULTS") {
                        self.venueLat = jsonData["results"][0]["geometry"]["location"]["lat"].doubleValue
                        self.venueLon = jsonData["results"][0]["geometry"]["location"]["lng"].doubleValue
                    }
                case .failure(let error):
                    print("Error!!!")
                    print(error.localizedDescription)
                }
            }
            detailsLoading = false
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(id: "Z7r9jZ1Adqzue")
    }
}
