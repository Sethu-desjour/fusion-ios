import SwiftUI

struct ChildModel: Equatable, Hashable {
    var name: String = ""
    var dob: Date?
}

struct JollyfieldRedemptionView: View {
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.dismiss) private var dismiss
    @State private var children: [ChildModel] = [.init(name: "Johnny Depp", dob: .now), .init(name: "Enrique Ilesias", dob: .now), .init(name: "Enrque Iglesias", dob: .now), .init(name: "nrique Iglesias", dob: .now)]
    @State private var selectedChildren: Set<ChildModel> = .init()
    
    var indexOfLastSelectedChild: Int {
        let lastChild = children.last { child in
            selectedChildren.contains { selectedChild in
                selectedChild == child
            }
        }
        
        return children.firstIndex { $0 == lastChild } ?? 0
    }
    
    var emptyUI: some View {
        VStack {
            Image("family")
            Text("No children found")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundStyle(Color.text.black80)
            Text("Add children details to continue using the coupons")
                .font(.custom("Poppins-Medium", size: 14))
                .padding(.horizontal, 28)
                .foregroundStyle(Color.text.black60)
                .multilineTextAlignment(.center)
            Button {
                // @todo make request
            } label: {
                NavigationLink(destination: AddChildView { children in
                    self.children = children
                }) {
                    HStack {
                        Text("Add child")
                            .font(.custom("Roboto-Bold", size: 16))
                        Image("plus")
                    }
                    .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(OutlineButton(strokeColor: Color.primary.brand, cornerRadius: 30))
            .padding(.top, 24)
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
    
    var dottedOutline: some View {
        
        if children.isEmpty {
            return RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.black.opacity(0.3))
                .padding(.top, 50)
                .padding(.bottom, 0)
                .padding(.horizontal, -16)
        }
        
        if selectedChildren.isEmpty {
            return RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.clear)
                .padding(.top, 50)
                .padding(.bottom, 0)
                .padding(.horizontal, -16)
        }
        
        let index = indexOfLastSelectedChild
        let multiplier = children.count - 1 - index // since we're pushing the lower side of the dotted line, I need to know how many cards up I need to push
        let cardHeight: CGFloat = 120
        let vPaddingBetweenCards: CGFloat = 16
        let heightOfDisclaimer: CGFloat = 24
        
        return RoundedRectangle(cornerRadius: 8)
            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
            .foregroundStyle(Color.black.opacity(0.3))
            .padding(.top, 50)
            .padding(.bottom, cardHeight * CGFloat(multiplier) + cardHeight / 2 + (vPaddingBetweenCards * CGFloat(multiplier)) + heightOfDisclaimer)
            .padding(.horizontal, -16)
    }
    
    func selectedOutline(_ isSelected: Bool) -> AnyView {
        if isSelected {
            return AnyView(RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style:  StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.primary.brand))
        } else {
            return AnyView(RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack {
                            VStack {
                                VStack {
                                    Text("01:30 Hr")
                                        .font(.custom("Roboto-Bold", size: 32))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 2)
                                    Text("Total Time")
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 2)
                                }
                                .frame(maxWidth: children.isEmpty ? nil : .infinity, maxHeight: 100)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 21)
                                .background(RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundStyle(Color.black.opacity(0.3))
                                    )
                                .background(RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.primary.brand)
                                    )
                                .padding(.bottom, 16)
                                if children.isEmpty {
                                    emptyUI
                                } else {
                                    VStack(alignment: .leading, spacing: 16) {
                                        ForEach(children.indices, id: \.self) { index in
                                            let child = children[index]
                                            let isSelected = selectedChildren.contains(child)
                                            VStack(alignment: .leading) {
                                                Text(children[index].name)
                                                    .font(.custom("Poppins-Medium", size: 18))
                                                    .foregroundStyle(Color.text.black80)
                                                Button {
                                                    if isSelected {
                                                        selectedChildren.remove(child)
                                                    } else {
                                                        selectedChildren.insert(child)
                                                    }
                                                } label: {
                                                    Text("Select child")
                                                        .font(.custom("Poppins-SemiBold", size: 16))
                                                        .foregroundStyle(Color.text.black100)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                                                    .foregroundStyle(Color.text.black100)
                                                    )
                                                .buttonStyle(EmptyStyle())
                                            }
                                            .padding()
                                            .background(selectedOutline(isSelected))
                                            .background(.white)
    //                                        .background(isSelected ? RoundedRectangle(cornerRadius: 8)
    //                                            .strokeBorder(style: StrokeStyle(lineWidth: 1))
    //                                            .foregroundStyle(Color.text.black100) : RoundedRectangle(cornerRadius: 12)
    //                                            .foregroundStyle(.white)
    //                                            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
    //                                        )
                                        }
                                        Text("*Select child to start the session")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(Color.text.black60)
                                    }
                                }
                            }
                            .background(dottedOutline)
                            .animation(.snappy, value: selectedChildren)
                            .padding(16)
                        }
                        .padding(.horizontal, 16)
                    }
                    VStack(spacing: 0) {
                        Button {
                            // @todo make request
                            children.append(contentsOf: [.init(name: "George Lucas", dob: .now), .init(name: "Henry Ford", dob: .now)])
                        } label: {
                            HStack {
                                Text("Start timer")
                                    .font(.custom("Roboto-Bold", size: 16))
                            }
                            .foregroundStyle(Color.background.white)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(EmptyStyle())
                    }
                    .padding([.leading, .trailing, .top], 16)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.text.black10), alignment: .top)
                }
                .background(Color.background.white)
            }
            .onWillAppear({
                tabIsShown.wrappedValue = false
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back")
                    }
                    .padding(.bottom, 10)
                }
                ToolbarItem(placement: .principal) {
                    Text("Jollyfield")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundStyle(Color.text.black100)
                        .padding(.bottom, 10)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if children.isEmpty {
                        Text("")
                    } else {
                        Button {
                            
                        } label: {
                            Text("Add child")
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundStyle(Color.primary.brand)
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    JollyfieldRedemptionView()
}
