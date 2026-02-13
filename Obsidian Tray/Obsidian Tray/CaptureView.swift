import SwiftUI

struct CaptureView: View {
    @State private var noteText: String = ""
    @State private var textHeight: CGFloat = 24
    
    let onSubmit: (String) -> Void
    let onCancel: () -> Void
    
    private let minHeight: CGFloat = 24
    private let maxHeight: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                
                CaptureTextView(
                    text: $noteText,
                    contentHeight: $textHeight,
                    maxHeight: maxHeight,
                    onSubmit: submitIfValid,
                    onCancel: onCancel
                )
                .frame(height: min(max(textHeight, minHeight), maxHeight))
                
                if !noteText.isEmpty {
                    Button(action: submitIfValid) {
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            HStack {
                Text("⏎ Save")
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary.opacity(0.5))
                Text("⌥⏎ Newline")
                    .foregroundColor(.secondary)
                Text("•")
                    .foregroundColor(.secondary.opacity(0.5))
                Text("⎋ Cancel")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .font(.system(size: 11))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 12, bottomTrailing: 12))
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 500)
        .animation(.easeOut(duration: 0.1), value: textHeight)
    }
    
    private func submitIfValid() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
        noteText = ""
        textHeight = minHeight
    }
}

// MARK: - NSTextView wrapper for key event handling
struct CaptureTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var contentHeight: CGFloat
    let maxHeight: CGFloat
    let onSubmit: () -> Void
    let onCancel: () -> Void
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isRichText = false
        textView.allowsUndo = true
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.isVerticallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        
        scrollView.hasVerticalScroller = true
        scrollView.scrollerStyle = .overlay
        scrollView.autohidesScrollers = true  // Only shows when needed
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        
        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
            // Only update height when text changed externally (e.g., reset to empty)
            DispatchQueue.main.async {
                self.updateHeight(textView)
            }
        }
    }
    
    private func updateHeight(_ textView: NSTextView) {
        guard let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer,
              let scrollView = textView.enclosingScrollView else { return }

        layoutManager.ensureLayout(for: textContainer)
        let height = layoutManager.usedRect(for: textContainer).height

        // Only show scrollbar when content exceeds maxHeight
        scrollView.hasVerticalScroller = height > maxHeight

        if contentHeight != height {
            contentHeight = height
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CaptureTextView
        
        init(_ parent: CaptureTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.updateHeight(textView)
        }
        
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onCancel()
                return true
            }
            
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                let optionPressed = NSEvent.modifierFlags.contains(.option)
                
                if optionPressed {
                    textView.insertNewlineIgnoringFieldEditor(nil)
                    return true
                } else {
                    parent.onSubmit()
                    return true
                }
            }
            
            return false
        }
    }
}

#Preview {
    CaptureView(
        onSubmit: { _ in },
        onCancel: { }
    )
    .padding(40)
    .frame(width: 600, height: 300)
    .background(Color.gray.opacity(0))
}
