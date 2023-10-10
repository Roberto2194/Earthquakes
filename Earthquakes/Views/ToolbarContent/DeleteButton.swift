//
//  DeleteButton.swift
//  Earthquakes
//
//  Created by Roberto Liccardo on 10/10/23.
//

import SwiftUI

struct DeleteButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton()
            .previewLayout(.sizeThatFits)
    }
}
