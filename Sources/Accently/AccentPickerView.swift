import SwiftUI

struct AccentPickerView: View {
    let session: AccentSession

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ForEach(Array(session.options.enumerated()), id: \.offset) { index, option in
                    VStack(spacing: 7) {
                        Text(option)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(index == session.selectedIndex ? Color.black : Color.white)
                            .frame(width: 46, height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(index == session.selectedIndex ? Color(red: 0.54, green: 0.93, blue: 0.78) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(index == session.selectedIndex ? Color.white.opacity(0.7) : Color.white.opacity(0.1), lineWidth: 1)
                            )

                        Circle()
                            .fill(index == session.selectedIndex ? Color(red: 1.0, green: 0.42, blue: 0.58) : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
            }

            Text("Release to type")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.black.opacity(0.84))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 20, y: 10)
        .fixedSize()
    }
}
