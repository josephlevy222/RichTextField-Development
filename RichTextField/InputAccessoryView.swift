//
//  InputAccessoryView.swift
//  TextView-Example
//
//  Created by Steven Zhang on 3/12/22.
//
//public enum EditorSection: CaseIterable {
//    case bold
//    case italic
//    case underline
//    case strikethrough
//    case subscriptButton
//    case superscript
//    case fontAdjustment
//    case textAlignment
//    case image
//    case color
//    case background
//    case keyboard
//}
import SwiftUI
/*
@available(iOS 13.0, *)
final class InputAccessoryView: UIInputView {
    private var accessorySections: Array<EditorSection>
    private var textFontName: String = UIFont.preferredFont(forTextStyle: .body).fontName
    
    private var attributedText : NSAttributedString { delegate.parent.textView.attributedText }
    private var selectedRange: NSRange { delegate.parent.textView.selectedRange }
    func updateAttributedText(with: NSAttributedString) {
        let textView = delegate.parent.textView
        let selection = textView.selectedRange
        textView.updateAttributedText(with: with)
        textView.selectedRange = selection
    }
    
    private let baseHeight: CGFloat = 44
    private let padding: CGFloat = 8
    private let buttonWidth: CGFloat = 32
    private let buttonHeight: CGFloat = 32
    private let cornerRadius: CGFloat = 6
    private let edgeInsets: CGFloat = 5
    private let selectedColor = UIColor.separator
    private let containerBackgroundColor: UIColor = .systemBackground
    private let toolBarsBackground: UIColor = .systemGroupedBackground
    private let colorConf = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    private var imageConf: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: min(buttonWidth, buttonHeight) * 0.7)
    }
    
    weak var delegate: TextEditorWrapper.Coordinator!
    
    // MARK: Input Accessory Buttons
    private lazy var stackViewSeparator: UIView = {
        let separator = UIView()
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = .secondaryLabel
        return separator
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        let spacerWidthConstraint = separator.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        return separator
    }()
    
    private lazy var colorSeparator: UIView = {
        let separator = UIView()
        let spacerWidthConstraint = separator.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        return separator
    }()
    
    private lazy var keyboardButton: UIButton = {
        let button = UIButton()
        // let keyboardButtonConf = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(hideKeyboard(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.tag = 12
        button.widthAnchor.constraint(equalToConstant: buttonWidth*1.5).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var increaseFontButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(increaseFontSize), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 9
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var decreaseFontButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "minus.circle", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(decreaseFontSize), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 8
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var textFontLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "\(Int(UIFont.systemFontSize))"
        label.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        return label
    }()
    
    private lazy var boldButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleBoldface(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "bold", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 1
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var italicButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleItalics(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "italic", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 2
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var underlineButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleUnderline(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "underline", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 3
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var strikethroughButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleStrikethrough(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "strikethrough", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 4
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var superscriptButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleSuperscript(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "textformat.superscript", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 6
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var subscriptButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleSubscript(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "textformat.subscript", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.tag = 5
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            alignmentButton.setImage(UIImage(systemName: self.textAlignment.imageName, withConfiguration: imageConf), for: .normal)
        }
    }
    
    private lazy var alignmentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: NSTextAlignment.left.imageName, withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(alignText(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 7
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var insertImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(insertImage(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 10
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    private lazy var fontSelectionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "textformat.size", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(showFontPalette(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    // MARK: Addtional Bars
    
    private let textColors: [UIColor] = [UIColor.label] +
    // From SwiftUI Colors
    [ .red, .orange, .yellow, .green, .blue, .purple ].map { UIColor($0)} +
    [ UIColor.systemBackground ]
    
    private lazy var colorButtons: [UIButton] = {
        var buttons: [UIButton] = []
        
        for color in textColors {
            let button = UIButton()
            button.tag = color == textColors.last ? 1 : 0
            button.setImage(UIImage(systemName: color == textColors.last ? "circle" : "circle.fill", withConfiguration: colorConf), for: .normal)
            button.tintColor = color == textColors.last ? .label : color
            button.addTarget(self, action: #selector(selectColor(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle", withConfiguration: colorConf), for: .normal)
        button.tintColor = UIColor.label
        button.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
        buttons.append(button)
        return buttons
    }()
    
    private lazy var backgroundButtons: [UIButton] = {
        var buttons: [UIButton] = []
        
        for color in textColors {
            let button = UIButton()
            button.tag = color == textColors.last ? 1 : 0
            button.setImage(UIImage(systemName: color == textColors.last ? "circle" : "circle.fill", withConfiguration: colorConf), for: .normal)
            button.tintColor = color == textColors.last ? .label : color
            button.addTarget(self, action: #selector(selectBackground(_:)), for: .touchUpInside)
            
            buttons.append(button)
        }
        
        return buttons
    }()
    
    private lazy var colorPicker: UIColorPickerViewController = {
        let picker = UIColorPickerViewController()
        return picker
    }()
    
    private lazy var colorPaletteBar: UIStackView = {
        var viewArray = {
            let label = UILabel()
            label.text = "Foreground"
            var viewArray : [UIView] = [label]
            viewArray.append(contentsOf: colorButtons)
            viewArray.append(colorSeparator)
            let label2 = UILabel()
            label2.text = " Background"
            viewArray.append(label2)
            viewArray.append(contentsOf: backgroundButtons)
            return viewArray
        }()
        
        let containerView = UIStackView(arrangedSubviews: viewArray)
        containerView.axis = .horizontal
        containerView.alignment = .leading
        containerView.spacing = padding/2
        containerView.backgroundColor = toolBarsBackground
        return containerView
    }()
    
    
    // TODO: Support Fonts Selection
    private lazy var fontPaletteBar: UIStackView = {
        let containerView = UIStackView()
        return containerView
    }()
    
    // MARK: - Initialization
    
    private var accessoryContentView: UIStackView
    
    init(frame: CGRect, inputViewStyle: UIInputView.Style, accessorySections: Array<EditorSection>) {
        self.accessoryContentView = UIStackView()
        self.accessorySections = accessorySections
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        setupAccessoryView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAccessoryView() {
        accessoryContentView.addArrangedSubview(toolbar)
        if accessorySections.contains(.color) {
            accessoryContentView.addArrangedSubview(colorPaletteBar)
        }
        
        accessoryContentView.axis = .vertical
        accessoryContentView.alignment = .center
        accessoryContentView.distribution = .fillProportionally
        
        backgroundColor = .secondarySystemBackground
        accessoryContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(accessoryContentView)
        NSLayoutConstraint.activate([
            accessoryContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            accessoryContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            accessoryContentView.topAnchor.constraint(equalTo: self.topAnchor),
            accessoryContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
 
    private lazy var buttonDictionary : [EditorSection : UIButton] =
    [.bold: boldButton, .italic: italicButton, .underline: underlineButton, .strikethrough: strikethroughButton,
     .subscriptButton: subscriptButton, .superscript: superscriptButton, .textAlignment: alignmentButton,
     .fontAdjustment: decreaseFontButton, .image: insertImageButton, .keyboard: keyboardButton]
    
    private var toolbar: UIStackView {
        let stackView = UIStackView()
        for section in EditorSection.allCases {
            if section == .keyboard { stackView.addArrangedSubview(separator) }
            if accessorySections.contains(section), let button = buttonDictionary[section] {
                stackView.addArrangedSubview(button)
            }
            if section == .fontAdjustment {
                stackView.addArrangedSubview(textFontLabel)
                stackView.addArrangedSubview(increaseFontButton)
            }
        }
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = padding
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = toolBarsBackground
        
        return stackView
    }
    
    // MARK: - Button Actions
    
    @objc private func showFontPalette(_ button: UIButton) {
        //
    }
    
    @objc private func hideKeyboard(_ button: UIButton) {
        delegate.hideKeyboard()
    }
    
    @objc func toggleStrikethrough(_ sender: Any?) {
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
    
    @objc public override func toggleUnderline(_ sender: Any?) {
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
    
    @objc override func toggleBoldface(_ sender: Any?) {
        toggleSymbolicTrait(sender, trait: .traitBold)
    }
    
    @objc override func toggleItalics(_ sender: Any?) {
        toggleSymbolicTrait(sender, trait: .traitItalic)
    }
    
    private func toggleSymbolicTrait(_ sender: Any?, trait: UIFontDescriptor.SymbolicTraits) {
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
    
    @objc func toggleSubscript(_ sender: Any?) { toggleScript(sender, sub: true) }
    
    @objc func toggleSuperscript(_ sender: Any?) { toggleScript(sender, sub: false) }
    
    private func toggleScript(_ sender: Any?, sub: Bool = false) {
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
    
    @objc private func alignText(_ button: UIButton) {
        switch textAlignment {
        case .left: textAlignment = .center
        case .center: textAlignment = .right
        case .right: textAlignment = .left
        case .justified: textAlignment = .justified
        case .natural: textAlignment = .natural
        @unknown default: textAlignment = .left
        }
        delegate.textAlign(align: textAlignment)
    }
    
    @objc private func increaseFontSize() {
        delegate.adjustFontSize(isIncrease: true)
    }
    
    @objc private func decreaseFontSize() {
        delegate.adjustFontSize(isIncrease: false)
    }
    
    @objc private func textFont(font: String) {
        delegate.textFont(name: font)
    }
    
    @objc private func insertImage(_ button: UIButton) {
        delegate.insertImage()
    }
    
    // MARK: - Color Selection Button Actions
    @objc private func selectColor(_ button: UIButton) {
        delegate.textColor(color: button.tag == 1 ? textColors.last! : button.tintColor)
    }
    
    @objc private func selectBackground(_ button: UIButton) {
        delegate.textBackground(color: button.tag == 1 ? textColors.last!  : button.tintColor)
    }
    
    @objc private func pickColor(_ button: UIButton) {
        let picker = UIColorPickerViewController()
        let controller=delegate.parent.controller
        controller.present(picker, animated: true) { button.tintColor = picker.selectedColor }
    }
    
    private func selectedButton(_ button: UIButton, isSelected: Bool) {
        button.layer.cornerRadius = isSelected ? cornerRadius : 0
        button.layer.backgroundColor = isSelected ? selectedColor.cgColor : UIColor.clear.cgColor
    }
    
    func updateToolbar(typingAttributes: [NSAttributedString.Key : Any], textAlignment: NSTextAlignment) {
        alignmentButton.setImage(UIImage(systemName: textAlignment.imageName, withConfiguration: imageConf), for: .normal)

        if let font = typingAttributes[.font] as? UIFont {
            let fontSize = font.pointSize
            
            textFontLabel.text = "\(Int(fontSize))"
            let isBold = font.contains(trait: .traitBold)
            let isItalic = font.contains(trait: .traitItalic)
            selectedButton(boldButton, isSelected: isBold)
            selectedButton(italicButton, isSelected: isItalic)
        } else {
            selectedButton(boldButton, isSelected: false)
            selectedButton(italicButton, isSelected: false)
        }
        
        if let style = typingAttributes[.underlineStyle] as? Int {
            selectedButton(underlineButton, isSelected: style == NSUnderlineStyle.single.rawValue )
        } else {
            selectedButton(underlineButton, isSelected: false)
        }
        
        if let style = typingAttributes[.strikethroughStyle] as? Int {
            selectedButton(strikethroughButton, isSelected: style == NSUnderlineStyle.single.rawValue)
        }  else {
            selectedButton(strikethroughButton, isSelected: false)
        }
    
        let offset = typingAttributes[.baselineOffset] as? CGFloat ?? 0.0
        selectedButton(superscriptButton, isSelected: offset > 0.0)
        selectedButton(subscriptButton, isSelected: offset < 0.0)
    
        
        let textColor = typingAttributes[.foregroundColor] as? UIColor
        for button in colorButtons {
            var systemName = "circle"
            var color : UIColor { button.tag == 1 ? textColors.last! : button.tintColor }
            if color == textColor ?? .label { systemName = "checkmark.circle" }
            if button.tag == 0 { systemName += ".fill" }
            button.setImage(UIImage(systemName: systemName, withConfiguration: colorConf), for: .normal)
        }
        
        let backColor = typingAttributes[.backgroundColor] as? UIColor
        for button in backgroundButtons {
            var systemName = "circle"
            var color : UIColor { button.tag == 1 ? textColors.last! : button.tintColor }
            if color == backColor ?? textColors.last! { systemName = "checkmark.circle" }
            if button.tag == 0 { systemName += ".fill" }
            button.setImage(UIImage(systemName: systemName, withConfiguration: colorConf), for: .normal)
        }
    }
}
 ***/
