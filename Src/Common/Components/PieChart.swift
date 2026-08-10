import SwiftUI

/// 纯 SwiftUI 饼图(无第三方依赖)
struct PieChart: View {
    struct Slice: Identifiable {
        let id = UUID()
        let value: Double
        let color: Color
        let label: String
    }
    let slices: [Slice]

    private var total: Double { max(slices.reduce(0) { $0 + $1.value }, 0.0001) }

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(Array(angles().enumerated()), id: \.offset) { idx, seg in
                    Path { p in
                        p.move(to: center)
                        p.addArc(center: center, radius: radius,
                                 startAngle: seg.start, endAngle: seg.end, clockwise: false)
                        p.closeSubpath()
                    }
                    .fill(slices[idx].color)
                }
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: radius, height: radius)
            }
        }
    }

    private func angles() -> [(start: Angle, end: Angle)] {
        var result: [(Angle, Angle)] = []
        var running = -90.0
        for s in slices {
            let sweep = s.value / total * 360
            result.append((.degrees(running), .degrees(running + sweep)))
            running += sweep
        }
        return result
    }
}
