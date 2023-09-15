//
//  KeyBoardAddition.swift
//  RichTextField
//
//  Created by Joseph Levy on 9/10/23.
//

import SwiftUI

private struct SizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    public func captureSize(in binding: Binding<CGSize>) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(key: SizeKey.self, value: proxy.size)
        })
        .onPreferenceChange(SizeKey.self) { size in binding.wrappedValue = size  }
    }
}
import Combine
class KeyBoardAdditionModel: ObservableObject {
    ///The shared instance of `TextHolder` for access across the frameworks.
    static let shared = KeyBoardAdditionModel()
    internal init(selectedRange: NSRange = NSRange(), attributes: [NSAttributedString.Key : Any] = [:], justChanged: Bool = false) {
        self.selectedRange = selectedRange
        self.attributes = attributes
        self.justChanged = justChanged
        $selectedRange
            .removeDuplicates()
            .sink { _ in  }
            .store(in: &subscribers)
    }
    var subscribers = Set<AnyCancellable>()

    ///The currently user selected text range.
    @Published var selectedRange: NSRange
    @Published var attributes: [NSAttributedString.Key: Any]
    ///NOTE: You can comment the next variable out if you do not need to update cursor location
    ///Whether or not SwiftUI just changed the text
    @Published var justChanged: Bool
    
}

struct KeyBoardAddition: View {
    internal init(textView: TextEditorWrapper.MyTextView, toolbar: Binding<(highlighting: [Bool],fontSize: CGFloat,textAlignment: NSTextAlignment,color: Color, background: Color)>) {
        self.textView = textView
        self._toolbar = toolbar
    }
    
    var textView: TextEditorWrapper.MyTextView
    @ObservedObject var keyBoardAdditionModel = KeyBoardAdditionModel()
    @Binding var toolbar: (highlighting: [Bool],fontSize: CGFloat, textAlignment: NSTextAlignment, color: Color, background: Color)
    
