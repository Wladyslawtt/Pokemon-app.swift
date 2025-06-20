//
//  PokemonExt.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 17/06/2025.
//

import SwiftUI
//הגדרנו תוסף לאובייקט פוקימון
extension Pokemon {
    //שני הקודים האלו אמורים לתת לנו להשתמש בתמונות שנשמרות לנו בטלפון
    //כאן אנו הגדרנו קומפיוטט פרופרטי בשם ספרייט אימג שמחזיר תמונה
    var spriteImage: Image {
        //בודק אם יש נתונים בתוך הספרייט ומנסה ליצור מהנתונים תמונה שתשמר בנתון אימג
        if let data = sprite, let image = UIImage(data: data) {
            //הוא אמור להחזיר תמונה שנוצרה מהנתונים
            Image(uiImage: image)
        } else {
            //אם לא אז הוא אמור להחזיר את אחת התמונות מהמאגר
            Image(.bulbasaur)
        }
    }
    //כאן הגדרנו משתנה שייני שאמור להחזיר תמונה של שייני
    var shinyImage: Image {
        //אם הוא מוצא במאגר של שייני נתונים הוא אמור ליצור מהם תמונה ולשמור בנתון אימג
        if let data = shiny, let image = UIImage(data: data) {
                //הוא אמור להחזיר תמונה שנוצרה מהנתונים
                Image(uiImage: image)
        } else {
            //אם לא אז הוא אמור להחזיר את אחת התמונות מהמאגר
            Image(.shinybulbasaur)
        }
    }
    //כאן הגדרנו שנתון רקע יחזיר תמונה כלשהי
    var background: ImageResource {
        //כאן הגרנו שיקח כל סוג ראשון של פוקימון ויגדיר את הרקע שלו עפי הסוג שלו
        switch types![0] {
            //לדוגמא אם אחד מהם הוא גלע הוא משהו דוה הוא יגדיר רקע של סלע
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
            //אם לא נמצא שום סוג לפוקמון אז יגדיר רקע מברירת מחדל
        default:
                .normalgrasselectricpoisonfairy
            }
    }
    //כאן הגדרנו משתנה שיחזיר צבע
    var typeColor: Color {
        //כאן הגדרנו על כל סוג ראשון של פוקימון להוסיף את הצבע שלו
        Color(types![0].capitalized)
    }
    //כאן הגדרנו את המשתנה שיצרנו למטה שיופיע לנו בכרטיסיה
    var stats: [Stat] {
        [//כאן הוספנו את השלד של הסטט שיצרנו למטה ונגדיר את את הנתנונים שאנו רוצים לראות בכרטיסיה
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    //זה מחזיר את הסטטיסטיקה הכי גבוהה של הפוקימון מתוך המערך סטט
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
}
//כאן אנו מגדירים את כל התכונות שיופיעו בכל כרטיס של פוקימון תחת השם סטט
//הגדרנו את הנתונים פה ככה שיהיו תואמים לאיך שהם מוגרים בקור דאטה והדאטה בייס
struct Stat: Identifiable {
    let id: Int
    let name: String
    let value: Int16
}
