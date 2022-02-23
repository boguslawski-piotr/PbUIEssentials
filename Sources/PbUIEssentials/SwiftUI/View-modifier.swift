/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public extension View {
    func modifier<M: View>(@ViewBuilder _ modifier: (Self) -> M) -> some View {
        modifier(self)
    }
    
    @ViewBuilder
    func modifier<M: View>(if condition: Bool, @ViewBuilder _ modifier: (Self) -> M) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func modifier<M1: View, M2: View>(if condition: Bool, @ViewBuilder _ thenModifier: (Self) -> M1, @ViewBuilder else elseModifier: (Self) -> M2) -> some View {
        if condition {
            thenModifier(self)
        } else {
            elseModifier(self)
        }
    }
}

public extension View {
    @ViewBuilder
    func hidden(if condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
    
    func visible(if condition: Bool) -> some View {
        hidden(if: !condition)
    }
}
