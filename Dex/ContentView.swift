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

    @FetchRequest<Pokemon>(//זה פעולה שממיינת לנו את המידע לדוגמא כאן אנו ממיינים לפי איידי
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    )private var pokedex
    //כאן יבאנו סרגל חיפוש
    @State private var searchText = ""
    //כאן יבאנו את קובץ הפטש סקוויס
    let fetcher = FetchService()
    //כאן אנו מגדירים את החיפוש עצמו
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = [] //החיפוש ריק כברירת מחדל כך הגדרנו
        
        //Search Predicate
        if !searchText.isEmpty{//אם החיפוש לא ריק
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))//לסנן לפי שם ולהציג רק מה שחיפשנו
        }
        //Filter By Favourite Predicate
        
        //Combine Predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    //כאן בגדרנו בסוגריים על מה להתבסס
                    NavigationLink(value: pokemon) {//כאן הגדרנו שיציג תמונה לכל תבנית
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        //כאן אנו מגדירים את השמות שיופיעו ליד התמונה
                        VStack(alignment: .leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)
                            
                            HStack{//כאן הגדרנו שיציג את הסוג של כל פוקימון
                                ForEach(pokemon.types!, id: \.self) { type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(Color(type.capitalized))
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }
                }
            }//כאן הגדרנו כותרת במסך הראשי
            .navigationTitle("Pokedex")
            //כאן הוספנו סרגל חיפוש לתצוגה
            .searchable(text: $searchText, prompt: "Find a Pokemon")
            //כאן ביטלנו את התיקון האוטומטי
            .autocorrectionDisabled()
            //כאן הגדרנו מה יציג אחרי שנחפש
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            //כאן הגרנו מה יציג בכל תבנית פוקימון בתוכה
            .navigationDestination(for: Pokemon.self) { pokemon in
                Text(pokemon.name ?? "no name")//הקוד הוא אופציונאלי לכן סימן שלאלה אומר אם לא מוצא שם אז שיציג שאין שם
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
