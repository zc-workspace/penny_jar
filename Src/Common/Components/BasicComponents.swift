import SwiftUI

/// 圆形分类图标
struct CategoryIcon: View {
    let systemName: String
    let colorHex: String
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: colorHex).opacity(0.15))
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(Color(hex: colorHex))
        }
        .frame(width: size, height: size)
    }
}

/// 卡片容器
struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

/// 简易水平柱状条(用于预算 / 分类占比)
struct ProgressBar: View {
    var value: Double          // 0...1
    var color: Color
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.15))
                Capsule().fill(color)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}
