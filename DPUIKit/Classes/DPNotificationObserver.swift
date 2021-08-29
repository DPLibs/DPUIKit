import Foundation
import Combine

open class DPNotificationObserver: NSObject {
    
    // MARK: - Static
    public struct Observer {
        public let notificationName: Notification.Name
        public var handler: (Notification) -> Void
        
        public static func notification(_ name: Notification.Name, handler: @escaping (Notification) -> Void) -> Self {
            .init(notificationName: name, handler: handler)
        }
    }
    
    // MARK: - Props
    public let notificationCenter: NotificationCenter
    open private(set) var observers: [Observer] = []
    
    // MARK: - Init
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    public override init() {
        self.notificationCenter = .default
        
        super.init()
    }
    
    open func observe(_ observers: Observer...) {
        observers.forEach({ observer in
            observers.forEach { observer in
                self.notificationCenter.addObserver(
                    self,
                    selector: #selector(self.handleNotification(_:)),
                    name: observer.notificationName,
                    object: nil
                )
            }
        })
    }
    
    @objc
    open func handleNotification(_ notification: Notification) {
        self.observers.forEach { observer in
            guard observer.notificationName == notification.name else { return }
            
            observer.handler(notification)
        }
    }
    
}
