//
//  SelectButton.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 10/10/23.
//

import SwiftUI

enum SelectMode {
    case active, inactive

    var isActive: Bool {
        self == .active
    }

    mutating func toggle() {
        switch self {
        case .active:
            self = .inactive
        case .inactive:
            self = .active
        }
    }
}

struct SelectButton: View {
    @Binding var mode: SelectMode
    var action: () -> Void = {}
    var body: some View {
        Button {
            withAnimation {
                mode.toggle()
                action()
            }
        } label: {
            Text(mode.isActive ? "Deselect All" : "Select All")
        }
    }
}

struct SelectButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectButton(mode: .constant(.active))
            SelectButton(mode: .constant(.inactive))
        }
        .previewLayout(.sizeThatFits)
    }
}
