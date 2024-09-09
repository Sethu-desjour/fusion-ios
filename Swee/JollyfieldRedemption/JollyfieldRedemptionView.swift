import SwiftUI

struct ChildModel: Equatable, Hashable {
    var name: String = ""
    var dob: Date?
}

struct RedemptionScanView: View {
    struct Model {
        let header: String
        let title: String
        let qr: Image
        let description: String
        let actionTitle: String
    }
    //    @Binding var model: ZoomoovRedemptionModel
    var model: Model
    var closure: (() -> Void)?
    
    var body: some View {
        VStack {
            Text(model.header)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
            model.qr
                .padding(.bottom, 8)
            Text(model.title)
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundStyle(Color.text.black100)
            Text(model.description)
                .font(.custom("Poppins-Medium", size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.text.black60)
                .padding(.bottom, 37)
            Button {
                // @todo make request
                closure?()
            } label: {
                HStack {
                    Text(model.actionTitle)
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(OutlineButton(strokeColor: Color.primary.brand))
            .padding(.bottom, 16)
        }
    }
}

struct RedemptionLoadingView: View {
    struct Model {
        let header: String
        let title: String
    }
    //    @Binding var model: ZoomoovRedemptionModel
    var model: Model
    var closure: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .top) {
            Text(model.header)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
            VStack {
                Image("spinner")
                    .padding(.top, 150)
                    .onTapGesture {
                        closure?()
                    }
                    .padding(.bottom, 22)
                Text(model.title)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.text.black100)
                    .padding(.bottom, 150)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct RedemptionCompletedView: View {
    struct Model {
        let header: String
        let title: String
        let description: String
        let actionTitle: String
    }
    //    @Binding var model: ZoomoovRedemptionModel
    var model: Model
    var closure: (() -> Void)?
    
    var body: some View {
        VStack {
            Text(model.header)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundStyle(Color.text.black100)
                .padding(.bottom, 32)
            Image("checkout-success")
                .resizable()
                .scaledToFill()
                .frame(width: 164, height: 136)
            Text(model.title)
                .font(.custom("Poppins-SemiBold", size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 39)
                .foregroundStyle(Color.text.black100)
            Button {
                // @todo make request
                closure?()
            } label: {
                HStack {
                    Text(model.actionTitle)
                        .font(.custom("Roboto-Bold", size: 16))
                }
                .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(OutlineButton(strokeColor: Color.primary.brand))
            .padding(.top, 44)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
}


struct JollyfieldRedemptionView: View {
    enum RedemptionStep {
        case qrStart
        case scanningStart
        case sessionStarted
        case qrEnd
        case scanningEnd
        case sessionEnded
    }
    
    @Environment(\.tabIsShown) private var tabIsShown
    @Environment(\.dismiss) private var dismiss
    @State private var children: [ChildModel] = [.init(name: "Johnny Depp", dob: .now), .init(name: "Charlee Sheen", dob: .now)]
    @State private var selectedChildren: Set<ChildModel> = .init()
    @State private var availableTime: TimeInterval = 5400
    @State var hidden = true
    @State var tempStep: RedemptionStep = .qrStart
    
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
                    self.children.append(contentsOf: children)
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
        
        if children.isEmpty || sessionOngoing {
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
            .foregroundStyle(Color.primary.brand)
            .padding(.top, 50)
            .padding(.bottom, cardHeight * CGFloat(multiplier) + cardHeight / 2 + (vPaddingBetweenCards * CGFloat(multiplier)) + heightOfDisclaimer)
            .padding(.horizontal, -16)
    }
    
    func selectedOutline(_ isSelected: Bool) -> AnyView {
        if isSelected && !sessionOngoing {
            return AnyView(RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style:  StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.primary.brand))
        } else {
            return AnyView(RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1))
        }
    }
    
    func buttonOutline(_ isSelected: Bool) -> AnyView {
        if isSelected {
            return AnyView(RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.primary.lighter.opacity(0.5))
            )
        } else {
            return AnyView(RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(Color.text.black100)
            )
        }
    }
    
    var alottedTime: TimeInterval {
        if selectedChildren.isEmpty {
            return 0
        }
        
        return availableTime / Double(selectedChildren.count)
    }
    
    var sessionOngoing: Bool {
        return tempStep == .qrEnd || tempStep == .scanningEnd
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack {
                            VStack {
                                VStack {
                                    Text("\(availableTime.toString()) Hr")
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
                                                    if sessionOngoing {
                                                        return
                                                    }
                                                    
                                                    if isSelected {
                                                        selectedChildren.remove(child)
                                                    } else {
                                                        selectedChildren.insert(child)
                                                    }
                                                } label: {
                                                    HStack {
                                                        Spacer()
                                                        Text(isSelected ? "Time alotted : \(alottedTime.toString()) Hr" : "Select child")
                                                            .font(.custom("Poppins-SemiBold", size: 16))
                                                            .foregroundStyle(isSelected ? Color.primary.dark : Color.text.black100)
                                                        Spacer()
                                                    }
                                                    .contentShape(Rectangle())
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(buttonOutline(isSelected))
                                                .buttonStyle(EmptyStyle())
                                            }
                                            .padding()
                                            .background(selectedOutline(isSelected))
                                            .background(.white)
                                        }
                                        Text("*Select child to start the session")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(Color.text.black60)
                                            .hidden(sessionOngoing)
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
                        if sessionOngoing {
                            Button {
                                // @todo make request
                                tempStep = .qrEnd
                                hidden = false
                            } label: {
                                HStack {
                                    Text("End session")
                                        .font(.custom("Roboto-Bold", size: 16))
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(OutlineButton(strokeColor: .red))
                        } else {
                            Button {
                                // @todo make request
                                if selectedChildren.isEmpty {
                                    return
                                }
                                hidden = false
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
                    }
                    .padding([.leading, .trailing, .top], 16)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.text.black10), alignment: .top)
                }
                .background(Color.background.white)
                BottomSheet(hide: $hidden, shouldDismissOnBackgroundTap: false) {
                    switch $tempStep.wrappedValue {
                    case .qrStart:
                        RedemptionScanView(model: .init(header: "Start session", title: "Scan QR to start your ride", qr: Image("qr"), description: "Show this QR code at the counter, our staff will scan this QR to mark your presence", actionTitle: "Verify")) {
                            $tempStep.wrappedValue = .scanningStart
                        }
                    case .scanningStart:
                        RedemptionLoadingView(model: .init(header: "Start session", title: "Scanning")) {
                            $tempStep.wrappedValue = .sessionStarted
                        }
                    case .sessionStarted:
                        RedemptionCompletedView(model: .init(header: "", title: "Session started", description: "", actionTitle: "Close")) {
                            hidden = true
                            $tempStep.wrappedValue = .qrEnd
                        }
                    case .qrEnd:
                        RedemptionScanView(model: .init(header: "End Session", title: "Scan QR to end your ride", qr: Image("qr"), description: "Show this QR code at the counter, our staff will scan this QR to mark your presence", actionTitle: "Verify")) {
                            $tempStep.wrappedValue = .scanningEnd
                        }
                    case .scanningEnd:
                        RedemptionLoadingView(model: .init(header: "End session", title: "Scanning")) {
                            $tempStep.wrappedValue = .sessionEnded
                        }
                        
                    case .sessionEnded:
                        RedemptionCompletedView(model: .init(header: "", title: "Session ended!", description: "Remaining time left 0:15 hr", actionTitle: "Okay")) {
                            hidden = true
                            $tempStep.wrappedValue = .qrStart
                        }
                    }
                }
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
                    } else if sessionOngoing {
                        Button {
                            // @todo show Help UI
                        } label: {
                            HStack(spacing: 4) {
                                Text("Help")
                                    .font(.custom("Poppins-Medium", size: 16))
                                Image(systemName: "questionmark.circle")
                                    .font(.callout.weight(.medium))
                            }
                            .foregroundStyle(Color.primary.brand)
                            .padding(.bottom, 10)
                        }
                    } else {
                        NavigationLink(destination: AddChildView { children in
                            self.children.append(contentsOf: children)
                        }) {
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
