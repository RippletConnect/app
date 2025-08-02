import SwiftUI

struct LaunchScreen: View {
    @EnvironmentObject var settings: Settings

    @Binding var isLaunching: Bool

    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var gradientSize: CGFloat = 0.0

    var gradient: LinearGradient {
        LinearGradient(
            colors: [settings.accentColor.opacity(0.3), settings.accentColor.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            gradient
                .clipShape(Circle())
                .scaleEffect(gradientSize)

            VStack {
                VStack {
                    Image("Ripplet")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(width: 150, height: 150)
                        .padding()
                }
                .foregroundColor(settings.accentColor)
                .scaleEffect(size)
                .opacity(opacity)
            }
        }
        .onAppear {
            triggerHapticFeedback(.soft)
            
            withAnimation(.easeInOut(duration: 0.5)) {
                size = 0.9
                opacity = 1.0
                gradientSize = 3.0
                
                triggerHapticFeedback(.soft)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                triggerHapticFeedback(.soft)
                
                withAnimation(.easeOut(duration: 0.5)) {
                    size = 0.8
                    gradientSize = 0.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    triggerHapticFeedback(.soft)

                    withAnimation {
                        self.isLaunching = false
                    }
                }
            }
        }
    }
    
    private func triggerHapticFeedback(_ feedbackType: HapticFeedbackType) {
        #if !os(watchOS)
        switch feedbackType {
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        #else
        if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
        #endif
    }

    enum HapticFeedbackType {
        case soft, light, medium, heavy
    }
}