    private let buttonWidth: CGFloat = 32
    private let buttonHeight: CGFloat = 32
    private let cornerRadius: CGFloat = 6
    private let edgeInsets = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0)
    private let selectedColor = UIColor.separator
    private let containerBackgroundColor: UIColor = .systemBackground
    private let toolBarsBackground: UIColor = .systemGroupedBackground
    private let colorConf = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    private var imageConf: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: min(buttonWidth, buttonHeight) * 0.7)
    }
    var attributes: [NSAttributedString.Key : Any] { KeyBoardAdditionModel.shared.attributes }
    
    func roundedRectangle(_ highlight: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 5).fill(Color(highlight ? selectedColor : .clear))
    }
    
    var isBold: Bool { toolbar.highlighting[0]}
    var isItalic: Bool { toolbar.highlighting[1]}
    var isUnderline: Bool { toolbar.highlighting[2]}
    var isStrikethrough: Bool { toolbar.highlighting[3]}
    var isSuperscript: Bool { toolbar.highlighting[4]}
    var isSubscript: Bool { toolbar.highlighting[5]}
    var textAlignment: NSTextAlignment { toolbar.textAlignment }
    func updateAttributedText(with attributedText: NSAttributedString) {
        let selection = textView.selectedRange
        textView.updateAttributedText(with: attributedText)
        textView.selectedRange = selection
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    Button(action: toggleBoldface) { Label("", systemImage: "bold") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isBold))
                    Button(action: toggleItalics) { Label("", systemImage: "italic") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isItalic))
                    Button(action: toggleUnderline) { Label("", systemImage: "underline") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isUnderline))
                    Button(action: toggleStrikethrough) { Label("", systemImage: "strikethrough") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isStrikethrough))
                    Button(action: toggleSuperscript) { Label("", systemImage: "textformat.superscript") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isSuperscript))
                    Button(action: toggleSubscript) { Label("", systemImage: "textformat.subscript") }
                        .padding(edgeInsets)
                        .background(roundedRectangle(isSubscript))
                    Button(action: increaseFontSize) { Label("", systemImage: "plus.circle") }
                        .padding(edgeInsets)
                    Text("\(Int(toolbar.fontSize))").font(.body)
                    Button(action: decreaseFontSize) { Label("", systemImage: "minus.circle") }
                        .padding(edgeInsets)
                    Button(action: alignText) { Label("", systemImage: toolbar.textAlignment.imageName)}
                }
                Button(action: insertImage) { Label("", systemImage: "photo.on.rectangle.angled") }
                    .padding(edgeInsets)
                    .background(roundedRectangle())
                Spacer()
                Button(action: {
                    textView.resignFirstResponder()
                }) { Label("", systemImage: "keyboard.chevron.compact.down")}
            }.font(.title2)
            HStack {
                ColorPicker(selection: $toolbar.color, supportsOpacity: true) {Text(" Foreground")}
                    .fixedSize()
                    .onChange(of: toolbar.color) { _ in selectColor()}
                
                ColorPicker(selection: $toolbar.background, supportsOpacity: true, label: {Text("Background")})
                    .fixedSize()
                    .onChange(of: toolbar.background) { _ in selectBackground() }
                Spacer()
            }.padding(.vertical, 4)
        }
        
        
        .background(Color(toolBarsBackground))
        .onAppear {
            print("Appearing...")
            //updateToolbar(typingAttributes: textView.typingAttributes, textAlignment: textView.textAlignment)
            //            foregroundColor = Color(attributes[.foregroundColor] as? UIColor ?? UIColor.label)
            //            backgroundColor = Color(attributes[.backgroundColor] as? UIColor ?? UIColor.systemBackground)
        }
        .onDisappear {
            print("Disappearing.")
        }
        
    }
    
    var attributedText: NSAttributedString { textView.attributedText }
    var selectedRange: NSRange { textView.selectedRange }
    
    func toggleStrikethrough() {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        var isAllStrikethrough = true
        attributedString.enumerateAttribute(.strikethroughStyle,
                                            in: selectedRange,
                                            options: []) { (value, range, stopFlag) in
            let strikethrough = value as? NSNumber
            if strikethrough == nil {
                isAllStrikethrough = false
                stopFlag.pointee = true
            }
        }
        if isAllStrikethrough {
            attributedString.removeAttribute(.strikethroughStyle, range: selectedRange)
        } else {
            attributedString.addAttribute(.strikethroughStyle, value: 1, range: selectedRange)
        }
        updateAttributedText(with: attributedString)
    }
    
    func toggleUnderline() {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        var isAllUnderlined = true
        attributedString.enumerateAttribute(.underlineStyle,
                                            in: selectedRange,
                                            options: []) { (value, range, stopFlag) in
            let underline = value as? NSNumber
            if  underline == nil  {
                isAllUnderlined = false
                stopFlag.pointee = true
            }
        }
        if isAllUnderlined {
            // Bug in iOS 15 when all selected and underlined that I can't fix as yet
            attributedString.removeAttribute(.underlineStyle, range: selectedRange)
        } else {
            attributedString.addAttribute(.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: selectedRange)
        }
        updateAttributedText(with: attributedString)
    }
    
    func toggleBoldface() {
        toggleSymbolicTrait(.traitBold)
    }
    
    func toggleItalics() {
        toggleSymbolicTrait(.traitItalic)
    }
    
    private func toggleSymbolicTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        var isAll = true
        attributedString.enumerateAttribute(.font, in: selectedRange,
                                            options: []) { (value, range, stopFlag) in
            let uiFont = value as? UIFont
            if let descriptor = uiFont?.fontDescriptor {
                isAll = isAll && descriptor.symbolicTraits.intersection(trait) == trait
                if !isAll { stopFlag.pointee = true }
            }
        }
        attributedString.enumerateAttribute(.font, in: selectedRange,
                                            options: []) {(value, range, stopFlag) in
            let uiFont = value as? UIFont
            if  let descriptor = uiFont?.fontDescriptor {
                // Fix bug in largeTitle by setting bold weight directly
                var weight = descriptor.symbolicTraits.intersection(.traitBold) == .traitBold ? .bold : descriptor.weight
                weight = trait != .traitBold ? weight : (isAll ? .regular : .bold)
                if let fontDescriptor = isAll ? descriptor.withSymbolicTraits(descriptor.symbolicTraits.subtracting(trait))
                    : descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(trait)) {
                    attributedString.addAttribute(.font, value: UIFont(descriptor: fontDescriptor.withWeight(weight),
                                                                       size: descriptor.pointSize), range: range)
                }
            }
        }
        updateAttributedText(with: attributedString)
    }
    
    private func toggleSubscript() { toggleScript(sub: true) }
    
    private func toggleSuperscript() { toggleScript(sub: false) }
    
    private func toggleScript(sub: Bool = false) {
        let newOffset = sub ? -0.3 : 0.4
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        var isAllScript = true
        attributedString.enumerateAttributes(in: selectedRange,
                                             options: []) { (attributes, range, stopFlag) in
            let offset = attributes[.baselineOffset] as? CGFloat ?? 0.0
            if offset == 0.0 { //  normal
                isAllScript = false
            } else { // its super or subscript so set to normal
                // Enlarge font and remove baselineOffset
                var newFont : UIFont
                let descriptor: UIFontDescriptor
                if let font = attributes[.font] as? UIFont {
                    descriptor = font.fontDescriptor
                    newFont = UIFont(descriptor: descriptor, size: descriptor.pointSize/0.75)
                    attributedString.removeAttribute(.baselineOffset, range: range)
                    if descriptor.symbolicTraits.intersection(.traitItalic) == .traitItalic, let font = newFont.italic() {
                        newFont = font
                    }
                } else { newFont = UIFont.preferredFont(forTextStyle: .body) }
                attributedString.addAttribute(.font, value: newFont, range: range)
            }
        }
        attributedString.enumerateAttributes(in: selectedRange,
                                             options: []) {(attributes, range, stopFlag) in
            var newFont : UIFont
            let descriptor: UIFontDescriptor
            if let font = attributes[.font] as? UIFont {
                descriptor = font.fontDescriptor
                newFont = font
                if !isAllScript { // everything is already normal if isAllScript
                    attributedString.addAttribute(.baselineOffset, value: newOffset*descriptor.pointSize,
                                                  range: range)
                    newFont = UIFont(descriptor: descriptor, size: 0.75*descriptor.pointSize)
                }
                if descriptor.symbolicTraits.intersection(.traitItalic) == .traitItalic, let font = newFont.italic() {
                    newFont = font
                }
            } else { newFont = UIFont.preferredFont(forTextStyle: .body) }
            attributedString.addAttribute(.font, value: newFont, range: range)
        }
        updateAttributedText(with: attributedString)
    }
    
    
    private func alignText() {
        var textAlignment: NSTextAlignment
        switch textView.textAlignment {
        case .left: textAlignment = .center
        case .center: textAlignment = .right
        case .right: textAlignment = .left
        case .justified: textAlignment = .justified
        case .natural: textAlignment = .natural
        @unknown default: textAlignment = .left
        }
        textView.textAlignment = textAlignment
    }
    
    /// Add text attribute to text view
    private func textEffect<T: Equatable>(range: NSRange, key: NSAttributedString.Key, value: T, defaultValue: T) {
        if !range.isEmpty {
            let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableString.removeAttribute(key, range: range)
            mutableString.addAttributes([key : value], range: range)
            // Update parent
            textView.updateAttributedText(with: mutableString)
        } else {
            if let current = textView.typingAttributes[key], current as! T == value  {
                textView.typingAttributes[key] = defaultValue
            } else {
                textView.typingAttributes[key] = value
            }
        }
        textView.selectedRange = range // restore selection
    }
    
    private func adjustFontSize(isIncrease: Bool) {
        var selectedRangeAttributes: [(NSRange, [NSAttributedString.Key : Any])] {
            let textRange = textView.selectedRange
            if textRange.isEmpty { return [(textRange, textView.typingAttributes)]}
            var textAttributes: [(NSRange, [NSAttributedString.Key : Any])] = []
            textView.attributedText.enumerateAttributes(in: textRange) { attributes, range, stop in
                textAttributes.append((range,attributes))
            }
            return textAttributes
        }
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
    
    private func increaseFontSize() {
        adjustFontSize(isIncrease: true)
    }
    
    private func decreaseFontSize() {
        adjustFontSize(isIncrease: false)
    }
    
//    private func textFont(font: String) {
//        textView.textFont(name: font)
//    }
    
    func insertImage() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        let imagePicker = UIImagePickerController()
        //imagePicker.delegate = textView.delegate
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        textView.inputAccessoryViewController?.present(imagePicker, animated: true, completion: {})
    }
    
    // MARK: - Color Selection Button Actions
    private func selectColor() {
        let color = UIColor(toolbar.color)
        textEffect(range: textView.selectedRange, key: .foregroundColor, value: color, defaultValue: color)
    }
    
    private func selectBackground() {
        let color = UIColor(toolbar.background)
        textEffect(range: textView.selectedRange, key: .backgroundColor, value: color, defaultValue: color)
    }

}

//struct KeyBoardAddition_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyBoardAddition()
//    }
//}
