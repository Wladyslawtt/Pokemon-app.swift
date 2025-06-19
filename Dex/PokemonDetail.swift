//
//  PokemonDetail.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 16/06/2025.
//

import SwiftUI

struct PokemonDetail: View {
    //זה נותן לנו גישה לדאטה בייס מנגר
    @Environment(\.managedObjectContext) private var viewContext
    //השורה הזו אומרת שפוקימון הוא אובייקט משותף לסביבה שמוזרק מבחוץ לתוך התצוגה והוא מסוג פוקימון
    //כשאתה רוצה שוויו כלשהו יקבל גישה לאובייקט שמשותף לכלל האפליקציה למשל מודל נתונים בלי להעביר אותו ידנית דרך כל ווי מוסיפים שורה כזאת
    //אווירמנט אובגקט זו תכונה פרופרטי ווראפט שמשמשת בסוויפט כדי למשוך אובייקט מתוך הסביבה של האפליקציה כלומר מדובר באובייקט שמשותף בין כמה תצוגות ונטען מבחוץ
    //פריבט ואר פוקימון מגדיר משתנה פרטי בשם פוקימון
    //פוקימון נקודותיים פוקימון מציין שהטיפוס של המשתנה הוא פוקימון כלומר מדובר באובייקט מסוג פוקימון מהדאטהבייס
    @EnvironmentObject private var pokemon: Pokemon
    
    @State private var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                //כאן יבאנו את הרקע שהגדרנו בקובץ פורימוןאקס
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                //כאן יבאנו את התמונה של הפוקימון
                //אפשר לראת אותו בסימולטור בוויו בצד אי אפשר כי משהו שבור פה אחי אבל בעיקרון יש תמונה פשוט לא רואים
                //אם שייני פעיל התמונה תהיה במצב שייני ואם לא אז רגילה
                //שייני זה מצב שהופך את הצבע של הפוקימון
                AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
            HStack {//הבאנו על כל פוקימון לפי האיידי היחודי שלו שיהיה רשום מתחת לתמונה את הסוג שלו
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                }
                
                Spacer()
                
                Button {
                    pokemon.favorite.toggle()//הפכנו את המועדפים ללחיצים
                    //הגדרנו שישמור את המועדפים ויזרוק שגיאה אם יהיה
                    do {
                        try viewContext.save()
                    }catch{
                        print(error)
                    }
                } label: {//אם המוקימון מועדף הכוכב יהיה מלא אם לא הכוכב יהיה ריק
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            
            //כאן יבאנו את הסטטס מהקובץ סטטס
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {//מוסיף סרגל כלים
            ToolbarItem(placement: .topBarTrailing) {//מוסיף כפתור למעלה בצד ימין
                Button {//מפעל כפתור שייני
                    showShiny.toggle()
                } label: {//אם הוא פעיל אז הכפתור יהיה מלא ואם לא אז ריק
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .tint(showShiny ? .yellow : .primary)//אם פעיל הוא יהיה צהוב ואם לא אז רגיל
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)//מוציא לנו לפרוויו פוקימון אחד כפי שהגדרנו בקובץ פרסיסטנס
    }
}
