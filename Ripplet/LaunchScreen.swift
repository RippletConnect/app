import SwiftUI
import UIKit

struct LaunchScreen: View {
    @EnvironmentObject var settings: Settings
    @Binding var isLaunching: Bool

    @State private var logoScale: CGFloat = 0.86
    @State private var logoOpacity: CGFloat = 0.0

    @State private var collapse: CGFloat = 0.0

    var accent: Color { settings.accentColor }
    var accentSoft: Color { settings.accentColor.opacity(0.35) }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Wave wash that fades amplitude as collapse rises
            WaveWash(color: accentSoft, collapse: collapse)
                .ignoresSafeArea()

            // Ripple rings that contract toward the logo as collapse rises
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Ripples(time: t,
                        color: accent,
                        maxRadius: 260,
                        ringCount: 5,
                        collapse: collapse)
                    .allowsHitTesting(false)
            }

            // Logo
            Image("Ripplet")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 10, y: 4)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            let settleDelay: TimeInterval = 0.6
            let implosionDelayAfterSettle: TimeInterval = 0.6
            let implosionDuration: TimeInterval = 1
            let dismissDuration: TimeInterval = 0.35
            
            triggerHaptic()

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                logoOpacity = 1.0
                logoScale = 0.95
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + settleDelay) {
                triggerHaptic()
                withAnimation(.easeInOut(duration: 0.5)) { logoScale = 0.9 }

                DispatchQueue.main.asyncAfter(deadline: .now() + implosionDelayAfterSettle) {
                    triggerHaptic()
                    withAnimation(.timingCurve(0.15, 0.8, 0.2, 1.0, duration: implosionDuration)) {
                        collapse = 1.0
                        logoScale = 0.88
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + implosionDuration) {
                        withAnimation(.easeInOut(duration: dismissDuration)) { isLaunching = false }
                    }
                }
            }
        }
    }
}

private struct Ripples: View {
    var time: TimeInterval
    var color: Color
    var maxRadius: CGFloat
    var ringCount: Int
    var collapse: CGFloat = 0 // 0..1

    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let speed: Double = 0.9

            // As we collapse, subtly reverse the phase so it feels like “inward” motion
            // (purely visual; keeps rings lively while shrinking)
            let reverseBias = Double(collapse) * 0.5
            let baseProgress = ((time * speed) - reverseBias).truncatingRemainder(dividingBy: 1)

            for i in 0..<ringCount {
                let phase = (baseProgress + Double(i) / Double(ringCount)).truncatingRemainder(dividingBy: 1)
                let eased = cubicEaseOut(phase)

                // Core trick: multiply radius by (1 - collapse) so rings are pulled inward
                let radius = CGFloat(eased) * maxRadius * max(0, (1 - collapse))

                // Fade as it expands + fade more as we collapse
                let alpha = max(0, 0.35 * (1 - eased)) * Double(max(0.0, 1 - collapse * 1.1))

                var path = Path()
                path.addEllipse(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))

                // Thin out during collapse
                let line = max(1.2, 6 * (1 - eased)) * max(0.5, (1 - collapse))
                let stroke = StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round)
                ctx.stroke(path, with: .color(color.opacity(alpha)), style: stroke)

                if alpha > 0.05 { ctx.addFilter(.blur(radius: 0.8)) }
            }
        }
        .compositingGroup()
        .allowsHitTesting(false)
    }

    private func cubicEaseOut(_ x: Double) -> Double {
        let p = max(0, min(1, x))
        return 1 - pow(1 - p, 3)
    }
}

private struct WaveWash: View {
    var color: Color
    var collapse: CGFloat = 0 // 0..1

    @State private var amplitudeBase: CGFloat = 22

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            // Amplitude fades with collapse
            let amplitude = amplitudeBase * max(0, (1 - collapse))
            let phase = CGFloat(t * 1.2)

            ZStack {
                LinearGradient(
                    colors: [
                        color.opacity(0.45),
                        color.opacity(0.15),
                        color.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask {
                    VStack(spacing: 0) {
                        WaveShape(phase: phase, amplitude: amplitude)
                            .frame(height: 220)
                        WaveShape(phase: phase + .pi, amplitude: amplitude * 0.7)
                            .frame(height: 220)
                        Spacer(minLength: 0)
                    }
                }
                .blur(radius: 24)
                .opacity(Double(max(CGFloat(0.0), 1.0 - collapse * 1.2))) // fade wash out during collapse
                // Optional: slightly scale toward the logo as it collapses
                .scaleEffect(1 - (collapse * 0.08), anchor: .center)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                amplitudeBase = 26
            }
        }
    }
}

private struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.height * 0.5
        let width = rect.width

        p.move(to: CGPoint(x: 0, y: midY))

        let wavelength = max(60, width / 1.2)
        let step: CGFloat = 6

        var x: CGFloat = 0
        while x <= width + step {
            let relative = x / wavelength
            let y = midY + sin(relative * 2 * .pi + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        p.addLine(to: CGPoint(x: width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(phase, amplitude) }
        set { phase = newValue.first; amplitude = newValue.second }
    }
}

private func triggerHaptic() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
}
