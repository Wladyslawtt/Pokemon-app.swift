//
//  Persistence.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import CoreData

struct PersistenceController {
// זה הדבר ששולט לנו בדאטה בייס
    static let shared = PersistenceController()
//הפונקציה פרוויו פוקימון מחזירה פוקימון אחד לדוגמה מתוך הדאטהסייס כדי שאפשר יהיה להשתמש בו בתצוגות פרוויוס בלי לטעון נתונים אמיתיים מהאפליקציה
    static var previewPokemon: Pokemon {//מגדיר משתנה סטטי בשם פרוויו פוקימון שמחזיר פוקימון
        //יוצרים משתנה קונטקסט שמיבא את הקונטקסט מהדאטהבייס לפרוויו
        //פרסיסטקונטרולר פרוויו זו גרסה מיוחדת של הדאטה בייס לפריוויו בלבד
        let context = PersistenceController.preview.container.viewContext
        //יוצר בקשת שליפה פטש מסוג פוקימון כלומר בקשה לקרוא אובייקטים מסוג פוקימון מהדאטהבייס
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        //מגביל את הבקשה שישלוף רק פורימון אחד במקום את כולם
        fetchRequest.fetchLimit = 1
        //יצרנו משתנה שיביא לנו את התוצאה
        //המשתנה מנסה להוציא את התוצאה על קונטקסט ויבצע את שליפת הנתונים שהגדרנו למעלה
        let results = try! context.fetch(fetchRequest)
        //מחזיר לי את התוצאה עם פוקימון אחד כפי שהגדרנו
        return results.first!
    }
    
//זה הדבר ששולט לנו בתצוגת הדאטה בייס שלנו
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 1
        newPokemon.name = "bulbasaur"
        newPokemon.types = ["grass", "poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shinyURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()
//קונטיינר זה הדבר ששומר לנו על המידע שאנו שמים בתוכו
    let container: NSPersistentContainer
//איניט זה פעולה שרצה אוטומטית כשהפרסיסטנס בקיצור בקר התמדה שלנו מאותחל כל פעם
//איניט זה איתחול והוא מאתחל אטומטית את האפליקצייה ומריץ את הקוד שרשמנו בתוכו
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        //זהו קוד ששומר לנו את המידע שהוספנו בדאטה בייס
        //בעיקרון אם יש כפולויות הוא מחבר אותן עם המידע שקיים כבר בדאטה בייס ןאם אין כפוליות הוא פשוט שומר אותן מחדש בדאטה בייס
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
