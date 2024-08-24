import SwiftUI

struct OnboardingView: View {
    struct Page {
        let image: Image
        let title: String
        let description: String
    }
    
    @State private var colors: [Color] = [.red, .green, .blue]
    @State private var offset: CGFloat = 0
    @State private var page = 0
    @State private var pages: [Page] = [
        .init(image: .init("onboarding-img-1", bundle: .main), 
              title: "Choose package",
              description: "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit."),
        .init(image: .init("onboarding-img-2", bundle: .main),
              title: "Make Payment",
              description: "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit."),
        .init(image: .init("onboarding-img-3", bundle: .main),
              title: "Enjoy your order",
              description: "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit."),
    ]
    
    var body: some View {
        VStack {
            HStack(content: {
                HStack(spacing: 0, content: {
                    Text("\(page + 1)")
                        .font(.custom("Poppins-SemiBold", size: 18))
                    Text("/3")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundStyle(Color.text.black40)
                })
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("Skip")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundStyle(Color.text.black100)
                })
            })
            .padding()
            TabView(selection: $page,
                    content:  {
                ForEach(colors.indices, id: \.self) { index in
                    VStack {
                        pages[index].image
                        Text(pages[index].title)
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundStyle(Color.text.black100)
                            .padding(.bottom)
                        Text(pages[index].description)
                            .multilineTextAlignment(.center)
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundStyle(Color.text.black40)
                        Spacer()
                    }
                    .padding()
                }
            }).tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            HStack(content: {
                Spacer()
                Button(action: {
                    withAnimation {
                        if page - 1 < 0 {
                            return
                        }
                        page -= 1
                    }
                }, label: {
                    Text("Prev")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundStyle(Color.text.black60)
                })
                .hidden(page == 0)
                .frame(maxWidth: .infinity)
                Spacer()
                HStack(spacing: 15, content: {
                    ForEach(colors.indices, id:\.self) { index in
                        Capsule()
                            .fill(page == index ? Color(hex: "#17223B") : Color(hex: "#17223B", opacity: 0.20))
                            .frame(width: page == index ? 40 : 7, height: 7, alignment: .center)
                            .animation(.default, value: page)
                    }
                })
                Spacer()
                Button(action: {
                    withAnimation {
                        if page + 1 > colors.count - 1 {
                            return
                        }
                        page += 1
                    }
                }, label: {
                    Text(page + 1 == colors.count ? "Get started" : "Next")
                        .frame(maxWidth: .infinity)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundStyle(
                            LinearGradient(
                                colors: Color.gradient.primary,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                })
                Spacer()
            })
            .padding(.bottom)
        }
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

#Preview {
    OnboardingView()
}
