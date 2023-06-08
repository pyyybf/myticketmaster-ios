//
//  ContentView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/1.
//

import Alamofire
import Kingfisher
import SwiftUI
import SwiftyJSON

struct ContentView: View {
    
    let categories = ["Default", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]
    let suggestAPI = "\(BASE_URL)/api/suggest"
    let searchAPI = "\(BASE_URL)/api/search"
    
    @State var keyword = ""
    @State var distance = "10"
    @State var category = 0
    @State var location = ""
    @State var autoDetect = false
    @State var showSheet = false
    @State var suggestLoading = true
    @State var suggestions: [String] = []
    
    @State var showEvents = false
    @State var eventLoading = false
    @State var events = [Event]()
    @State private var selectedRow: Int?
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Keyword:").foregroundColor(.secondary)
                    TextField("Required", text: $keyword)
                        .onSubmit {
                            getSuggestions()
                        }
                        .sheet(isPresented: $showSheet){
                            if $suggestLoading.wrappedValue {
                                ProgressView() {
                                    Text("loading...")
                                }
                            } else {
                                SuggestSheetView(
                                    suggestions: $suggestions,
                                    selectedKeyword: $keyword,
                                    isPresented: $showSheet
                                )
                            }
                        }
                }

                HStack {
                    Text("Distance:").foregroundColor(.secondary)
                    TextField("", text: $distance).keyboardType(.numberPad)
                }

                HStack {
                    Text("Category:").foregroundColor(.secondary)
                    Picker("", selection: $category) {
                        ForEach(0 ..< categories.count, id: \.self) { index in
                            Text(categories[index])
                        }
                    }.pickerStyle(.menu)
                }

                if !$autoDetect.wrappedValue {
                    HStack {
                        Text("Location:").foregroundColor(.secondary)
                        TextField("Required", text: $location)
                    }
                }

                Toggle(isOn: $autoDetect) {
                    Text("Auto-detect my location")
                        .foregroundColor(.secondary)
                        .onChange(of: autoDetect) {newValue in
                            location = ""
                        }
                }

                HStack {
                    if $keyword.wrappedValue.replacingOccurrences(of: " ", with: "").count > 0 && ($autoDetect.wrappedValue || $location.wrappedValue.replacingOccurrences(of: " ", with: "").count > 0) {
                        Button(action: onSearch, label: {
                            Text("Search")
                                .foregroundColor(.white)
                                .frame(width: 80)
                                .padding()
                                .background(.red)
                                .cornerRadius(10)
                        }).buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            // disabled
                        }, label: {
                            Text("Search")
                                .foregroundColor(.white)
                                .frame(width: 80)
                                .padding()
                                .background(.gray)
                                .cornerRadius(10)
                        }).buttonStyle(PlainButtonStyle()).disabled(true)
                    }
                    Spacer()
                    Button(action: onClear, label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .frame(width: 80)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                    }).buttonStyle(PlainButtonStyle())
                }.padding(15)
                
                if $eventLoading.wrappedValue {
                    Section {
                        Text("Results").font(.title).bold()
                        HStack(alignment: .center) {
                            Spacer()
                            ProgressView() {
                                Text("Please wait...")
                            }
                            Spacer()
                        }
                    }
                }
                
                if $showEvents.wrappedValue {
                    Section {
                        Text("Results").font(.title).bold()
                        if $events.count > 0 {
                            // show results
                            List {
                                ForEach(events, id: \.self) { event in
                                    NavigationLink(destination: DetailView(id: event.id).padding(.top, -200)) {
                                        Text({() -> String in
                                            if let localTimeString = event.date.localTime {
                                                return "\(event.date.localDate)|\(localTimeString)"
                                            } else {
                                                return event.date.localDate
                                            }
                                        }()).font(Font.system(size: 15))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80)
                                        KFImage(URL(string: event.icon.url))
                                            .placeholder {
                                                ProgressView()
                                            }
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(5)
                                        Text(event.event).bold()
                                            .frame(width: 75)
                                            .lineLimit(3)
                                        Text(event.venue).foregroundColor(.secondary).bold()
                                        //                                            .frame(width: 60)
                                    }.padding(.vertical)
                                }
                            }
                        } else {
                            Text("No result available").foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitle("Event Search")
            .navigationBarItems(trailing: NavigationLink(
                destination: FavoritesView()
            ) {
                Image(systemName: "heart.circle")
            })
        }
    }
    
    func getSuggestions() {
        suggestLoading = true
        showSheet = true
        suggestions = []
        
        var request = URLRequest(url: URL(string: suggestAPI)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request = try! URLEncoding.default.encode(request, with: ["keyword": keyword])

        AF.request(request).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                if(jsonData["success"].boolValue) {
                    self.suggestions = jsonData["content"].map {$0.1.stringValue}
                } else {
                    self.suggestions = []
                    print(jsonData["message"])
                }
            case .failure(let error):
                print("Error!!!")
                print(error.localizedDescription)
            }
            self.suggestLoading = false
        }
    }
    
    func onSearch() {
        showEvents = false
        eventLoading = true
        if(autoDetect) {
            AF.request(ipinfoAPI).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    let loc = jsonData["loc"].stringValue.components(separatedBy: ",")
                    search(lat: loc[0], lon: loc[1])
                case .failure(let error):
                    eventLoading = false
                    self.events = []
                    self.showEvents = true
                    print("Error!!!")
                    print(error.localizedDescription)
                }
            }
        } else {
            let params = [
                "address": location,
                "key": GOOGLE_API_KEY
            ]
            
            var request = URLRequest(url: URL(string: googleLocationAPI)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request = try! URLEncoding.default.encode(request, with: params)

            AF.request(request).responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    if(jsonData["status"] == "ZERO_RESULTS") {
                        self.eventLoading = false
                        self.events = []
                        self.showEvents = true
                    } else {
                        search(lat: jsonData["results"][0]["geometry"]["location"]["lat"].stringValue,
                               lon: jsonData["results"][0]["geometry"]["location"]["lng"].stringValue)
                    }
                case .failure(let error):
                    self.eventLoading = false
                    self.events = []
                    self.showEvents = true
                    print("Error!!!")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func search(lat: String, lon: String) {
        // search the events
        let params = [
            "keyword": keyword,
            "distance": distance,
            "category": categories[category],
            "lat": lat,
            "lon": lon
        ]
        
        var request = URLRequest(url: URL(string: searchAPI)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request = try! URLEncoding.default.encode(request, with: params)

        AF.request(request).responseDecodable(of: Response.self) { response in
            switch response.result {
            case .success(let data):
                if(data.success) {
                    self.events = data.content ?? []
                } else {
                    self.events = []
                    print(data.message)
                }
            case .failure(let error):
                self.events = []
                print("Error!!!")
                print(error.localizedDescription)
            }
            showEvents = true
            eventLoading = false
        }
    }
    
    func onClear() {
        keyword = ""
        distance = "10"
        category = 0
        location = ""
        autoDetect = false

        showEvents = false
        events = []
    }
    
    struct Response: Decodable {
        var success: Bool
        var message: String
        var content: [Event]
    }
}

struct SuggestSheetView: View {
    @Binding var suggestions: [String]
    @Binding var selectedKeyword: String
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Text("Suggestions")
                .font(Font.system(size: 30))
                .bold()
        }.padding(15)
        List {
            ForEach(suggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .foregroundColor(.black)
                    .onTapGesture {
                        self.selectedKeyword = suggestion
                        self.isPresented = false
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
