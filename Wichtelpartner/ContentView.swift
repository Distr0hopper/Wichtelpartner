//
//  ContentView.swift
//  Wichtelpartner
//
//  Created by Julius Arzberger on 18.11.25.
//

import SwiftUI

struct Person: Identifiable{
    let id = UUID()
    var name: String
    var constraints: [UUID] = []
}

struct PersonDetailView: View {
    @Binding var person: Person
    let allPersons: [Person]
    var body: some View {
        let filteredList = allPersons.filter({person.id != $0.id})
        List {
            Section(header: Text("Select constraints for \(person.name)")) {
                ForEach(filteredList){ listPerson in
                    HStack {
                        Text(listPerson.name)
                        Spacer()
                        if person.constraints.contains(listPerson.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                    //.contentShape(Rectangle())
                    .onTapGesture {
                        toggleConstraint(for: listPerson)
                    }
                }
            }
        }
    }
    
    func toggleConstraint(for listPerson: Person) {
        if let index = person.constraints.firstIndex(of: listPerson.id){
            person.constraints.remove(at: index) 
        } else {
            person.constraints.append(listPerson.id)
        }
    }
}

struct ContentView: View {
    @State private var participants: [Person] = []
    @State private var newParticipantName: String = ""
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    TextField("New Participant", text: $newParticipantName)
                    Button("Add") {
                        guard !newParticipantName.isEmpty else { return }
                        let newParticipant = Person(
                            name: newParticipantName.capitalized
                        )
                        participants.append(newParticipant)
                        newParticipantName = ""
                    }.disabled(newParticipantName.isEmpty)
                }
                List{
                    Section(header: Text("Participants:")){
                        ForEach($participants){ person in
                            NavigationLink(destination: PersonDetailView(
                                person: person,
                                allPersons: participants)
                                ) {
                                Text(person.wrappedValue.name)
                            }
                        }
                        .onDelete(perform: removeParticipant)
                    }
                }
            }

        }
        .padding()
    }
    func removeParticipant(at offsets: IndexSet){
        participants.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
