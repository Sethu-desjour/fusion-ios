import SwiftUI

struct ProfileView: View {
    struct RowData {
        let title: String
        let description: String?
        let leadingIcon: Image?
        let trailingIcon: Image?
        let action: () -> Void
        let tint: Color?

        init(title: String, description: String? = nil, leadingIcon: Image? = nil, trailingIcon: Image = Image("forward"), tint: Color? = nil, action: @escaping () -> Void) {
            self.title = title
            self.description = description
            self.leadingIcon = leadingIcon
            self.trailingIcon = trailingIcon
            self.tint = tint
            self.action = action
        }
    }
    
    @EnvironmentObject private var api: API
    @EnvironmentObject private var appRootManager: AppRootManager
    @Environment(\.tabIsShown) private var tabIsShown
    
    @State private var profileProgress: Double = 0.6
    @State private var sections: [[RowData]] = []
    
    func setupSections() {
        sections = [
            [
                .init(title: "Location", description: "Singapore", leadingIcon: Image("location")) {
                    
                },
                .init(title: "Language", description: "English", leadingIcon: Image("globe")) {
                    
                },
                .init(title: "Email ID", description: "Add email ID", leadingIcon: Image("mail")) {
                    
                },
                .init(title: "Payment", description: "Add payment", leadingIcon: Image("card")) {
                    
                },
                .init(title: "Gender", description: "Add gender", leadingIcon: Image("gender")) {
                    
                },
            ],
            [
                .init(title: "Child", description: "No info added", leadingIcon: Image("person-add")) {
                    
                },
            ],
            [
                .init(title: "Help Center", leadingIcon: Image("help")) {
                    
                },
                .init(title: "Terms & Condition", leadingIcon: Image("receipt")) {
                    
                },
                .init(title: "Rate our app", leadingIcon: Image("raiting")) {
                    
                },
            ],
            [
                .init(title: "Logout", trailingIcon: Image("logout")) {
                    Task {
                        await api.signOut()
                        appRootManager.currentRoot = .authentication
                    }
                },
            ],
            [
                .init(title: "Delete profile", trailingIcon: Image("delete"), tint: .red) {
                    
                },
            ],
        ]
    }
    
    var body: some View {
        CustomNavView {
            ZStack(alignment: .top) {
                VStack {
                    LinearGradient(colors: [Color.secondary.brand, Color.white, Color.white], startPoint: .init(x: 0.5, y: 0), endPoint: .bottomLeading)
                        .frame(maxWidth: .infinity, maxHeight: 500)
                    Spacer()
                }
                .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Image("avatar")
                            VStack(alignment: .leading, spacing: 4) {
                                Text(api.user?.name ?? "")
                                    .font(.custom("Poppins-SemiBold", size: 18))
                                    .foregroundStyle(Color.text.black100)
                                if let phone = api.user?.phone, !phone.isEmpty {
                                    Text(phone)
                                        .font(.custom("Poppins-Medium", size: 14))
                                        .foregroundStyle(Color.text.black60)
                                }
                                CustomNavLink(destination: EditBasicInfoView()) {
                                    HStack(alignment: .center, spacing: 3) {
                                        Text("Edit basic info")
                                            .font(.custom("Poppins-Medium", size: 14))
                                        Image("back")
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                            .rotationEffect(.degrees(180))
                                            .padding(.top, 1)
                                    }
                                    .foregroundStyle(Color.primary.brand)
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 34)
                        HStack {
                            CircularProgressView(progress: $profileProgress)
                                .frame(width: 40, height: 40)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Complete your profile")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundStyle(.white)
                                Text("Fill up a few missing steps to win exciting rewards")
                                    .font(.custom("Poppins-Medium", size: 12))
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                            Spacer()
                            Image("arrow-right")
                                .padding(4)
                                .background {
                                    Circle()
                                        .fill(.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(LinearGradient(colors: Color.gradient.secondary, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        ForEach(sections.indices, id: \.self) { sectionIndex in
                            let section = sections[sectionIndex]
                            VStack(spacing: 0) {
                                ForEach(section.indices, id: \.self) { index in
                                    let row = section[index]
                                    Row(row: row, hideDivider: index == 0)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                            )
                        }
                        ReferalCard(banner: .init(title: "Refer a friend and earn rewards ✨", description: "Enjoy a free Zoomoov ride for each friend who signs up through your referral, and your friend gets a free ride too!", buttonTitle: "Share", background: .image(URL(string: "https://i.ibb.co/LpYWLfQ/referal-bg-3x.png")!), badgeImage: URL(string: "https://i.ibb.co/qkHf8XZ/badge-1-3x.png")))
                    }
                    .padding()
                    .padding(.bottom, 60)
                    .customNavBarHidden(true)
                }
            }
            .onAppear(perform: {
                setupSections()
                tabIsShown.wrappedValue = true
            })
        }
    }
    
    struct Row: View {
        var row: RowData
        var hideDivider: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                if !hideDivider {
                    Divider()
                        .background(row.tint != nil ? row.tint! : Color.text.black10)
                        .padding(.horizontal, 16)
                }
                HStack(spacing: 0) {
                    if let leadingIcon = row.leadingIcon {
                        leadingIcon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(row.tint != nil ? row.tint! : Color.text.black60)
                            .padding(.trailing, 10)
                    }
                    VStack(alignment: .leading) {
                        Text(row.title)
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundStyle(row.tint != nil ? row.tint! : Color.text.black80)
                        if let description = row.description {
                            Text(description)
                                .font(.custom("Poppins-Medium", size: 12))
                                .foregroundStyle(row.tint != nil ? row.tint! : Color.text.black40)
                        }
                    }
                    Spacer()
                    if let trailingIcon = row.trailingIcon {
                        trailingIcon
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(row.tint != nil ? row.tint! : Color.text.black40)
                    }
                    
                }
                .padding()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                row.action()
            }
        }
    }
}
struct CircularProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    .white.opacity(0.1),
                    lineWidth: 4
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .white,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppRootManager())
        .environmentObject(API())
}
