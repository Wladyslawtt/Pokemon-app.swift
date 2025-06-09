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
        //התכנה תכנס לכל תקייה ובכל תקייה תכנס לקיית תייפ ובכל תייפ תחפש ניים
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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([String].self, forKey: .types)
        self.hp = try container.decode(Int16.self, forKey: .hp)
        self.attack = try container.decode(Int16.self, forKey: .attack)
        self.defense = try container.decode(Int16.self, forKey: .defense)
        self.specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
        self.specialDefense = try container.decode(Int16.self, forKey: .specialDefense)
        self.speed = try container.decode(Int16.self, forKey: .speed)
        self.sprite = try container.decode(URL.self, forKey: .sprite)
        self.shiny = try container.decode(URL.self, forKey: .shiny)
    }
}
