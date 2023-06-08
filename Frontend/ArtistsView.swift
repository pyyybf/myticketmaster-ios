//
//  ArtistsView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/30.
//

import SwiftUI
import SwiftyJSON
import Kingfisher

struct ArtistsView: View {
    var artists: [JSON]
    
    var body: some View {
        if artists.count > 0 {
            ScrollView {
                VStack{
                    ForEach(artists) { artist in
                        VStack {
                            HStack {
                                KFImage(URL(string: artist["avatar"].string ?? ""))
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .frame(width: 110, height: 110)
                                    .cornerRadius(10)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(artist["name"].stringValue)
                                        .font(Font.system(size: 23))
                                        .bold()
                                        .lineLimit(1)
                                    HStack {
                                        Text("\(formatFollerNum(followers: artist["followers"].intValue))")
                                            .font(Font.system(size: 21))
                                        Text("Followers")
                                    }.padding(.top, 5)
                                    Link(destination: {
                                        var components = URLComponents(string: artist["spotifyLink"].stringValue)!
                                        return components.url!
                                    }()) {
                                        Image("spotify")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("Spotify").foregroundColor(.green)
                                    }
                                }//.frame(width: 120)
                                Spacer()
                                VStack(alignment: .center) {
                                    Text("Popularity").bold()
                                    // 进度条？？？
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                Color.orange.opacity(0.5),
                                                lineWidth: 15
                                            )
                                        Circle()
                                            .trim(from: 0, to: artist["popularity"].doubleValue / 100)
                                            .stroke(
                                                Color.orange,
                                                style: StrokeStyle(
                                                    lineWidth: 15
                                                )
                                            )
                                        Text("\(artist["popularity"].intValue)")
                                            .font(Font.system(size: 21))
                                    }.frame(width: 60, height: 60)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Popular Albums")
                                    .font(Font.system(size: 23))
                                    .bold()
                                HStack {
                                    ForEach(artist["albumCovers"].arrayValue.indices) { index in
                                        KFImage(URL(string: artist["albumCovers"].arrayValue[index].string ?? ""))
                                            .placeholder {
                                                ProgressView()
                                            }
                                            .resizable()
                                            .frame(width: 90, height: 90)
                                            .cornerRadius(10)
                                        if index != artist["albumCovers"].arrayValue.indices.last {
                                            Spacer()
                                        }
                                    }
                                }.padding(.horizontal, 3)
                            }.frame(maxWidth: .infinity)
                                .padding(.top, 10)
                                .padding(.horizontal, 0)
                        }.padding(.horizontal, 10)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color(red: 76/255, green: 76/255, blue: 76/255))
                            .cornerRadius(10)
                    }
                }
            }.padding(.horizontal, 15)
                .padding(.top, 5)
        } else {
            Text("No music related artist details to show")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
        }
    }
    
    func formatFollerNum(followers: Int) -> String {
        if(followers >= 1000000000) {
            return "\(Int(followers / 1000000000))B"
        } else if(followers >= 1000000) {
            return "\(Int(followers / 1000000))M"
        } else if(followers >= 1000) {
            return "\(Int(followers / 1000))K"
        }
        return "\(followers)"
    }
}

struct ArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistsView(artists: [])
    }
}
