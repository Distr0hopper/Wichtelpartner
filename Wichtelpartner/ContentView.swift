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

struct WichtelpartnerView: View {
    var body: some View {
        Text("Wichtelpartner")
    }
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
                    //.contentShape(Rectangle())
                    .onTapGesture {
                        toggleConstraint(for: listPerson)
                    }
                }
            }
        }
        
    }
    func toggleConstraint(for constraintPerson: Person) {
        // Because constraints are two-directional, find the index of the constraintPerson in the list
        // of allPersons, because otherwise we cannot append or remove(at index!) of the constraint person (immutable)
        guard let indexOfConstraintPersonInArray = allPersons.firstIndex(where: {$0.id == constraintPerson.id}) else {return}
        // If the person is already in the constraint, remove it
        if person.constraints.contains(constraintPerson.id){
            // Remove that person from the list
            //person.constraints.removeAll(where: {$0 == constraintPerson.id})
            // Instead of searching through the whole array, just find the index to remove (firstIndex(of:) - remove(at:) pattern!)
            if let indexToRemove = person.constraints.firstIndex(of: constraintPerson.id) {
                person.constraints.remove(at: indexToRemove)
                allPersons[indexOfConstraintPersonInArray].constraints.remove(at:indexToRemove)
            }
            // Also remove the constraint from the other person if there is one
            //allPersons[indexOfConstraintPersonInAllPerson].constraints.removeAll(where: {$0 == person.id})
            // Again, we can use the index directly in the if-statement
        } else {
            person.constraints.append(constraintPerson.id)
            // Add the constraint also to the other person
            allPersons[indexOfConstraintPersonInArray].constraints.append(person.id)
        }
    }
}

struct ContentView: View {
    @State private var participants: [Person] = []
    @State private var newParticipantName: String = ""
    @State private var showingResultAlert: Bool = false
    @State private var resultsMessage: String = ""
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
                Button("Generate Wichtelpaar") {
                    generatePairs()
                }
            }
            .alert(isPresented: $showingResultAlert) {
                Alert(
                    title: Text("Generated Wichtelpaar"),
                    message: Text(resultsMessage)
                )
            }

        }
        .padding()
    }
    func removeParticipant(at offsets: IndexSet){
        participants.remove(atOffsets: offsets)
    }
    func generatePairs(){
        resultsMessage = "Not implemented yet"
        showingResultAlert.toggle()
    }
}

#Preview {
    ContentView()
}
