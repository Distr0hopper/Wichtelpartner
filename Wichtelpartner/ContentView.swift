//
//  ContentView.swift
//  Wichtelpartner
//
//  Created by Julius Arzberger on 18.11.25.
//

import SwiftUI

struct ContentView: View {
    @State var participants: [String] = ["juli","lola","fabi"]
    @State var newParticipantName: String = ""
    var body: some View {
        VStack {
            List{
                Text("Participants:")
                ForEach(participants, id: \.self){ name in
                    Text(name)
                }
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
