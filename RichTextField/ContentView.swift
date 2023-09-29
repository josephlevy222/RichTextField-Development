//
//  ContentView.swift
//  RichTextField
//
//  Created by Joseph Levy on 8/20/23.
//
import SwiftUI

let bText = "#   Large".markdownToAttributed()
let aText: AttributedString = AttributedString("Big").setFont(to: .largeTitle).setItalic().setBold() + (AttributedString(" Hello,",attributes: AttributeContainer().kern(3)).setFont(to: .title2).setItalic() + AttributedString(" world!",attributes: AttributeContainer().foregroundColor(.yellow).backgroundColor(.blue).baselineOffset(6)).setFont(to: .title2)).setBold() + AttributedString(" in body ").setFont(to: .body.weight(.ultraLight)) + bText.setBold()
let dumpfont = Font.body.weight(.ultraLight).italic().bold()

struct ContentView: View {
    
    @State var text : AttributedString
    
    @State var state: Int = 0
    var body: some View {
        VStack(alignment: .leading) {
                
                RichTextEditor(attributedText: $text, onCommit: {_ in})
                
                Text(text)
                
                Button("Change Text") {
                    state = state + 1
                    if state == 5 { state = 0 }
                    switch state {
                    case 0: text = aText
                    case 1: text = text.setItalic()
                    case 2: text = text.setBold();
                    case 3: text = text.setItalic()
                    case 4: text = text.setBold()
                    default: break
                    }
                }
            Spacer()
        }.padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(text: aText)
    }
}
