import SwiftUI

struct TestView: View {
    private var tosText: (String) -> AttributedString =  { text in
        var string = AttributedString(text)
        string.font = .custom("Poppins-Regular", size: 14)
        string.foregroundColor = Color.text.black60
        
        return string
    }
    
    private var tosLink: (String) -> AttributedString =  { text in
        var string = AttributedString(text)
        string.font = .custom("Poppins-Medium", size: 14)
        string.foregroundColor = Color.text.black80
        string.link = URL(string: "https://google.com")
        string.underlineStyle = Text.LineStyle(pattern: .solid, color: Color.text.black80)
        
        return string
    }
    
    var body: some View {
//        Text(tosText("By continuing, you accept Swee’s ") + tosLink("Terms and Condition") + tosText(" and ") + tosLink("Privacy Policy"))
//            .lineLimit(0)
//            .multilineTextAlignment(.center)
        Text(tosText("By continuing, you accept Swee’s ")) + Text(tosLink("Terms and Condition")) + Text(tosText(" and ")) + Text(tosLink("Privacy Policy"))
        
        Link(destination: URL(string: "https://google.com")!, label: {
            Image(systemName: "envelope.fill")
            Text("Send Email")
        })
        

    }
}

#Preview {
    TestView()
}
