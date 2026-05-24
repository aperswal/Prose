import SwiftUI
import UIKit

struct HighlightingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    var highlights: [HighlightRange]
    var highlightsEnabled: Bool
    var font: UIFont = .preferredFont(forTextStyle: .title3)
    var textColor: UIColor = .label

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.isEditable = true
        tv.isSelectable = true
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.font = font
        tv.textColor = textColor
        tv.autocapitalizationType = .sentences
        tv.smartQuotesType = .yes
        tv.smartDashesType = .yes
        tv.adjustsFontForContentSizeCategory = true
        tv.text = text
        applyAttributes(to: tv)
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        if tv.text != text {
            let selectedRange = tv.selectedRange
            tv.text = text
            let clamped = NSRange(
                location: min(selectedRange.location, (tv.text as NSString).length),
                length: 0
            )
            tv.selectedRange = clamped
        }
        if tv.font != font { tv.font = font }
        applyAttributes(to: tv)

        if isEditing && !tv.isFirstResponder {
            DispatchQueue.main.async { tv.becomeFirstResponder() }
        } else if !isEditing && tv.isFirstResponder {
            DispatchQueue.main.async { tv.resignFirstResponder() }
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width
        guard width.isFinite, width > 0 else { return nil }
        uiView.textContainer.size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let height = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        return CGSize(width: width, height: max(height, 320))
    }

    private func applyAttributes(to tv: UITextView) {
        let nsText = tv.text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        guard fullRange.length > 0 else { return }

        let storage = tv.textStorage
        storage.beginEditing()

        storage.removeAttribute(.backgroundColor, range: fullRange)
        storage.removeAttribute(.underlineStyle, range: fullRange)
        storage.removeAttribute(.underlineColor, range: fullRange)
        storage.addAttribute(.font, value: font, range: fullRange)
        storage.addAttribute(.foregroundColor, value: textColor, range: fullRange)

        if highlightsEnabled {
            let source = tv.text ?? ""
            let isDark = tv.traitCollection.userInterfaceStyle == .dark
            let sentenceAlpha: CGFloat = isDark ? 0.32 : 0.16
            for hl in highlights {
                guard let nsRange = nsRange(from: hl.range, in: source) else { continue }
                let intersected = NSIntersectionRange(nsRange, fullRange)
                guard intersected.length > 0 else { continue }
                let uiColor = UIColor(hl.category.color)
                if hl.category.isSentenceLevel {
                    storage.addAttribute(
                        .backgroundColor,
                        value: uiColor.withAlphaComponent(sentenceAlpha),
                        range: intersected
                    )
                } else {
                    storage.addAttribute(
                        .underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: intersected
                    )
                    storage.addAttribute(.underlineColor, value: uiColor, range: intersected)
                    storage.addAttribute(.foregroundColor, value: uiColor, range: intersected)
                }
            }
        }

        storage.endEditing()
    }

    private func nsRange(from range: Range<String.Index>, in source: String) -> NSRange? {
        guard
            let lower = range.lowerBound.samePosition(in: source.utf16),
            let upper = range.upperBound.samePosition(in: source.utf16)
        else { return nil }
        let location = source.utf16.distance(from: source.utf16.startIndex, to: lower)
        let length = source.utf16.distance(from: lower, to: upper)
        return NSRange(location: location, length: length)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightingTextEditor

        init(_ parent: HighlightingTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            if parent.text != textView.text {
                parent.text = textView.text
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if !parent.isEditing {
                DispatchQueue.main.async { self.parent.isEditing = true }
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.isEditing {
                DispatchQueue.main.async { self.parent.isEditing = false }
            }
        }
    }
}
