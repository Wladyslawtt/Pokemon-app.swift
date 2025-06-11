//
//  ContentView.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //זה נותן לנו גישה לדאטה בייס מנגר
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(//זה פעולה שממיינת לנו את המידע לדוגמא כאן אנו ממיינים לפי איידי
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    //כאן יבאנו את קובץ הפטש סקוויס
    let fetcher = FetchService()

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
                        getPokemon()
                    }
                }
            }
        }
    }
    
    private func getPokemon() {//כאן הגדרנו פונקצייה שתציג לנו פוקימונים
        Task{
            for id in 1..<152 {//כאן אנו מריצים 151 פעמים פונקציית פטש כדי שיציג לנו איידי של כל ה151 פוקימונים מהדאטה
                do {//למקרה שתיהיה שגיאה אנו עושים את הפקודה בדו
                    //הפטש פוקימון פה הוא לא אותו הדבר כמו הקובץ שיצרנו
                    //הפטש כאן קשור לפטש סרוויס שיבאנו למעלה
                    //הוא מיבא מהפטש סרוויס את האיידי ששמור בפטש פוקימון
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    //כאן הגדרנו שיציג את הפוקימונים בוויוקונטנט למעלה
                    let pokemon = Pokemon(context: viewContext)
                    //כאן הגדרנו שיציג את הקטגוריות שפיענחנו בפטש סרוויס
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    //כאן אנו שומרים את כל מה שהגדרנו במסד הנתונים
                    try viewContext.save()
                }catch{
                    print(error)
                }
            }
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
