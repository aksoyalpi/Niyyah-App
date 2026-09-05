import FamilyControls
import SwiftUI

struct AppPickerView: View {
  @State var selection: FamilyActivitySelection
  @Environment(\.dismiss) private var dismiss
  let onDone: (FamilyActivitySelection) -> Void

  var body: some View {
    NavigationStack {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Choose apps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              let selected = selection
              dismiss()
              onDone(selected)
            }
          }
        }
    }
  }
}
