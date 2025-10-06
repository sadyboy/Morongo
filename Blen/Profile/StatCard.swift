import Foundation
import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
            
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .foregroundColor(.blue)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Image(.cell)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
            )
            .cornerRadius(12)
    }
}
