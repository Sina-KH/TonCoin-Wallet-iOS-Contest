//
//  Created by Anton Spivak
//

import Foundation

/// SImple wrapper around NSNotificationCenter for strict types
public final class AnnouncementCenter {
    
    private let center = NotificationCenter()
    
    fileprivate init() {}
    
    public func post<T>(
        announcement: T.Type,
        with content: T.AnnouncementContent
    ) where T: Announcement {
        center.post(
            name: .init(rawValue: String(describing: announcement)),
            object: nil,
            userInfo: [
                "value" : content
            ]
        )
    }
    
    @discardableResult
    public func observe<T>(
        of announcement: T.Type,
        on queue: OperationQueue? = .main,
        using block: @escaping (T.AnnouncementContent) -> Void
    ) -> NSObjectProtocol where T: Announcement {
        center.addObserver(
            forName: .init(rawValue: String(describing: announcement)),
            object: nil,
            queue: queue,
            using: { notification in
                guard let content = notification.userInfo?["value"] as? T.AnnouncementContent
                else {
                    return
                }
                
                block(content)
            }
        )
    }
    
    public func removeObserver(_ observer: NSObjectProtocol) {
        center.removeObserver(observer)
    }
}

public extension AnnouncementCenter {
    
    static let shared = AnnouncementCenter()
}
