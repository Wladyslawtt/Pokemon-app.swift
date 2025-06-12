//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 09/06/2025.
//
//שים לב שכל מה שהגדרת יהיה תואם לקובץ גייסון ולאייפיאי
import Foundation
//זה קוד פיאנוח מהאייפיאיי לאפליקציה
struct FetchedPokemon: Decodable{
    let id: Int16 //זה מה שהגדרנו מהתחלה בדאטה בייס
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL
    //פשוט תרשום איניט וכל זה יופיע לך אחרי זהגדרת סטרוקט
    //שים לב שלא תמיד מה שהגרתה בסטרוקט באמת יפואנח לאפליקציה אז צריך להוסיפ מפתחות
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        //כברירת מחדל התכנה תכנס רק לתקייה הראשונה אבל לפעמים יהיו לנו תת תקיות וכדי להגיד לתכנה שתכנס גם אליהם צריכים להגדיר לה אותם שוב פעם כמו שעשינו פה
        //התכנה תכנס לכל תקייה ובכל תקייה תכנס לקיית תייפ ובכל תייפ תחפש ניים או בייס סטט
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: CodingKey {
            case baseStat
        }
//        אנחנו לא תמיד צריכים לחפש פי השם לפעמים אנחנו יכולים לחפש לפי המידע עצמו כמו שעשינו פה הגדרנו שיחפש תיקיות עם המידע פרונט דיפולט ופרונט שייני
        enum SpriteKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }
    //זהו קוד איתחול שמפענחת אובייקט מגייסון
    init(from decoder: any Decoder) throws {
        //קוד זה אומר לתת גישה לנתוני גייסון כמילון לפי המפתחות שהגדרנו בקודינגקייס
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //קוד זה אומר להוציא מהגייסון את ערך המפתחות איידי ותמיר אותו לאינט16 ותשמור בגוף איידי
        id = try container.decode(Int16.self, forKey: .id)
        //קוד זה אומר להוציא מגייסון את ערך המפתחות שם ולהמיר לאותיות ולשמור בגוף שמות
        name = try container.decode(String.self, forKey: .name)
        //כל זה קשור לטייפס למטה
        //הגדר משתנה בשם דקודד טייפס שהוא מערך של מחרוזות ומהתחל אותו כריק
        //הגדרנו אותו סטרינג כי ככה הוא הוגדר אצלנו בדאטה בייס
        var decodedTypes: [String] = []
        //צור משתנה בשם טייפקונטינר שמפענח מערך לא מקודד אןקייד מתוך שדה בשם טייפס בתוך הנתונים שקיבלנו קונטיינר הפעולה עלולה להיכשל ולכן משתמשים בטריי
        //תוציא מתוך הנתונים שקיבלנו רשימה מערך שנמצאת תחת השם טייפס ותשמור אותה במשתנה שנקרא טייפ קונטיינר
        //בגלל שהטייפס שלנו שאנו צריכים נמצא בתת תקייה אנחנו כותבים את הקוד הזה שיקלוט את כל התקיות בתוכו ויהיה לו גישה אליהם להוציא משהו
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        //הקוד הזה עובר בלולאה על רשימה מערך של אובייקטים מקוננים בכל פעם הוא לוקח את האובייקט הבא בתור ומנסה לפענח אותו לתוך מבנה נתונים שמתנהג כמו מילון דיקשיונרי כדי לאפשר גישה למידע שבתוכו באמצעות מפתחות וכל זה עד הסוף כל עוד יש עוד איברים במערך
        while !typesContainer.isAtEnd {
            //הקוד מופעל בטריי למקרה שתיהיה שגיאה והיא מנסה לגשת למערך הבא בטייפס קונטיינר שהגדרנו למעלה
            // הקיידביי הוא חלק שמספק את מפת הפיאנוח ואומר באיזה מפתחות להשתמש כדי לפאנח את המידע
            // המפתח שרשמנו פה הגדרנו אותו למעלה באנום עם צרור מפתחות מוכן
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            //השורה הזו ממשיכה את תהליך הפענוח דיקודינג מהשורה הקודמת היא שולפת אובייקט מקונן נסטד אובגקט מתוך האובייקט הנוכחי לפי מפתח ספציפי שהגדרנו למפתח קיי
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            //זוהי השורה האחרונה והסופית בתהליך הפענוח של הטייפס היא שולפת ערך ספציפי ובודד כמו טקסט או מספר מתוך האובייקט שבו אנו נמצאים
            let type = try typeContainer.decode(String.self, forKey: .name)
            //בקוד הזה הוא פשוט מוציא את הערך שאנו צריכים מקובץ טייפ בגייסון או אייפיאיי ומוסיפ לדקודד טייפס שהגדרנו למעלה
            decodedTypes.append(type)
        }
        //כאן אנו משווים את הטייפס לנתונים שהוצאו מדיקודד טייפס
        types = decodedTypes
        //הגדרנו סטט כ אינט כמו בדאטה בייס והתחלנו אותו לריק
        //פשוט העתקנו כמו למעלה אבל שינינו לסטט הפעם
        var decodedStats: [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
            
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            decodedStats.append(stat)
        }
        //כאן אנחנו מגדירים לפי הסדר שיש באייפי את כל הסטטס שהוצינו בשורות הקודמות
        hp = decodedStats[0]
        attack = decodedStats[1]
        defense = decodedStats[2]
        specialAttack = decodedStats[3]
        specialDefense = decodedStats[4]
        speed = decodedStats[5]
        //השורה הזו מפענחת בעזרת המפתחות שיצרנו למעלה את המידע של סריטס
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        //פה זה מפאנח את הפיאנוח מהשורה הקודמת ומתאים את המידע אליו
        sprite = try spriteContainer.decode(URL.self, forKey: .sprite)
        shiny = try spriteContainer.decode(URL.self, forKey: .shiny)
    }
}
