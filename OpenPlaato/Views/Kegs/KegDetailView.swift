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
                if let amount = keg.amountLeft {
                    LabeledContent("Amount Left", value: "\(amount) L")
                }
                LabeledContent("Pouring", value: keg.isPouringBool ? "Yes" : "No")
                if let lastPour = keg.lastPourString {
                    LabeledContent("Last Pour", value: lastPour)
                }
            }

            if let beer = beer {
                Section("Beer") {
                    LabeledContent("Name", value: beer.name)
                    if let style = beer.style { LabeledContent("Style", value: style) }
                    if !beer.abvFormatted.isEmpty { LabeledContent("ABV", value: beer.abvFormatted) }
                    if !beer.ibuFormatted.isEmpty { LabeledContent("IBU", value: beer.ibuFormatted) }
                }
            }
        }
        .navigationTitle(keg.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
