import Foundation
import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.custom("Montserrat-Bold", size: 22))
                .foregroundColor(.blue)
            Text(value)
                .font(.custom("Montserrat-Bold", size: 12))
                .fontWeight(.semibold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Image(.cell).resizable())
        .cornerRadius(12)
    }
}
