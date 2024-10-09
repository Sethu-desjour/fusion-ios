import SwiftUI

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
    @EnvironmentObject private var api: API
    
    @State var merchant: WalletMerchant
    @StateObject private var viewModel = JollyfieldRedemptionViewModel()
    @State private var selectedChildren: Set<Child> = .init()
    
    @State var hidden = true
    @State var tempStep: RedemptionStep = .qrStart
    
    var indexOfLastSelectedChild: Int {
        let lastChild = viewModel.children.last { child in
            selectedChildren.contains { selectedChild in
                selectedChild == child
            }
        }
        
        return viewModel.children.firstIndex { $0 == lastChild } ?? 0
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
            CustomNavLink(destination: AddChildView(children: viewModel.children) { children in
                viewModel.children = children
            }) {
                HStack {
                    Text("Add child")
                        .font(.custom("Roboto-Bold", size: 16))
                    Image("plus")
                }
                .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 24)
            .padding(.horizontal, 28)
            .padding(.bottom, 60)
        }
    }
    
    var dottedOutline: some View {
        
        if viewModel.children.isEmpty || sessionOngoing {
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
        let multiplier = viewModel.children.count - 1 - index // since we're pushing the lower side of the dotted line, I need to know how many cards up I need to push
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
        
        return viewModel.availableTime / Double(selectedChildren.count)
    }
    
    var sessionOngoing: Bool {
        return tempStep == .qrEnd || tempStep == .scanningEnd
    }
    
    var shouldDismissOnTap: Bool {
        return tempStep == .qrStart || tempStep == .qrEnd
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        VStack {
                            VStack {
                                Text("\(viewModel.availableTime.toString()) Hr")
                                    .font(.custom("Roboto-Bold", size: 32))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 2)
                                Text("Total Time")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 2)
                            }
                            .frame(maxWidth: viewModel.children.isEmpty ? nil : .infinity, maxHeight: 100)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 21)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(Color.black.opacity(0.3))
                            )
                            .background(RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            HStack(spacing: 0) {
                                if let validUntilDate = viewModel.validUntilDate {
                                    Text("Valid until ")
                                        .foregroundStyle(Color.text.black60)
                                        .font(.custom("Poppins-Medium", size: 12))
                                    Text("\(validUntilDate.formatted(date: .abbreviated, time: .omitted))")
                                        .foregroundStyle(Color.text.black100)
                                        .font(.custom("Poppins-Medium", size: 12))
                                }
                            }
                            .padding(.bottom, 16)

                            if viewModel.children.isEmpty {
                                emptyUI
                            } else {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(viewModel.children.indices, id: \.self) { index in
                                        let child = viewModel.children[index]
                                        let isSelected = selectedChildren.contains(child)
                                        VStack(alignment: .leading) {
                                            Text(viewModel.children[index].name)
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
                                                    Text(isSelected ? "Time \(sessionOngoing ? "remaining" : "alotted") : \(alottedTime.toString()) Hr" : "Select child")
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
                                        .hidden(!selectedChildren.isEmpty)
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
                                Spacer()
                                Text("End session")
                                    .font(.custom("Roboto-Bold", size: 16))
                                Spacer()
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
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
                                Image("timer")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButton())
                    }
                }
                .padding([.leading, .trailing, .top], 16)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.text.black10), alignment: .top)
            }
            .background(Color.background.white)
        }
        .onAppear(perform: {
            viewModel.api = api
            viewModel.merchant = merchant
            Task {
                try? await viewModel.fetch()
            }
            tabIsShown.wrappedValue = false
        })
        .customBottomSheet(hidden: $hidden) {
            switch $tempStep.wrappedValue {
            case .qrStart:
                RedemptionScanView(model: .init(header: "Start session", title: "Check - in", qr: Image("qr"), description: "Show this QR code at the counter, our staff will scan this QR to mark your presence", actionTitle: "Refresh")) {
                    $tempStep.wrappedValue = .scanningStart
                }
            case .scanningStart:
                RedemptionLoadingView(model: .init(header: "Start session", title: "Scanning")) {
                    $tempStep.wrappedValue = .sessionStarted
                }
            case .sessionStarted:
                RedemptionCompletedView(model: .init(header: "", title: "Session started!", description: "", actionTitle: "Okay")) {
                    hidden = true
                    $tempStep.wrappedValue = .qrEnd
                }
            case .qrEnd:
                RedemptionScanView(model: .init(header: "End Session", title: "Check - out", qr: Image("qr"), description: "Show this QR code at the counter, our staff will scan this QR to end your session", actionTitle: "Refresh")) {
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
        .customNavigationTitle("Jollyfield")
        .customNavTrailingItem {
            if viewModel.children.isEmpty {
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
                }
            } else {
                CustomNavLink(destination: AddChildView(children: viewModel.children) { children in
                    viewModel.children = children
                }) {
                    Text("Add child")
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(Color.primary.brand)
                }
            }
        }
    }
}

#Preview {
    CustomNavView {
        JollyfieldRedemptionView(merchant: .empty)
    }
}
