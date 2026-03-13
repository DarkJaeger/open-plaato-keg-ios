import Foundation
import Combine

class WebSocketService: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketService()
    private var task: URLSessionWebSocketTask?
    private var session: URLSession?
    var onKegUpdate: ((Keg) -> Void)?

    private var baseURL: String {
        UserDefaults.standard.string(forKey: "serverURL") ?? "http://192.168.8.141:8085"
    }

    func connect() {
        let wsURL = baseURL.replacingOccurrences(of: "http", with: "ws") + "/ws"
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session?.webSocketTask(with: URL(string: wsURL)!)
        task?.resume()
        receive()
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
    }

    private func receive() {
        task?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8),
                   let keg = try? JSONDecoder().decode(Keg.self, from: data) {
                    DispatchQueue.main.async {
                        self?.onKegUpdate?(keg)
                    }
                }
                self?.receive()
            case .failure:
                // Auto-reconnect after 3s
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.connect()
                }
            }
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.connect()
        }
    }
}
