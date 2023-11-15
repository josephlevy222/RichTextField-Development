//
//  ContentView.swift
//  RichTextField
//
//  Created by Joseph Levy on 8/20/23.
//
import SwiftUI

let bText = "#   Large".markdownToAttributed()
let aText: AttributedString = AttributedString("Big").setFont(to: .largeTitle).setItalic().setBold() + (AttributedString(" Hello,",attributes: AttributeContainer().kern(3)).setFont(to: .title2).setItalic() + AttributedString(" world",attributes: AttributeContainer().foregroundColor(.yellow).backgroundColor(.blue).baselineOffset(6)).setFont(to: .title2)).setBold() + AttributedString("!",attributes: AttributeContainer().foregroundColor(.yellow).backgroundColor(.blue)).setFont(to: .title2).setBold() + AttributedString(" in body ").setFont(to: .body.weight(.ultraLight))// + bText.setBold()
let dumpfont = Font.body.weight(.ultraLight).italic().bold()

struct ContentView: View {
    
    @State var text : AttributedString
    
    @State var state: Int = 0
    var body: some View {
        VStack(alignment: .leading) {
            Color.clear.frame(height: 100)
            
            RichTextEditor(attributedText: $text, onCommit: {_ in})
            
            Text(text)
            
            Button("Change Text from state: \(state)") {
                state = state + 1
                if state == 5 { state = 0 }
                switch state {
                case 0: text = aText
                case 1: text = text.setItalic()
                case 2: text = text.setBold()
                case 3: text = text.setUnderline()
                case 4: text = text.setItalic()
                default: break
                }
            }
            ScrollView {
                Text(text.description)
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






























struct MyTextView: UIViewRepresentable {
    
    /// The underlying UITextView. This is a binding so that a parent view can access it. You do not assign this value. It is created automatically.
    @Binding var undoManager: UndoManager?
    
    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        
        // Expose the UndoManager to the caller. This is performed asynchronously to avoid modifying the view at an inappropriate time.
        DispatchQueue.main.async {
            undoManager = uiTextView.undoManager
        }
        
        return uiTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
    }
    
}

struct ContentView2: View {
    
    /// The underlying UndoManager. Even though it looks like we are creating one here, ultimately, MyTextView will set it to its internal UndoManager.
    @State private var undoManager: UndoManager? = UndoManager()
    
    var body: some View {
        NavigationView {
            MyTextView(undoManager: $undoManager)
                .toolbar {
                    ToolbarItem {
                        Button {
                            undoManager?.undo()
                        } label: {
                            Image(systemName: "arrow.uturn.left.circle")
                        }
                    }
                }
        }
    }
}
