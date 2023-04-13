import SwiftSignalKit

class Downloader {
    enum DownloadFileError {
        case network
    }
    
    private static let urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        return session
    }()
    
    static func download(url: URL) -> Signal<Data, DownloadFileError> {
        return Signal { subscriber in
            let completed = Atomic<Bool>(value: false)
            let downloadTask = urlSession.downloadTask(with: url, completionHandler: { location, _, error in
                let _ = completed.swap(true)
                if let location = location, let data = try? Data(contentsOf: location) {
                    subscriber.putNext(data)
                    subscriber.putCompletion()
                } else {
                    subscriber.putError(.network)
                }
            })
            downloadTask.resume()
            
            return ActionDisposable {
                if !completed.with({ $0 }) {
                    downloadTask.cancel()
                }
            }
        }
    }
}
