//
//  VenueView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/30.
//

import SwiftUI
import SwiftyJSON
import MapKit
import Alamofire

struct VenueView: View {
    var eventName: String
    var venue: JSON
    var latitude: Double
    var longitude: Double
    
    @State var showMap = false
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var body: some View {
        VStack {
            Text(eventName)
                .font(Font.system(size: 22))
                .bold()
                .lineLimit(1)
            VStack {
                Text("Name")
                    .bold()
                Text(venue["name"].string ?? "")
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }.padding(5)
            VStack {
                Text("Address")
                    .bold()
                Text(venue["address"].string ?? "")
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }.padding(5)
            VStack {
                Text("Phone Number")
                    .bold()
                Text(venue["phoneNumber"].string ?? "")
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }.padding(5)
            VStack {
                Text("Open Hours")
                    .bold()
                ScrollView {
                    Text(venue["openHours"].string ?? "")
                        .foregroundColor(.gray)
                }.frame(height: 65)
            }.padding(5)
            VStack {
                Text("General Rule")
                    .bold()
                ScrollView {
                    Text(venue["generalRule"].string ?? "")
                        .foregroundColor(.gray)
                }.frame(height: 65)
            }.padding(5)
            VStack {
                Text("Child Rule")
                    .bold()
                ScrollView {
                    Text(venue["childRule"].string ?? "")
                        .foregroundColor(.gray)
                }.frame(height: 65)
            }.padding(5)
            Button(action: {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                showMap = true
            }, label: {
                Text("Show venue on maps")
                    .foregroundColor(.white)
                    .padding()
                    .background(.red)
                    .cornerRadius(15)
            }).buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showMap){
                MapSheetView(
                    isPresented: $showMap,
                    region: $region,
                    markers: [Marker(latitude: latitude, longitude: longitude)]
                )
            }
        }.padding(.top, -80).padding(.horizontal, 15)
    }
}

struct MapSheetView: View {
    @Binding var isPresented: Bool
    @Binding var region: MKCoordinateRegion
    @State var markers: [Marker]
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: markers) { marker in
            MapMarker(coordinate: marker.coordinate, tint: .red)
        }
        .edgesIgnoringSafeArea(.all)
        .padding(15)
    }
}

struct Marker: Identifiable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct VenueView_Previews: PreviewProvider {
    static var previews: some View {
        VenueView(eventName:"", venue: JSON(), latitude: 0, longitude: 0)
    }
}
