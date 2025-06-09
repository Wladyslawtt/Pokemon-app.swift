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
    
//זה הדבר ששולט לנו בתצוגת הדאטה בייס שלנו
    @MainActor
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
        newPokemon.sprite = URL(string: "http://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shiny = URL(string: "http://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
