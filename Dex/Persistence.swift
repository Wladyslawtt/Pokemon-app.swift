//
//  Persistence.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import SwiftData
import Foundation

@MainActor //כאן הגדרנו שהקובץ פה יהיה קשור לוויו הראשי
struct PersistenceController {
//הפונקציה פרוויו פוקימון מחזירה פוקימון אחד לדוגמה מתוך הדאטהסייס כדי שאפשר יהיה להשתמש בו בתצוגות פרוויוס בלי לטעון נתונים אמיתיים מהאפליקציה
    static var previewPokemon: Pokemon {//מגדיר משתנה סטטי בשם פרוויו פוקימון שמחזיר פוקימון
        let decoder = JSONDecoder()
        // יוצרים מופע של JSONDecoder – מחלקה שאחראית לפענח נתוני JSON לאובייקטים בסוויפט

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // מגדירים לדקודר להשתמש באסטרטגיית המרה: במקום מפתחות בפורמט snake_case (כמו "base_experience")
        // הוא יתאים אותם אוטומטית לשמות במבנה שלנו שכתובים ב-camelCase (כמו "baseExperience")

        let pokemonData = try! Data(contentsOf: Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!)
        // טוענים את קובץ ה-JSON בשם "samplepokemon.json" מתוך קבצי הפרויקט (Bundle ראשי)
        // וממירים אותו לאובייקט מסוג Data – כלומר נתונים בינאריים של הקובץ

        let pokemon = try! decoder.decode(Pokemon.self, from: pokemonData)
        // מפענחים את נתוני ה-JSON לאובייקט מסוג Pokemon באמצעות ה-decoder

        return pokemon
    }
    
//זה הדבר ששולט לנו בתצוגת הדאטה בייס שלנו הלדוגמא של התצוגה המקדימה שלנו
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        // יוצרים מיכל נתונים (ModelContainer) עבור המודל Pokemon, עם הגדרה שהנתונים יישמרו רק בזיכרון (ולא בדיסק)

        container.mainContext.insert(previewPokemon)
        // מוסיפים את אובייקט ה-preview (פוקימון לדוגמה) לקונטקסט הראשי של המיכל

        return container
        // מחזירים את המיכל שנוצר

    }()

}
