//
//  Stats.swift
//  Dex
//
//  Created by Vladyslav Tarabunin on 18/06/2025.
//

import SwiftUI
import Charts

struct Stats: View {
    //כאן הבאנו את האובייקט המשותף בכל התצוגות שהוא פוקימון מהדאטה בייס שהגדרנו
    var pokemon: Pokemon
    
    var body: some View {//כאן אנו יוצרים תרשים מנתונים של פוקימון סטטס בצורת גרף עמודות
        Chart(pokemon.stats) { stat in
            BarMark(x: .value("Value", stat.value),
                    y: .value("Stat", stat.name))
            //כאן אנו מוסיפים מספר ליד כל עמודה
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, -5)
            }
        }
        .frame(height: 200)
        .padding([.horizontal, .bottom])
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value+10)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
