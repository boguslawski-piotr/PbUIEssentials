/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public extension Binding {
    init<T>(_ data: T, _ keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(get: { data[keyPath: keyPath] }, set: { newValue in data[keyPath: keyPath] = newValue })
    }
}

