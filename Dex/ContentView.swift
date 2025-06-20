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
    //זוהי בקשה פטש רקווסט שמביאה נתונים ממסד הנתונים של קור דאטה במקרה הזה היא נועדה לשלוף את כל האובייקטים מסוג פוקימון ולשמור אותם במשתנה אול
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
//בקיצור הפטשים יוצרים תצוגות ממוחשבות עם כל הנתונים כמו חלונות בעצם כל פטש זה חלון נפרד סוגשל במקום שניצור אותם ידנית
    @FetchRequest<Pokemon>(//זה פעולה שממיינת לנו את המידע ושומרת אותו במשתנה פוקידקס לדוגמא כאן אנו ממיינים לפי איידי
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    )private var pokedex
    //כאן יבאנו סרגל חיפוש
    @State private var searchText = ""
    //כאן הגדרנו סינון לפי אהובים כברירת מחדל הוא כבוי
    @State private var filterByFavorites = false
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
        if filterByFavorites {//אם הוא מסונן לפי אהובים
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        //Combine Predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)//כאן הוא מחזיר לנו את כל הסינון והחיפוש
    }

    var body: some View {//האיף מריצה ישר את כל הפוקימונים ומוסיפה חלון הוראות מה לעדות אם לא יוצג כלום
        if all.isEmpty {//למקרה שהמסך יהיה ריק שתופיע הודע מה לעשות
            //הוספנו שיהיה ללחות על הפונקציה שיצרנו שיופיעו פוקימונים ומקרה ולא יופיע כלום
            ContentUnavailableView {
                Label("NO POKEMON", image: .nopokemon)
            } description: {
                Text("There ain't any Pokemon yet.\nFetch some Pokemon to get started")
            } actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1) //כאן הגדרנו שזה יציג פוקימונים ממספר מזוהה 1 והלך
                }
                .buttonStyle(.borderedProminent)
            }

        }else{
            
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            //כאן בגדרנו בסוגריים על מה להתבסס
                            NavigationLink(value: pokemon) {
                                //בודק אם לפוקימון אין משתנה בספרייט
                                //הקוד הזה אמור לתת לנו להשתמש בתמונות שנשמרות לנו בטלפון מבלי לגשת לאינטרנט כל פעם
                                if pokemon.sprite == nil {
                                    //כאן הגדרנו שיציג תמונה לכל תבנית
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {//אם יש אז הוא אמור להחזיר את התמונה שהגדרנו בקובץ פוקימוןאקס
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                //כאן אנו מגדירים את השמות שיופיעו ליד התמונה
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        //כאן הגדרנו ליד כל מועדף תהיה כוכבית
                                        if pokemon.favorite{
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    
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
                            .swipeActions(edge: .leading) {//כאן הוספנו החלקה למועדפים
                                //אם פוקימון פייבור שווה לטרו אז להחסיר מהמועדפים
                                //ואם אחרת אז להוסיף למועדפים
                                Button(pokemon.favorite ? "Remove from favorites" : "Add to Favorites", systemImage: "star") {
                                    //כאן הגדרנו שישלח לתקיית מועדפים את כל מי שהחלקנו
                                    pokemon.favorite.toggle()
                                    //כאן הגדרנו שמירת מועדפים ושיתפוס שגיאה אם יהיה
                                    do{
                                        try viewContext.save()
                                    }catch{
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {//הוספנו עוד חלון הזהרה עם כפתור איך לפתור את הבעיה הפעם בתוך התצוגה בראשית עצמה
                        //אם יש פחות מ151 פוקימונים זה יציג הזהרה ודרך פיתרון
                        if all.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!.\nFetch the rest of the pokemon.")
                            } actions: { Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                getPokemon(from: pokedex.count + 1)//כאן הגדרנו שאחרי שיזהה את הראשון בסדר פשוט יוסיף את שאר הפוקימונים אחד אחרי השני לפי הסדר
                                }
                                .buttonStyle(.borderedProminent)
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
                //כאן הגדרנו שיציג לנו את הסינון
                .onChange(of: filterByFavorites) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                //כאן הגדרנו מה יציג בכל תבנית פוקימון בתוכה
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                 }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { //כאן אנו מגדירים כפתור סינון
                            filterByFavorites.toggle() //מה הכפתור יעשה
                        } label: { //איך הכפתור יראה
                            Label("Filter by favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                            //אם הוא מסונן אז יהיה כוכב מלא ואם לא אז כוכב רגיל
                        }
                        .tint(.yellow)
                    }
                }
            }
            //        .task{ //זה מריץ ישר את הפונקציה שיצרנו ומביא את כל הפוקימונים במקום שנלחץ כל פעם על הפלוס
            //            getPokemon()
            //        }
        }
    }
    //הגדרנו שהפונקציה תתחיל ממספר מזוהה של הפוקימון
    private func getPokemon(from id:Int) {//כאן הגדרנו פונקצייה שתציג לנו פוקימונים
        Task{
            for i in id..<152 {//כאן אנו מריצים 151 פעמים פונקציית פטש כדי שיציג לנו איידי של כל ה151 פוקימונים מהדאטה
                do {//למקרה שתיהיה שגיאה אנו עושים את הפקודה בדו
                    //הפטש פוקימון פה הוא לא אותו הדבר כמו הקובץ שיצרנו
                    //הפטש כאן קשור לפטש סרוויס שיבאנו למעלה
                    //הוא מיבא מהפטש סרוויס את האיידי ששמור בפטש פוקימון
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
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
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                   
                    //זה בדיקה זמנים לראות שאכן הפונקציה של הסינון למועדף עובד
//                    if pokemon.id % 2 == 0 {
//                        pokemon.favorite = true
//                    }
                    
                    //כאן אנו שומרים את כל מה שהגדרנו במסד הנתונים
                    try viewContext.save()
                }catch{
                    print(error)
                }
            }
            //כאן אנו מריצים את הפונקציה שיצרנו למטה שתשמור את כל מה שנוצר עי הקוד למעלה
            storeSprites()
        }
    }
    //הפונקציה הזו נועדה לשמור את כל התמונות של הפוקימונים אחרי שלוחצים פטש
    private func storeSprites() {
        Task {
            do{
                for pokemon in all {//אנחנו מריצים סשיין משותף פונקציית נתונים שמחזירים שלנו תגובה ונתונים אפס אומר לשמור רק את הדבר הראשון שהוא נתונים
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    //זה שורה ששומרת לנו את התוצאה בסופו של דבר
                    try viewContext.save()
                    //שורה זו מריצה את הקוד בטרמינל כדי שנוכל לראות אם היא עובדת
                    print("Sprites stored: \(pokemon.id): \(pokemon.name!.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
