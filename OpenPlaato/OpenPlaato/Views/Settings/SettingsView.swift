import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("serverURL") private var serverURL = "http://192.168.8.141:8085"
    @AppStorage("pourNotificationsEnabled") private var pourNotificationsEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @EnvironmentObject var appState: AppState

    @State private var urlText = ""
    @State private var airlockEnabled = false
    @State private var brewfatherConfigured = false
    @State private var bfUserId = ""
    @State private var bfApiKey = ""
    @State private var isSavingBF = false
    @State private var showBatches = false
    @State private var alertMsg: String?
    @State private var showAlert = false
    @State private var configLoaded = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("Server URL", text: $urlText)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    Button("Reconnect") {
                        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, URL(string: trimmed) != nil else { return }
                        serverURL = trimmed
                        WebSocketService.shared.disconnect()
                        WebSocketService.shared.connect()
                        Task { await appState.loadAll() }
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Notifications") {
                    Toggle("Pour Notifications", isOn: $pourNotificationsEnabled)
                        .onChange(of: pourNotificationsEnabled) { enabled in
                            if enabled { requestNotificationPermission() }
                        }
                    Toggle("Keg Running Low", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { enabled in
                            if enabled { requestNotificationPermission() }
                        }
                }

                Section("App Config") {
                    Toggle("Airlock Support", isOn: $airlockEnabled)
                        .onChange(of: airlockEnabled) { enabled in
                            Task {
                                do { try await APIService.shared.setAirlockEnabled(enabled) }
                                catch {
                                    alertMsg = error.localizedDescription
                                    showAlert = true
                                }
                            }
                        }

                    NavigationLink("Rearrange Tab Bar") {
                        TabOrderView()
                            .environmentObject(appState)
                    }
                }

                Section("Brewfather") {
                    if brewfatherConfigured {
                        Label("Credentials configured", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    TextField("User ID", text: $bfUserId)
                        .autocapitalization(.none)
                    SecureField("API Key", text: $bfApiKey)
                    Button(isSavingBF ? "Saving..." : "Save Credentials") {
                        saveBrewfatherCreds()
                    }
                    .disabled(bfUserId.isEmpty || bfApiKey.isEmpty || isSavingBF)

                    if brewfatherConfigured {
                        Button("Browse Batches") { showBatches = true }
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Server", value: serverURL)
                    Link("GitHub", destination: URL(string: "https://github.com/DarkJaeger/open-plaato-keg-ios")!)
                }
            }
            .navigationTitle("Settings")
            .onAppear { urlText = serverURL }
            .task { await loadConfig() }
            .sheet(isPresented: $showBatches) {
                BrewfatherBatchListView()
                    .environmentObject(appState)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") {}
            } message: { Text(alertMsg ?? "") }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func loadConfig() async {
        guard !configLoaded else { return }
        do {
            let config = try await APIService.shared.fetchAppConfig()
            airlockEnabled = config.airlockEnabled
            let bfConfig = try await APIService.shared.fetchBrewfatherConfig()
            brewfatherConfigured = bfConfig.configured
        } catch {}
        configLoaded = true
    }

    private func saveBrewfatherCreds() {
        isSavingBF = true
        Task {
            do {
                try await APIService.shared.saveBrewfatherCreds(userId: bfUserId, apiKey: bfApiKey)
                brewfatherConfigured = true
            } catch {
                alertMsg = error.localizedDescription
                showAlert = true
            }
            isSavingBF = false
        }
    }
}
