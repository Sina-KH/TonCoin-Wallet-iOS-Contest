import SwiftSignalKit

final class FileBackedStorageImpl {
    private let queue: Queue
    private let path: String
    private var data: Data?
    private var subscribers = Bag<(Data?) -> Void>()
    
    init(queue: Queue, path: String) {
        self.queue = queue
        self.path = path
    }
    
    func get() -> Data? {
        if let data = self.data {
            return data
        } else {
            self.data = try? Data(contentsOf: URL(fileURLWithPath: self.path))
            return self.data
        }
    }
    
    func set(data: Data) {
        self.data = data
        do {
            try data.write(to: URL(fileURLWithPath: self.path), options: .atomic)
        } catch let error {
            print("Error writng data: \(error)")
        }
        for f in self.subscribers.copyItems() {
            f(data)
        }
    }
    
    func watch(_ f: @escaping (Data?) -> Void) -> Disposable {
        f(self.get())
        let index = self.subscribers.add(f)
        let queue = self.queue
        return ActionDisposable { [weak self] in
            queue.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.subscribers.remove(index)
            }
        }
    }
}

final class FileBackedStorage {
    private let queue = Queue()
    private let impl: QueueLocalObject<FileBackedStorageImpl>
    
    init(path: String) {
        let queue = self.queue
        self.impl = QueueLocalObject(queue: queue, generate: {
            return FileBackedStorageImpl(queue: queue, path: path)
        })
    }
    
    func get() -> Signal<Data?, NoError> {
        return Signal { subscriber in
            self.impl.with { impl in
                subscriber.putNext(impl.get())
                subscriber.putCompletion()
            }
            return EmptyDisposable
        }
    }
    
    func set(data: Data) -> Signal<Never, NoError> {
        return Signal { subscriber in
            self.impl.with { impl in
                impl.set(data: data)
                subscriber.putCompletion()
            }
            return EmptyDisposable
        }
    }
    
    func update<T>(_ f: @escaping (Data?) -> (Data, T)) -> Signal<T, NoError> {
        return Signal { subscriber in
            self.impl.with { impl in
                let (data, result) = f(impl.get())
                impl.set(data: data)
                subscriber.putNext(result)
                subscriber.putCompletion()
            }
            return EmptyDisposable
        }
    }
    
    func watch() -> Signal<Data?, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.watch({ data in
                    subscriber.putNext(data)
                }))
            }
            return disposable
        }
    }
}
