// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct Magnets {
    static func closest(to position: CGPoint, inSpace: CGSize) -> CGPoint {
        var stops = [CGPoint]()

        stride(from: -1.0, through: 1.0, by: 0.5).forEach { x in
            stride(from: -1.0, through: 1.0, by: 0.5).forEach { y in
                stops.append(CGPoint(x: x, y: y))
            }
        }

        let distances = stops.map {
            let p = CGPoint(x: $0.x * inSpace.width / 2, y: $0.y * inSpace.height / 2)
            return p.distance(to: position)
        }

        var ixOfMinimum = -1
        var minimumDistance = CGFloat.greatestFiniteMagnitude
        for ix in 0..<distances.count {
            if distances[ix] < minimumDistance {
                ixOfMinimum = ix
                minimumDistance = distances[ix]
            }
        }

        let magnet = CGPoint(
            x: stops[ixOfMinimum].x * inSpace.width / 2,
            y: stops[ixOfMinimum].y * inSpace.height / 2
        )

        return magnet
    }
}

struct Slider2DView: View {
    let canvasColor: Color = .blue
    let cornerRadius: CGFloat = 15
    let handleColor: Color = .purple
    let size: CGSize = CGSize(width: 400, height: 400)
    let title: String

    @State private var dotAlpha: CGFloat = 1
    @State private var dotOffset: CGPoint = .zero
    @State private var dotPosition: CGPoint = .zero

    func dragChange(_ gesture: DragGesture.Value, sticky: Bool = true) {
        let gOffset = CGPoint(
            x: gesture.translation.width,
            y: gesture.translation.height
        )

        let intendedPosition = CGPoint(
            x: gOffset.x + dotPosition.x,
            y: gOffset.y + dotPosition.y
        )

        let magnet = Magnets.closest(to: intendedPosition, inSpace: size)

        if magnet.distance(to: intendedPosition) < 20 {
            dotOffset = CGPoint(x: magnet.x - dotPosition.x, y: magnet.y - dotPosition.y)
            dotAlpha = 1
        } else {
            dotOffset = gOffset
            dotAlpha = 0.8
        }
    }

    func dragEnd(_ gesture: DragGesture.Value, sticky: Bool = true) {
        dotOffset = .zero

        let gOffset = CGPoint(
            x: gesture.translation.width,
            y: gesture.translation.height
        )

        let intendedPosition = CGPoint(x: gOffset.x + dotPosition.x, y: gOffset.y + dotPosition.y)
        let magnet = Magnets.closest(to: intendedPosition, inSpace: size)

        if magnet.distance(to: intendedPosition) < 20 {
            dotPosition = CGPoint(x: magnet.x, y: magnet.y)
        } else {
            dotPosition = CGPoint(
                x: gOffset.x + dotPosition.x,
                y: gOffset.y + dotPosition.y
            )
        }
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(title)

            ZStack {

                RoundedRectangle(cornerRadius: 15, style: .circular)
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(canvasColor)
                    .onTapGesture(count: 2) {
                        dotOffset = .zero
                        dotPosition = .zero
                    }
                    .onTapGesture { position in
                        dotOffset = .zero
                        dotPosition = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
                    }
                    .coordinateSpace(.named("sliderCanvas"))

                Rectangle()
                    .frame(width: 2, height: size.height)
                    .foregroundColor(.black)

                Rectangle()
                    .frame(width: size.width, height: 2)
                    .foregroundColor(.black)

                Circle()
                    .fill(handleColor.opacity(dotAlpha))
                    .frame(width: max(10, size.width / 10), height: max(10, size.height / 10))
                    .offset(x: dotOffset.x + dotPosition.x, y: dotOffset.y + dotPosition.y)

                    .gesture(
                        DragGesture(coordinateSpace: .named("sliderCanvas")).modifiers(.control)
                            .onChanged { dragChange($0, sticky: false) }
                            .onEnded { dragEnd($0, sticky: false) }
                    )

                    .gesture(
                        DragGesture(coordinateSpace: .named("sliderCanvas"))
                            .onChanged { dragChange($0, sticky: true) }
                            .onEnded { dragEnd($0, sticky: true) }
                    )
            }

            Text("\(CGPoint(x: dotOffset.x + dotPosition.x, y: -(dotOffset.y + dotPosition.y)))")
        }
    }
}

#Preview {
    Slider2DView(title: "Slider 2D")
}
