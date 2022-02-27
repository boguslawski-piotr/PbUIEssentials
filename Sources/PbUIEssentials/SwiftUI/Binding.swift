/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public extension Binding {
    init<T>(_ data: T, _ keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(get: { data[keyPath: keyPath] }, set: { newValue in data[keyPath: keyPath] = newValue })
    }
    
    init<Key: Hashable>(_ data: Binding<Dictionary<Key, Value>>, key: Key, default value: Value) {
        self.init(get: { data.wrappedValue[key] ?? value },
                  set: { newValue in data.wrappedValue[key] = newValue }
        )
    }
}

// TODO: czy to ma sens?

public protocol Bindable {
    func get<T, Value>(_ keyPath: WritableKeyPath<T, Value>) -> Value
    func set<T, Value>(_ newValue: Value, in keyPath: WritableKeyPath<T, Value>)
}

public extension Binding {
    init<T: Bindable>(_ data: T, _ keyPath: WritableKeyPath<T, Value>) {
        self.init(get: { data.get(keyPath) }, set: { newValue in data.set(newValue, in: keyPath) })
    }
}
