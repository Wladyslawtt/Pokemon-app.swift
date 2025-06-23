//
//  Pokemon.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 23/06/2025.
//
//
//שים לב שכל מה שהגדרת יהיה תואם לקובץ גייסון ולאייפיאי
import Foundation
import SwiftData
import SwiftUI
//זה קוד פיאנוח מהאייפיאיי לאפליקציה
//זה הקור דאטה שלנו אחרי שהעברנו אותו לפרוטוקול סוויפט דאטה
@Model
class Pokemon: Decodable {
    @Attribute(.unique) var id: Int
    var name: String
    var types: [String]
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    var spriteURL: URL
    var shinyURL: URL
    var shiny: Data?
    var sprite: Data?
    var favorite: Bool = false
    
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
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
        }
    }
    //זהו קוד איתחול שמפענחת אובייקט מגייסון
    required init(from decoder: any Decoder) throws {
        //קוד זה אומר לתת גישה לנתוני גייסון כמילון לפי המפתחות שהגדרנו בקודינגקייס
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //קוד זה אומר להוציא מהגייסון את ערך המפתחות איידי ותמיר אותו לאינט16 ותשמור בגוף איידי
        id = try container.decode(Int.self, forKey: .id)
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
        //הסימן הכפול אחרי השתיים אומר גם
        //הגדרנו במערך דקודד קאונט אם יש שני סוגים והראשון ובין שני הסוגים הוא גם נורמלי אז כנס והחלף בינהם
        if decodedTypes.count == 2 && decodedTypes [0] == "normal" {
            //כאן הגרנו טמפ טייפס ובתוכו שישמור את התוצאה הראשונה במערך דיקודד טייפס
//            let tempType = decodedTypes[0]
            //כאן בגדרנו שהתוצאה הראשונה היא בעצם תיהיה התוצאה השנייה
//            decodedTypes[0] = decodedTypes[1]
            //וכאן בעצם הגדרנו שישתמש בתוצאה ששמרנו בטמפ טייפס וישים בתוצאה השנייה ובעצם כך מחליף בין תוצאה ראשונה לשנייה
//            decodedTypes[1] = tempType
            
            //אפשרות שנייה להחליף בין משתנים
            decodedTypes.swapAt(0, 1)
        }
        //כאן אנו משווים את הטייפס לנתונים שהוצאו מדיקודד טייפס
        types = decodedTypes
        //הגדרנו סטט כ אינט כמו בדאטה בייס והתחלנו אותו לריק
        //פשוט העתקנו כמו למעלה אבל שינינו לסטט הפעם
        var decodedStats: [Int] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
            
            let stat = try statsDictionaryContainer.decode(Int.self, forKey: .baseStat)
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
        spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
    }
    
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
        //כאן הגדרנו שיקח כל סוג ראשון של פוקימון ויגדיר את הרקע שלו עפי הסוג שלו
        switch types[0] {
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
        Color(types[0].capitalized)
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
    
    //כאן אנו מגדירים את כל התכונות שיופיעו בכל כרטיס של פוקימון תחת השם סטט
    //הגדרנו את הנתונים פה ככה שיהיו תואמים לאיך שהם מוגרים בקור דאטה והדאטה בייס
    struct Stat: Identifiable {
        let id: Int
        let name: String
        let value: Int
    }
}
