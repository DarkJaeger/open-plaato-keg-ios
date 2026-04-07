import Foundation
import Combine
import UserNotifications

class WebSocketService: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketService()
    private var task: URLSessionWebSocketTask?
    private var session: URLSession?
    var onKegUpdate: ((Keg) -> Void)?
    var onAirlockUpdate: ((Airlock) -> Void)?
    var onTransferScaleUpdate: ((TransferScale) -> Void)?

    private var previousPouringState: [String: Bool] = [:]

    private var baseURL: String {
        UserDefaults.standard.string(forKey: "serverURL") ?? "http://192.168.8.141:8085"
    }

    func connect() {
        disconnect()

        let wsURL = baseURL.replacingOccurrences(of: "http", with: "ws") + "/ws"
        guard let url = URL(string: wsURL) else { return }
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session?.webSocketTask(with: url)
        task?.resume()
        receive()
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
        session?.invalidateAndCancel()
        session = nil
    }

    private func receive() {
        task?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8) {
                    self?.handleMessage(data)
                }
                self?.receive()
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.connect()
                }
            }
        }
    }

    private func handleMessage(_ data: Data) {
        // Handle airlock updates
        if let envelope = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           envelope["type"] as? String == "airlock",
           let innerData = envelope["data"],
           let innerJSON = try? JSONSerialization.data(withJSONObject: innerData),
           let airlock = try? JSONDecoder().decode(Airlock.self, from: innerJSON) {
            DispatchQueue.main.async { self.onAirlockUpdate?(airlock) }
            return
        }
        
        // Handle transfer scale updates
        if let envelope = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           envelope["type"] as? String == "transfer_scale",
           let innerData = envelope["data"],
           let innerJSON = try? JSONSerialization.data(withJSONObject: innerData),
           let scale = try? JSONDecoder().decode(TransferScale.self, from: innerJSON) {
            DispatchQueue.main.async { self.onTransferScaleUpdate?(scale) }
            return
        }

        // Handle keg updates
        if let keg = try? JSONDecoder().decode(Keg.self, from: data) {
            checkPourNotification(keg)
            DispatchQueue.main.async { self.onKegUpdate?(keg) }
        }
    }

    private func checkPourNotification(_ keg: Keg) {
        let wasPouring = previousPouringState[keg.id] ?? false
        let isNowPouring = keg.isPouringBool
        previousPouringState[keg.id] = isNowPouring

        let notifEnabled = UserDefaults.standard.bool(forKey: "pourNotificationsEnabled")
        guard notifEnabled else { return }

        if wasPouring && !isNowPouring, let lp = keg.lastPourDouble, lp > 0 {
            let unit = keg.beerLeftUnit ?? "L"
            let pourStr = String(format: "%.1f %@", lp, unit)
            sendLocalNotification(
                title: "Pour Complete",
                body: "\(keg.name): \(pourStr) poured. \(keg.percentFormatted) remaining."
            )
        }
    }

    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.connect()
        }
    }
}
