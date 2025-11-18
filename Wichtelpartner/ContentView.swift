//
//  ContentView.swift
//  Wichtelpartner
//
//  Created by Julius Arzberger on 18.11.25.
//

import SwiftUI

struct ContentView: View {
    @State private var participants: [String] = []
    @State private var newParticipantName: String = ""
    var body: some View {
        VStack {
            HStack{
                TextField("New Participant", text: $newParticipantName)
                Button("Add") {
                    participants.append(newParticipantName)
                    newParticipantName = ""
                }.disabled(newParticipantName.isEmpty)
            }
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
