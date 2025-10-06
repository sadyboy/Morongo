import Foundation
import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var username: String {
        didSet { saveUser() }
    }
    @Published var profileImage: UIImage? {
        didSet { saveUser() }
    }
    
    private let usernameKey = "profile_username"
    private let imageKey = "profile_image"
    
    init() {
        self.username = UserDefaults.standard.string(forKey: usernameKey) ?? "Guest"
        
        if let data = UserDefaults.standard.data(forKey: imageKey),
           let uiImage = UIImage(data: data) {
            self.profileImage = uiImage
        } else {
            self.profileImage = nil
        }
    }
    
    private func saveUser() {
        UserDefaults.standard.set(username, forKey: usernameKey)
        
        if let image = profileImage,
           let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: imageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: imageKey)
        }
    }
}
