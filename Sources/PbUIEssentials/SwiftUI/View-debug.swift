/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI
import PbEssentials

public extension View {
    func dbgCode(_ code: () -> Void) -> Self {
    #if DEBUG
        code()
    #endif
        return self
    }
    
    func dbgPrint(level: Int = 0, _ values: Any..., function: String = #function, file: String = #fileID, line: Int = #line) -> Self {
        dbgCode {
        #if DEBUG
            PbEssentials.dbg(level: level, values, function: function, file: file, line: line)
        #endif
        }
    }
}

