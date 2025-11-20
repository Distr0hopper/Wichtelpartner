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
    @Binding var allPersons: [Person]
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
                    //.contentShape(Rectangle())¥
                    .onTapGesture {
                        toggleConstraint(for: listPerson)
                    }
                }
            }
        }
    }
    
    func toggleConstraint(for listPerson: Person) {
        // 1. Find the index of the other person in the main array
        guard let otherPersonIndex = allPersons.firstIndex(where: { $0.id == listPerson.id }) else {
            return
        }
        
        // 2. Toggle constraint for the CURRENT person (being edited)
        if let index = person.constraints.firstIndex(of: listPerson.id) {
            person.constraints.remove(at: index)
            
            // 3. ALSO remove the constraint from the OTHER person
            if let otherConstraintIndex = allPersons[otherPersonIndex].constraints.firstIndex(of: person.id) {
                allPersons[otherPersonIndex].constraints.remove(at: otherConstraintIndex)
            }
        } else {
            person.constraints.append(listPerson.id)
            
            // 4. ALSO add the constraint to the OTHER person
            allPersons[otherPersonIndex].constraints.append(person.id)
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
                                allPersons: $participants)
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
