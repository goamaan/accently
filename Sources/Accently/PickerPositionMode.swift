import Foundation

enum PickerPositionMode: String, CaseIterable, Identifiable {
    case centerScreen
    case nearMouse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .centerScreen:
            return "Center Screen"
        case .nearMouse:
            return "Near Mouse"
        }
    }
}
