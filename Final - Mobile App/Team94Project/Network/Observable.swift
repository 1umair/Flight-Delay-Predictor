
import Foundation

class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }

    var valueChanged: ((T) -> Void)?

    init(value: T) {
        self.value = value

    }
}
