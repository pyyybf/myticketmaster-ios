//
//  EventsView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/30.
//

import Alamofire
import Kingfisher
import SwiftUI
import SwiftyJSON
import SwiftUI_SimpleToast

struct EventsView: View {
    var event: JSON
    
    @State var ifFav: Bool
    @State var showAddToast = false
    @State var showRemoveToast = false
    
    var body: some View {
        VStack{
            Text(event["name"].stringValue)
                .font(Font.system(size: 22))
                .bold()
                .lineLimit(1)
            HStack {
                VStack(alignment: .leading) {
                    Text("Date").bold()
                    Text(event["date"]["localDate"].string ?? "")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Artist | Team").bold()
                    Text((event["artist"].array ?? []).map { $0.stringValue }.joined(separator: " | "))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
            HStack {
                VStack(alignment: .leading) {
                    Text("Venue").bold()
                    Text(event["venue"].string ?? "")
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Genre").bold()
                    Text(event["genres"].string ?? "")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
            HStack {
                VStack(alignment: .leading) {
                    Text("Price Range").bold()
                    Text(event["priceRanges"].string ?? "0 - 0")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Ticket Status").bold()
                    Text((event["ticketStatus"].string ?? "").capitalized)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background({ () -> Color in
                            if(event["ticketStatus"].string == "onsale") {
                                return Color.green
                            } else if(event["ticketStatus"].string == "offsale") {
                                return Color.red
                            } else if(event["ticketStatus"].string == "cancelled") {
                                return Color.black
                            } else if(event["ticketStatus"].string == "postponed" || event["ticketStatus"].string == "rescheduled") {
                                return Color.orange
                            }
                            return Color.green
                        }())
                        .cornerRadius(5)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
            if $ifFav.wrappedValue {
                Button(action: {
                    // remove favorite
                    // remove id
                    var favIdList = UserDefaults.standard.array(forKey: "favIdList") as? [String] ?? []
                    if let index = favIdList.firstIndex(of: event["id"].stringValue) {
                        favIdList.remove(at: index)
                    }
                    UserDefaults.standard.set(favIdList, forKey: "favIdList")
                    // remove event
                    var favList = JSON(parseJSON: UserDefaults.standard.string(forKey: "favList") ?? "{}")
                    var dict = favList.dictionaryObject
                    dict?.removeValue(forKey: event["id"].stringValue)
                    favList = JSON(dict as Any)
                    UserDefaults.standard.set(favList.rawString(), forKey: "favList")
                    
                    ifFav = false
                    withAnimation {
                        showRemoveToast.toggle()
                    }
                }, label: {
                    Text("Remove From Favorites")
                        .foregroundColor(.white)
                        .frame(width: 90, height: 20)
                        .padding()
                        .background(.red)
                        .cornerRadius(15)
                }).buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    // add favorite
                    // add id
                    var favIdList = UserDefaults.standard.array(forKey: "favIdList") as? [String] ?? []
                    favIdList.append(event["id"].stringValue)
                    UserDefaults.standard.set(favIdList, forKey: "favIdList")
                    // add event
                    var favList = JSON(parseJSON: UserDefaults.standard.string(forKey: "favList") ?? "{}")
                    favList[event["id"].stringValue] = event
                    UserDefaults.standard.set(favList.rawString(), forKey: "favList")
                    
                    ifFav = true
                    withAnimation {
                        showAddToast.toggle()
                    }
                }, label: {
                    Text("Save Event")
                        .foregroundColor(.white)
                        .frame(width: 90, height: 20)
                        .padding()
                        .background(.blue)
                        .cornerRadius(15)
                }).buttonStyle(PlainButtonStyle())
            }
            KFImage(URL(string: event["seatMap"].string ?? ""))
//                .placeholder {
//                    ProgressView()
//                }
                .resizable()
                .frame(width: 250, height: 250)
            HStack {
                Text("Buy Ticket At:").bold()
                Link(destination: URL(string: (event["buyTicketAt"].string ?? ""))!) {
                    Text("TicketMaster")
                }
            }
            HStack {
                Text("Share on:").bold()
                Link(destination: {
                    var components = URLComponents(string: "https://m.facebook.com/sharer/sharer.php")!
                    components.queryItems = [URLQueryItem(
                        name: "u",
                        value: event["buyTicketAt"].string ?? ""
                    )]
                    return components.url!
                }()) {
                    Image("facebook")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Link(destination: {
                    var components = URLComponents(string: "https://twitter.com/intent/tweet")!
                    components.queryItems = [URLQueryItem(
                        name: "text",
                        value: "\(event["name"].string ?? "")%0D%0A \(event["buyTicketAt"].string ?? "")"
                    )]
                    return components.url!
                }()) {
                    Image("twitter")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
        }.padding(.top, -20).padding(.horizontal, 15)
            .simpleToast(
                isPresented: $showAddToast,
                options: SimpleToastOptions(alignment: .bottom, hideAfter: 2)
            ) {
                HStack {
                    Text("Added to favorites.")
                }.padding(.vertical, 30)
                    .padding(.horizontal, 50)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(10)
            }
            .simpleToast(
                isPresented: $showRemoveToast,
                options: SimpleToastOptions(alignment: .bottom, hideAfter: 2)
            ) {
                HStack {
                    Text("Remove favorite")
                }.padding(.vertical, 30)
                    .padding(.horizontal, 50)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(10)
            }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(event: JSON(), ifFav: false)
    }
}
