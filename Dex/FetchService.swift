//
//  FetchService.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 11/06/2025.
//

import Foundation

@MainActor

//פה אנו מפאנחים מידע מהאינטרנט
struct FetchService {
    //למקרה שלא יוכל לפאנח שישלח שגיאה
    enum FetchError: Error {
        case badResponse
    }
    //כאן אנו מגדירים מאיזה אתר הוא יפאנח את המידע
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
//זו פונקציה אסינכרונית שמטרתה להביא מידע על פוקימון לפי מזהה איידי שמחזיר אובייקט מגוף שהגדרנו בפוקימון
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
//השורה הזו יוצרת כתובת יוראל חדשה פטש יואראל על בסיס כתובת קיימת בייס יו אראל ומוסיפה לה נתיב נוסף במקרה הזה מספר האיידי של הפוקימון
//פאס סטרינג לוקח את המספר של הפוקימון ממיר אותו לסוג של אות ומוסיפ לסוף של הכתובת אינטרנט כדי לגשת אליו
        let fetchURL = baseURL.appending(path: String(id))
//השורה שולחת בקשת רשת  לכתובת פטשיואראל ומחכה לתשובה בסוג של דאטה תוכן או פרטי תגובה סטטוס או קוד
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
//היא בודקת שהתשובה מהשרת תקינה קוד סטטוס מאתיים שווה הצלחה אם לא היא זורקת שגיאה
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        //פה הגדרנו פאנוח גייסון
        let decoder = JSONDecoder()
        //ופה הגדרנו לפאנח הכל לסטנדרט סנייק קייס
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        //היא מפענחת את הנתונים שהגיעו מהשרת דאטה למבנה סטרוקט בשם פוקימון
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        //פה הגדרנו שיציג בטרמינל את הפוקימונים
        print("Fetched pokemon: \(pokemon.id): \(pokemon.name.capitalized)")
        //ופה הגדרנו שיוציא לנו את מה שפיאנחנו
        return pokemon
    }
}
