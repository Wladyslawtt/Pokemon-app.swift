//
//  ContentView.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(//זה פעולה שממיינת לנו את המידע לדוגמא כאן אנו ממיינים לפי איידי
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>

    var body: some View {
        NavigationView {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink {
                        Text(pokemon.name ?? "no name")//הקוד הוא אופציונאלי לכן סימן שלאלה אומר אם לא מוצא שם אז שיציג שאין שם
                    } label: {
                        Text(pokemon.name ?? "no name")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
