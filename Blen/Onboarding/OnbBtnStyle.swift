import Foundation
import SwiftUI

struct OnboardingButtonStyle: ButtonStyle {
    let isSecondary: Bool
    
    init(isSecondary: Bool = false) {
        self.isSecondary = isSecondary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("ChangaOne-Regular", size: 18))
            .foregroundColor(isSecondary ? .white : .white)
            .frame(height: 50)
            .frame(maxWidth: isSecondary ? nil : .infinity)
            .padding(.horizontal, isSecondary ? 20 : 0)
            .background(
                ZStack {
                    if !isSecondary {
                        LinearGradient(
                            colors: [.yellow, .brown, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSecondary ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1)
                )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
