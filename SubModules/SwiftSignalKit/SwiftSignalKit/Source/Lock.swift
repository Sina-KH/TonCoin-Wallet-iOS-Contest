import Foundation

public final class Lock {
    private var mutex = pthread_mutex_t()
    
    public init() {
        pthread_mutex_init(&self.mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&self.mutex)
    }
    
    public func locked(_ f: () -> ()) {
        pthread_mutex_lock(&self.mutex)
        f()
        pthread_mutex_unlock(&self.mutex)
    }
}
