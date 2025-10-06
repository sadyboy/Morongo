import Foundation
import SwiftUI
// MARK: - Lesson Content View
struct LessonContentView: View {
    let lesson: Course.Lesson
    @EnvironmentObject var viewModel: AcademyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                lessonHeader
                
                // Content based on lesson type
                lessonContent
                
                // Completion Button
                if !viewModel.isLessonCompleted(lesson) {
                    completionButton
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private var lessonHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: lesson.type.icon)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .foregroundColor(.blue)
                
                Text(lesson.type.rawValue.capitalized)
                     .font(.custom("Montserrat-Bold", size: 17))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isLessonCompleted(lesson) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.custom("Montserrat-Bold", size: 22))
                }
            }
            
            Text(lesson.title)
                .font(.custom("Montserrat-Bold", size: 22))
                .fontWeight(.bold)
            
            Text(lesson.description)
                .font(.custom("Montserrat-Bold", size: 17))
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(lesson.duration / 60) min", systemImage: "clock")
                    .font(.custom("Montserrat-Bold", size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isLessonCompleted(lesson) {
                    Text("Completed")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var lessonContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lesson Content")
                .font(.title3)
                .fontWeight(.semibold)
            
            AdvancedFormattedContent(text: lesson.content)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    private var completionButton: some View {
        Button(action: {
            viewModel.markLessonCompleted(lesson)
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Mark as Completed")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(12)
        }
        .padding(.top, 20)
    }
}

// MARK: - Formatted Content View
struct FormattedContent: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseContent(text), id: \.self) { block in
                contentBlock(block)
            }
        }
    }
    
    private func contentBlock(_ block: String) -> some View {
        Group {
            if block.hasPrefix("# ") {
                // Main title
                Text(block.replacingOccurrences(of: "# ", with: ""))
                    .font(.custom("Montserrat-Bold", size: 22))
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
            } else if block.hasPrefix("## ") {
                // Section title
                Text(block.replacingOccurrences(of: "## ", with: ""))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
            } else if block.hasPrefix("- ") {
                // List item
                HStack(alignment: .top) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.blue)
                        .padding(.top, 6)
                    
                    Text(block.replacingOccurrences(of: "- ", with: ""))
                        .font(.custom("Montserrat-Bold", size: 17))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                
            } else if block.hasPrefix("**") && block.hasSuffix("**") {
                // Bold text
                Text(block.replacingOccurrences(of: "**", with: ""))
                    .font(.custom("Montserrat-Bold", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
            } else if block.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Empty line - add spacing
                Spacer()
                    .frame(height: 8)
                
            } else {
                // Regular paragraph
                Text(block)
                    .font(.custom("Montserrat-Bold", size: 17))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func parseContent(_ text: String) -> [String] {
        return text.components(separatedBy: "\n")
    }
}
// MARK: - Advanced Formatted Content
struct AdvancedFormattedContent: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(parseAdvancedContent(text), id: \.id) { element in
                contentElement(element)
            }
        }
    }
    
    private func contentElement(_ element: ContentElement) -> some View {
        Group {
            switch element.type {
            case .title:
                Text(element.content)
                    .font(.custom("Montserrat-Bold", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
            case .subtitle:
                Text(element.content)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                
            case .listItem:
                HStack(alignment: .top) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    
                    Text(element.content)
                        .font(.custom("Montserrat-Bold", size: 17))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                
            case .bold:
                Text(element.content)
                    .font(.custom("Montserrat-Bold", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
                
            case .paragraph:
                Text(element.content)
                    .font(.custom("Montserrat-Bold", size: 17))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                
            case .divider:
                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
    
    private func parseAdvancedContent(_ text: String) -> [ContentElement] {
        var elements: [ContentElement] = []
        let lines = text.components(separatedBy: "\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty {
                elements.append(ContentElement(id: UUID(), type: .divider, content: ""))
            } else if trimmedLine.hasPrefix("# ") {
                elements.append(ContentElement(id: UUID(), type: .title, content: String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.hasPrefix("## ") {
                elements.append(ContentElement(id: UUID(), type: .subtitle, content: String(trimmedLine.dropFirst(3))))
            } else if trimmedLine.hasPrefix("- ") {
                elements.append(ContentElement(id: UUID(), type: .listItem, content: String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.hasPrefix("**") && trimmedLine.hasSuffix("**") {
                elements.append(ContentElement(id: UUID(), type: .bold, content: String(trimmedLine.dropFirst(2).dropLast(2))))
            } else {
                elements.append(ContentElement(id: UUID(), type: .paragraph, content: trimmedLine))
            }
        }
        
        return elements
    }
}

struct ContentElement: Identifiable, Hashable {
    let id: UUID
    let type: ContentType
    let content: String
    
    enum ContentType {
        case title, subtitle, listItem, bold, paragraph, divider
    }
}
