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
    @Binding var pairedResults: [(Person, Person)]
    var body: some View {
        List {
            Section(header: Text("List of Wichtelpartner results")) {
                ForEach(pairedResults, id: \.0.id) { pair in
                    HStack {
                        Text(pair.0.name)
                        Spacer()
                        Text(pair.1.name)
                    }
                }
            }
        }
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
    @State private var hideNavigationLink: Bool = false
    @State private var resultsMessage: String = ""
    @State private var pairedResults: [(Person,Person)] = []
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
            .alert("", isPresented: $showingResultAlert) {
                NavigationLink(destination: WichtelpartnerView(pairedResults: $pairedResults)) {
                    Button("Go to Wichtelpartner View") {}
                }.disabled(hideNavigationLink)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(resultsMessage)
            }

        }
        .padding()
    }
    func removeParticipant(at offsets: IndexSet){
        participants.remove(atOffsets: offsets)
    }
    func generatePairs(){
        // Pre checks: If we have not at least 2 persons or an odd number, throw error
        if participants.count < 2 || participants.count % 2 != 0{
            resultsMessage = "Not enough participants or odd number of participants"
            hideNavigationLink = true // if error, dont link to WichtelpartnerView
            showingResultAlert.toggle()
            return
        }
        // Try the pairing 100 times
        for _ in 1...100 {
            var shuffledParticipants = participants.shuffled()
            var pairsInThisAttempt: [(Person, Person)] = []
            var success = true
            
            while !shuffledParticipants.isEmpty {
                let person1 = shuffledParticipants.removeFirst()
                // Find index of a valid partner (not in constraints)
                if let partnerIndex = shuffledParticipants.firstIndex(where: {!person1.constraints.contains($0.id)}) {
                //
                let partner = shuffledParticipants.remove(at: partnerIndex)
                pairsInThisAttempt.append((person1, partner))
                print("Paired \(person1.name) with \(partner.name)")
                } else {
                    // Could not find a partner for person1, this attempt fails
                    success = false
                    break
                }
            }
            if (success){
                pairedResults = pairsInThisAttempt
                resultsMessage = "Success! A valid set of pairs was found."
                hideNavigationLink = false
                showingResultAlert.toggle()
                return
            }
            
        }
        resultsMessage = "Could not find a valid pairing after 100 attempts. Try removing some constraints."
        hideNavigationLink = true
        showingResultAlert.toggle()
    }
}

#Preview {
    ContentView()
}
