//
//  Created by Anton Spivak
//

import Foundation

public struct AnnouncementSynchronization: Announcement {
 
    public typealias AnnouncementContent = Content
    
    public struct Content {
        
        public let progress: Double
        
        internal init(progress: Double) {
            self.progress = progress
        }
    }
}
