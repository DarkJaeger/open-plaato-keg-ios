import SwiftUI

struct KegDetailView: View {
    @EnvironmentObject var appState: AppState
    let keg: Keg

    var beer: Beer? { appState.beer(for: keg) }

    var body: some View {
        List {
            Section("Status") {
                LabeledContent("Level", value: keg.percentFormatted)
                LabeledContent("Temperature", value: keg.tempFormatted)
                if let liters = keg.litersRemaining {
                    LabeledContent("Remaining", value: String(format: "%.2f L", liters))
                }
                LabeledContent("Pouring", value: keg.isPouringBool ? "Yes" : "No")
            }

            if let beer = beer {
                Section("Beer") {
                    LabeledContent("Name", value: beer.name)
                    if let style = beer.style { LabeledContent("Style", value: style) }
                    if let abv = beer.abv { LabeledContent("ABV", value: String(format: "%.1f%%", abv)) }
                    if let ibu = beer.ibu { LabeledContent("IBU", value: "\(ibu)") }
                }
            }
        }
        .navigationTitle(keg.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
