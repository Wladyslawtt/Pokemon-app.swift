//
//  ContentView.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    //זה נותן לנו גישה דאטה מודל שלנו בסוויפט דאטה העתקנו מקובץ שיצרנו על בוויפט דאטה
    @Environment(\.modelContext) private var modelContext
    //זה תחליף לפטש ריקווסט אול שגם העתקנו
    //השורה הזאת יוצרת משתנה פרטי פוקידקס שמכיל את כל הפוקימונים מהמיון לפי האיידי עם אנימצית ברירת מחדל שנמשכו מהדאטהבייס בצורה אוטומטית
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    //כאן יבאנו סרגל חיפוש
    @State private var searchText = ""
    //כאן הגדרנו סינון לפי אהובים כברירת מחדל הוא כבוי
    @State private var filterByFavorites = false
    //כאן יבאנו את קובץ הפטש סקוויס
    let fetcher = FetchService()
    
    //כאן אנו מגדירים את החיפוש עצמו בשם דינמיק פרדיקייט
    private var dynamicPredicate: Predicate<Pokemon> {
    #Predicate<Pokemon> { pokemon in
        //אם סינון לפי מועדפים וטקסט פעיל
        if filterByFavorites && !searchText.isEmpty {
            //אז יש לסנן לפי מועדף לפי החיפוש
            pokemon.favorite && pokemon.name.localizedStandardContains(searchText)
        //אם לא פעיל השורת חיפוש
        } else if !searchText.isEmpty {
            //תציג רק שורת חיפוש
            pokemon.name.localizedStandardContains(searchText)
        //אם לא פעיל הסינון
        } else if filterByFavorites {
            //תציג רק מועדפים
            pokemon.favorite
        //אם שום דבר מכל זה
        } else {
            //אז תציג את הכל
            true
        }
    }
}

    var body: some View {//האיף מריצה ישר את כל הפוקימונים ומוסיפה חלון הוראות מה לעדות אם לא יוצג כלום
        if pokedex.isEmpty {//למקרה שהמסך יהיה ריק שתופיע הודע מה לעשות
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
                        //הגדרנו שינסה לסנן את הפוקימונים לפי תנאי דינמי כמו חיפוש או סינון ואם זה לא מצליח  שיציג את כל הפוקימונים כמו שהם
                        ForEach((try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
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
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        //כאן הגדרנו ליד כל מועדף תהיה כוכבית
                                        if pokemon.favorite{
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    
                                    HStack{//כאן הגדרנו שיציג את הסוג של כל פוקימון
                                        ForEach(pokemon.types, id: \.self) { type in
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
                                        try modelContext.save()
                                    }catch{
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {//הוספנו עוד חלון הזהרה עם כפתור איך לפתור את הבעיה הפעם בתוך התצוגה בראשית עצמה
                        //אם יש פחות מ151 פוקימונים זה יציג הזהרה ודרך פיתרון
                        if pokedex.count < 151 {
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
                //כאן הדרנו אנימציה שיסנן יותר חלק
                .animation(.default, value: searchText)
                //כאן הגדרנו מה יציג בכל תבנית פוקימון בתוכה
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail(pokemon: pokemon)
                 }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { //כאן אנו מגדירים כפתור סינון
                            withAnimation {//הגדרנו אנימציה בעת הסינון
                                filterByFavorites.toggle() //מה הכפתור יעשה
                            }
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
                    //השורה מוסיפה את הפוקימון מהפטשריקווסט לתוך הדאטהבייס של האפליקציה
                    modelContext.insert(fetchedPokemon)
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
                for pokemon in pokedex {//אנחנו מריצים סשיין משותף פונקציית נתונים שמחזירים לנו תגובה ונתונים אפס אומר לשמור רק את הדבר הראשון שהוא נתונים
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    //זה שורה ששומרת לנו את התוצאה בסופו של דבר
                    try modelContext.save()
                    //שורה זו מריצה את הקוד בטרמינל כדי שנוכל לראות אם היא עובדת
                    print("Sprites stored: \(pokemon.id): \(pokemon.name.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
}



#Preview {
    ContentView().modelContainer( PersistenceController.preview)
}
