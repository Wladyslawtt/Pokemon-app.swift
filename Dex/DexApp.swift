//
//  DexApp.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 08/06/2025.
//

import SwiftUI
import SwiftData

@main
struct DexApp: App {//כאן החלפנו את הקוד בקוד קונטיינר מדאטהסוויפט
    //פשוט יש ליצור פרוייקט חדש עם סוויט דאטה ולהעתיק את הרונטיינר לפה
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pokemon.self,//כאן יש להגדיר את האייתם למסדר הנתונים לשם שלו במקרה שלנו קוראים לו פוקימון
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }//כאן גם העתקנו מפרוייקט עם מסד נתונים סוויפטדאטה
}
