//
//  TextEditorWrapper.swift
//  TextView-Example
//
//
//
//  Created by Steven Zhang on 3/12/22.
//  Modified a lot by Joseph Levy on 8/16/23

import SwiftUI

@available(iOS 13.0, *)
public struct RichTextEditor: View {
    @State var dynamicSize = CGSize(width: 100, height: 34)
    @Binding public var attributedText: AttributedString
    private let placeholder: String
    private let accessorySections: Array<EditorSection>
    private let onCommit: (NSAttributedString) -> Void
    
    public init(
        attributedText: Binding<AttributedString>,
        placeholder: String = "Type ...",
        accessory sections: Array<EditorSection> = EditorSection.allCases,
        onCommit: @escaping ((NSAttributedString) -> Void) = { _ in}
    ) {
        _attributedText = attributedText
        self.placeholder = placeholder
        self.accessorySections = sections
        self.onCommit = onCommit
    }
    
    public var body: some View {
        TextEditorWrapper(attributedText: $attributedText, size: $dynamicSize, placeholder: placeholder, sections: accessorySections, onCommit: onCommit)
            .frame(minHeight: dynamicSize.height ,
                   maxHeight: dynamicSize.height)
    }
}
public enum EditorSection: CaseIterable {
    case bold
    case italic
    case underline
    case strikethrough
    case subscriptButton
    case superscript
    case fontAdjustment
    case textAlignment
    case image
    case color
    case background
    case keyboard
}

extension NSTextAlignment {
    var imageName: String {
        switch self {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        case .justified: return "text.justify"
        case .natural: return "text.aligncenter"
        @unknown default: return "text.aligncenter"
        }
    }
    static let available: [NSTextAlignment] = [.left, .right, .center]
}

@available(iOS 13.0, *)
struct TextEditorWrapper: UIViewControllerRepresentable {
    @Binding var attributedText: AttributedString
    @Binding private var size: CGSize
    
    private var controller: UIViewController
    internal var textView: MyTextView
    private var accessoryView: InputAccessoryView
    
    private let placeholder: String
    private let lineSpacing: CGFloat = 3
    private let hintColor = UIColor.placeholderText
    private let defaultFontSize = UIFont.systemFontSize
    private let defaultFontName = UIFont.systemFont(ofSize: 17).fontDescriptor.fontAttributes[.name] as? String ?? "SFUI"
    private let onCommit: ((NSAttributedString) -> Void)
    
    private var defaultFont: UIFont {
        return UIFont(name: defaultFontName, size: defaultFontSize) ?? .systemFont(ofSize: defaultFontSize)
    }
    
