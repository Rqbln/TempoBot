//
//  ContentView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 08/02/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var datas = ReadDatas()
    var body: some View {
        MainPage().environmentObject(datas)
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var previewDatas = ReadDatas()
    static var previews: some View {
        ContentView().environmentObject(previewDatas)
    }
}

