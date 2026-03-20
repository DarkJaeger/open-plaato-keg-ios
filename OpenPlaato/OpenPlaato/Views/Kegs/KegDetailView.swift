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
                LabeledContent("Amount Left", value: keg.amountFormatted)
                LabeledContent("Pouring", value: keg.isPouringBool ? "Yes" : "No")
                if let lastPour = keg.lastPourString, !lastPour.isEmpty {
                    LabeledContent("Last Pour", value: lastPour)
                }
            }

            if keg.myOg != nil || keg.myFg != nil || keg.myAbv != nil || keg.myKegDate != nil {
                Section("Beer Info") {
                    if let style = keg.myBeerStyle, !style.isEmpty {
                        LabeledContent("Style", value: style)
                    }
                    if let og = keg.myOg, !og.isEmpty {
                        LabeledContent("OG", value: og)
                    }
                    if let fg = keg.myFg, !fg.isEmpty {
                        LabeledContent("FG", value: fg)
                    }
                    if let abv = keg.myAbv, !abv.isEmpty {
                        LabeledContent("ABV", value: "\(abv)%")
                    }
                    if let date = keg.myKegDate, !date.isEmpty {
                        LabeledContent("Keg Date", value: date)
                    }
                }
            }

            if let beer = beer {
                Section("Beverage") {
                    LabeledContent("Name", value: beer.name)
                    if let style = beer.style, !style.isEmpty { LabeledContent("Style", value: style) }
                    if !beer.abvFormatted.isEmpty { LabeledContent("ABV", value: beer.abvFormatted) }
                    if !beer.ibuFormatted.isEmpty { LabeledContent("IBU", value: beer.ibuFormatted) }
                }
            }

            if keg.firmwareVersion != nil || keg.wifiSignalStrength != nil {
                Section("Device") {
                    if let fw = keg.firmwareVersion, !fw.isEmpty {
                        LabeledContent("Firmware", value: fw)
                    }
                    if let wifi = keg.wifiSignalStrength, !wifi.isEmpty {
                        LabeledContent("WiFi Signal", value: "\(wifi)%")
                    }
                }
            }
        }
        .navigationTitle(keg.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: KegConfigView(keg: keg)) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}
