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
              title: "Quick Bookings",
              description: "Skip the lines! Reserve rides and play sessions effortlessly through the app"),
        .init(image: .init("onboarding-img-2", bundle: .main),
              title: "Track Playtime",
              description: "Monitor and manage your child's play history and favorite activities all in one place"),
        .init(image: .init("onboarding-img-3", bundle: .main),
              title: "Exclusive Offers & Rewards",
              description: "Unlock app-only discounts, promotions, and rewards. Enjoy more playtime while saving on every booking!"),
    ]
    
    private var nextTextView: some View {
        return Text(page + 1 == colors.count ? "Get started" : "Next")
            .frame(maxWidth: .infinity)
            .font(.custom("Poppins-Bold", size: 16))
            .foregroundStyle(
                LinearGradient(
                    colors: Color.gradient.primary,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    var body: some View {
        NavigationView {
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
                    NavigationLink(destination: AuthView()) {
                        Text("Skip")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundStyle(Color.text.black100)
                    }
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
                                .padding(.bottom, 2)
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
                        if page + 1 == colors.count {
                            NavigationLink(destination: AuthView()) {
                                nextTextView
                            }
                        } else {
                            nextTextView
                        }
                    })
                    Spacer()
                })
                .padding(.bottom)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
}

#Preview {
    OnboardingView()
}
