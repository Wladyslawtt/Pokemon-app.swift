//
//  DexWidget.swift
//  DexWidget
//
//  Created by Vladyslav Tarabunin on 20/06/2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    //כאן החלפנו את הקוד בקוד קונטיינר מדאטהסוויפט
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
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry =  SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            var entries: [SimpleEntry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            
            if let results = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Pokemon>()) {
                for hourOffset in 0 ..< 10 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * 5, to: currentDate)!
                    
                    let entryPokemon = results.randomElement()!
                    
                    let entry = SimpleEntry(date: entryDate, name: entryPokemon.name, types: entryPokemon.types, sprite: entryPokemon.spriteImage)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } else {
                let timeline = Timeline(entries: [SimpleEntry.placeholder, SimpleEntry.placeholder2], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types: [String]
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(date: .now, name: "bulbasaur", types: ["grass","poison"], sprite: Image(.bulbasaur))
    }
    
    static var placeholder2 : SimpleEntry {
        SimpleEntry(date: .now, name: "mew", types: ["psychic"], sprite: Image(.mew))
    }
}

struct DexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    
    var entry: Provider.Entry

    var pokemonImage: some View {
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(color: .black ,radius: 6)
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) {type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(Color(type.capitalized))
                .clipShape(.capsule)
                .shadow(radius: 3)
        }
    }
    
    var body: some View {
        switch widgetSize {
        case .systemMedium:
            HStack {
                pokemonImage
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.title)
                        .padding(.vertical, 1   )
                    
                    HStack{
                        typesView
                    }
                }
                .layoutPriority(1)
                
                Spacer()
            }
        case .systemLarge:
            ZStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        typesView
                    }
                }
            }
        default:
            pokemonImage
        }
    }
}

struct DexWidget: Widget {
    let kind: String = "DexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DexWidgetEntryView(entry: entry)
                    .foregroundStyle(.black)
                    .containerBackground(Color(entry.types[0].capitalized), for: .widget)
            } else {
                DexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("See a random pokemon.")
    }
}

#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
