import SwiftUI

struct SettingsView: View {
    @AppStorage("serverURL") private var serverURL = "http://192.168.8.141:8085"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("Server URL", text: $serverURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    Button("Reconnect") {
                        WebSocketService.shared.disconnect()
                        WebSocketService.shared.connect()
                        Task { await appState.loadAll() }
                    }
                }

                Section("Notifications") {
                    Toggle("Keg Running Low", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { enabled in
                            if enabled { requestNotificationPermission() }
                        }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Server", value: serverURL)
                    Link("GitHub", destination: URL(string: "https://github.com/DarkJaeger/open-plaato-keg-ios")!)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}
