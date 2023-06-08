//
//  FavoritesView.swift
//  Frontend
//
//  Created by 潘越 on 2023/4/30.
//

import SwiftUI
import SwiftyJSON

struct FavoritesView: View {
    @State var favIdList: [String] = []
    @State var favList: JSON = JSON()
    
    var body: some View {
        NavigationView {
            if favIdList.count > 0 {
                Form {
                    List {
                        ForEach(favIdList, id: \.self) { eventId in
                            HStack {
                                Text(favList[eventId]["date"]["localDate"].stringValue).font(Font.system(size: 12))
                                Text(favList[eventId]["name"].stringValue).lineLimit(2).font(Font.system(size: 12))
                                Text(favList[eventId]["genres"].stringValue).font(Font.system(size: 12))
                                Text(favList[eventId]["venue"].stringValue).font(Font.system(size: 12))
                            }
                        }.onDelete(perform: delete)
                    }
                }.navigationBarTitle("Favorites")
            } else {
                Text("No favorites found").foregroundColor(.red)
                    .navigationBarTitle("Favorites")
            }
        }.onAppear() {
            favIdList = UserDefaults.standard.array(forKey: "favIdList") as? [String] ?? []
            favList = JSON(parseJSON: UserDefaults.standard.string(forKey: "favList") ?? "{}")
        }.padding(.top, -250)
    }
    
    func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            let delId = favIdList[index]
            // delete event
            var dict = favList.dictionaryObject
            dict?.removeValue(forKey: delId)
            favList = JSON(dict as Any)
            UserDefaults.standard.set(favList.rawString(), forKey: "favList")
            // delete id
            favIdList.remove(at: index)
            UserDefaults.standard.set(favIdList, forKey: "favIdList")
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