    // TODO: line width, line style
    init(
        attributedText: Binding<AttributedString>,
        size: Binding<CGSize>,
        placeholder: String,
        sections: Array<EditorSection>,
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        _attributedText = attributedText
        self._size = size
        self.controller = UIViewController()
        self.textView = MyTextView()
        let rect = CGRect(x: 0, y: 0, width: 100, height: sections.contains(.color) ? 70 : 40)
        self.placeholder = placeholder
        self.onCommit = onCommit
        
        self.accessoryView = InputAccessoryView(frame: rect, inputViewStyle: .default, accessorySections: sections)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        setUpTextView()
        textView.delegate = context.coordinator
        context.coordinator.textViewDidChange(textView)
        
        accessoryView.delegate = context.coordinator
        textView.inputAccessoryView = accessoryView
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.parent.textView.attributedText =  attributedText.nsAttributedString
        // apparently the context is assigned to the "state" after this so without changing the context nothing happens
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setUpTextView() {
        let richText = attributedText.nsAttributedString
        if richText.string == "" {
            textView.attributedText = NSAttributedString(string: placeholder, attributes: [.foregroundColor: hintColor])
        } else {
            textView.attributedText = richText
        }
        textView.typingAttributes = [.font : defaultFont]
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.textAlignment = .left
        
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        //textView.layoutManager.allowsNonContiguousLayout = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.backgroundColor = .clear
        textView.textColor = .label
        controller.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //textView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            //textView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
        ])
    }
    
    private func scaleImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let ratio = image.size.width / image.size.height
        let imageW: CGFloat = (ratio >= 1) ? maxWidth : image.size.width*(maxHeight/image.size.height)
        let imageH: CGFloat = (ratio <= 1) ? maxHeight : image.size.height*(maxWidth/image.size.width)
        UIGraphicsBeginImageContext(CGSize(width: imageW, height: imageH))
        image.draw(in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
        let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledimage!
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {//, TextEditorDelegate
        var parent: TextEditorWrapper
        var fontName: String
        
        init(_ parent: TextEditorWrapper) {
            self.parent = parent
            self.fontName = parent.defaultFontName
        }
        
        // MARK: - Image Picker
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, var image = img.roundedImageWithBorder(color: .secondarySystemBackground) {
                textViewDidBeginEditing(parent.textView)
                let newString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                image = scaleImage(image: image, maxWidth: 180, maxHeight: 180)
                
                let textAttachment = NSTextAttachment(image: image)
                let attachmentString = NSAttributedString(attachment: textAttachment)
                newString.append(attachmentString)
                parent.textView.attributedText = newString
                textViewDidChange(parent.textView)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func scaleImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
            let ratio = image.size.width / image.size.height
            let imageW: CGFloat = (ratio >= 1) ? maxWidth : image.size.width*(maxHeight/image.size.height)
            let imageH: CGFloat = (ratio <= 1) ? maxHeight : image.size.height*(maxWidth/image.size.width)
            UIGraphicsBeginImageContext(CGSize(width: imageW, height: imageH))
            image.draw(in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
            let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledimage!
        }
        
        // MARK: - Text Editor Delegate

        func textAlign(align: NSTextAlignment) {
            parent.textView.textAlignment = align
        }
        
        func adjustFontSize(isIncrease: Bool) {
            var font: UIFont
            let defaultFont = UIFont.preferredFont(forTextStyle: .body)
            let maxFontSize: CGFloat = 80
            let minFontSize: CGFloat = 8
            let rangesAttributes = selectedRangeAttributes
            for (range, attributes) in rangesAttributes {
                font = attributes[.font] as? UIFont ?? defaultFont
                let weight = font.fontDescriptor.symbolicTraits.intersection(.traitBold) == .traitBold ? .bold : font.fontDescriptor.weight
                let size = font.fontDescriptor.pointSize
                let fontSize = size + CGFloat(isIncrease ? (size < maxFontSize ? 1 : 0) : (size > minFontSize ? -1 : 0))
                font = UIFont(descriptor: font.fontDescriptor, size: fontSize).withWeight(weight)
                textEffect(range: range, key: .font, value: font, defaultValue: defaultFont)
            }
        }
        
        /// Not used yet?
        func textFont(name: String) {
            let attributes = parent.textView.selectedRange.isEmpty ? parent.textView.typingAttributes : selectedAttributes
            let fontSize = getFontSize(attributes: attributes)
            
            fontName = name
            let defaultFont = UIFont.preferredFont(forTextStyle: .body)
            let newFont = UIFont(name: fontName, size: fontSize) ?? defaultFont
            textEffect(range: parent.textView.selectedRange, key: .font, value: newFont, defaultValue: defaultFont)
        }
        
        func textColor(color: UIColor) {
            textEffect(range: parent.textView.selectedRange, key: .foregroundColor, value: color, defaultValue: color)
        }
        
        func textBackground(color: UIColor) {
            textEffect(range: parent.textView.selectedRange, key: .backgroundColor, value: color, defaultValue: color)
        }
        
        func insertImage() {
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            parent.controller.present(imagePicker, animated: true, completion: nil)
        }
        
        func insertLine(name: String) {
            if let line = UIImage(named: name) {
                let newString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                let image = scaleImage(image: line, maxWidth: 280, maxHeight: 20)
                let attachment = NSTextAttachment(image: image)
                let attachedString = NSAttributedString(attachment: attachment)
                newString.append(attachedString)
                parent.textView.attributedText = newString
            }
        }
        
        func hideKeyboard() {
            parent.textView.resignFirstResponder()
        }
        
        /// Add text attribute to text view
        private func textEffect<T: Equatable>(range: NSRange, key: NSAttributedString.Key, value: T, defaultValue: T) {
            
            if !range.isEmpty {
                let mutableString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                mutableString.removeAttribute(key, range: range)
                mutableString.addAttributes([key : value], range: range)
                // Update parent
                parent.textView.updateAttributedText(with: mutableString)
            } else {
                if let current = parent.textView.typingAttributes[key], current as! T == value  {
                    parent.textView.typingAttributes[key] = defaultValue
                } else {
                    parent.textView.typingAttributes[key] = value
                }
                parent.accessoryView.updateToolbar(typingAttributes: parent.textView.typingAttributes, textAlignment: parent.textView.textAlignment)
            }
            parent.textView.selectedRange = range // restore selection
        }
        
        private func getFontSize(attributes: [NSAttributedString.Key : Any]) -> CGFloat {
            let font = attributes[.font] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
            return font.pointSize
        }
        
        var selectedAttributes: [NSAttributedString.Key : Any] {
            let textRange = parent.textView.selectedRange
            if textRange.isEmpty {
                return parent.textView.typingAttributes
            } else {
                var textAttributes: [NSAttributedString.Key : Any] = [:]
                parent.textView.attributedText.enumerateAttributes(in: textRange) { attributes, range, stop in
                    for item in attributes {
                        textAttributes[item.key] = item.value
                    }
                }
                return textAttributes
            }
        }
        
        var selectedRangeAttributes: [(NSRange, [NSAttributedString.Key : Any])] {
            let textRange = parent.textView.selectedRange
            if textRange.isEmpty { return [(textRange, parent.textView.typingAttributes)]}
            var textAttributes: [(NSRange, [NSAttributedString.Key : Any])] = []
            parent.textView.attributedText.enumerateAttributes(in: textRange) { attributes, range, stop in
                textAttributes.append((range,attributes))
            }
            return textAttributes
        }
        
        // MARK: - Text View Delegate
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.accessoryView.updateToolbar(typingAttributes: selectedAttributes, textAlignment: textView.textAlignment)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.attributedText.string == parent.placeholder {
                textView.attributedText = NSAttributedString(string: "")
                textView.typingAttributes[.foregroundColor] = UIColor.label
            }
            textViewDidChangeSelection(textView)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.attributedText.string == "" || textView.attributedText.string == parent.placeholder {
                textView.attributedText = NSAttributedString(string: parent.placeholder)
            } else {
                parent.onCommit(textView.attributedText)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.attributedText.string != parent.placeholder {
                DispatchQueue.main.async { [self] in
                    parent.attributedText = textView.attributedText.attributedString
                }
            }
            let size = CGSize(width: parent.controller.view.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            if parent.size != estimatedSize {
                DispatchQueue.main.async { [self] in
                    parent.size = estimatedSize
                }
            }
            textView.scrollRangeToVisible(textView.selectedRange)
        }
    }
    class MyTextView: UITextView {
        
        // This works in iOS 16 but never called in 15 I believe
        open override func buildMenu(with builder: UIMenuBuilder) {
            builder.remove(menu: .lookup) // Remove Lookup, Translate, Search Web
            //builder.remove(menu: .standardEdit) // Keep Cut, Copy, Paste
            //builder.remove(menu: .replace) // Keep Replace
            builder.remove(menu: .share) // Remove Share
            builder.remove(menu: .textStyle) // Remove Format

            super.buildMenu(with: builder)
        }
        
        // This is needed for iOS 15
        open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if #unavailable(iOS 16.0) {
                //let menuController = UIMenuController.shared

                // Get rid of menu item not wanted
                if action.description.contains("_share") // Share
                    || action.description.contains("_translate") // Translate
                    || action.description.contains("_define") { // Blocks Lookup
                    return false
                }
            }
            return super.canPerformAction(action, withSender: sender)
        }
        
        public func updateAttributedText(with attributedString: NSAttributedString) {
            attributedText = attributedString
            if let update = delegate?.textViewDidChange {
                update(self) }
        }
    }
}
