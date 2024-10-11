import SwiftUI

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var api: API
    @State var children: [Child] = [.init(name: "")]
    private(set) var onSave: (_ children: [Child]) -> Void
    
    init(children: [Child], onSave: @escaping (_: [Child]) -> Void) {
        self.children = [.init(name: "")] + children
        self.onSave = onSave
    }
    
    var allDataFilled: Bool {
        children.reduce(true) { valid, model in
            if !valid {
                return valid
            }
            return model.isValid
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(spacing: 10) {
                        ForEach(children.indices, id: \.self) { index in
                            HStack {
                                Rectangle()
                                    .fill(Color.text.black10)
                                    .frame(height: 1)
                                Text("Child \(index + 1)")
                                    .font(.custom("Poppins-Medium", size: 12))
                                    .foregroundStyle(Color.text.black40)
                                Rectangle()
                                    .fill(Color.text.black10)
                                    .frame(height: 1)
                            }
                            VStack {
                                ChildDetailsView(child: children[index]) { name, date in
                                    var child = children[index]
                                    child.name = name
                                    child.dob = date
                                    children[index] = child
                                }
                            }
                        }
                        Button {
                            children.append(.init(name: ""))
                        } label: {
                            Text("Add another child")
                                .font(.custom("Roboto-Bold", size: 16))
                                .foregroundStyle(LinearGradient(colors: Color.gradient.primary, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 16)
                        .buttonStyle(OutlineButton(strokeColor: Color.primary.brand, cornerRadius: 30))

                    }
                }
                .padding()
            }
        }
        .customNavigationTitle("Add child")
        .customNavTrailingItem {
            AsyncButton {
                let children = await save(children: children)
                onSave(children)
                dismiss()
            } label: {
                Text("Save")
                    .font(.custom("Poppins-Medium", size: 16))
            }
            .disabled(!allDataFilled)
            .tint(Color.primary.brand)
        }
    }
    
    func save(children: [Child]) async -> [Child] {
        return await withTaskGroup(of: Child?.self) { group in
            for child in children {
                group.addTask {
                    do {
                        if let id = child.id {
                            return try await api.updateChild(with: id,
                                                             name: child.name,
                                                             dob: child.dob).toLocal()
                        } else {
                            return try await api.addChild(with: child.name,
                                                          dob: child.dob).toLocal()
                        }
                    } catch {
                        return child.id != nil ? child : nil // we're failing silently here
                    }
                }
            }

            var results: [Child] = []
            for await result in group {
                guard let child = result else {
                    continue
                }
                results.append(child)
            }

            return results
        }
    }
}

struct ChildDetailsView: View {
    var child: Child
    var onEdit: (_ name: String, _ dob: Date?) -> Void
    @State var name: String
    @State var dob: Date = .now
    @FocusState private var isKeyboardShowing: Bool
    
    init(child: Child, onEdit: @escaping (_: String, _: Date?) -> Void) {
        self.child = child
        self.onEdit = onEdit
        self.name = child.name
        self.dob = child.dob ?? .now
        self.isKeyboardShowing = isKeyboardShowing
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Name of the child")
                .font(.custom("Poppins-Regular", size: 14))
            TextField("", text: $name, prompt: Text("Add name")
                .font(.custom("Poppins-SemiBold", size: 18))
            )
            .font(.custom("Poppins-Medium", size: 18))
            .submitLabel(.done)
            .foregroundStyle(Color.text.black80)
            .onChange(of: name, perform: { newValue in
                onEdit(newValue, Calendar.current.isDateInToday(dob) ? child.dob : dob)
            })
            //            .onSubmit {
            //                onEdit(name, Calendar.current.isDateInToday(dob) ? child.dob : dob)
            //            }
            Rectangle()
                .fill(Color.text.black10)
                .frame(height: 1)
            VStack(alignment: .leading) {
                Text("Date of birth")
                    .font(.custom("Poppins-Regular", size: 14))
                HStack {
                    Text(child.dob != nil ? "\(child.dob!.formatted(date: .numeric, time: .omitted))" : "DD/MM/YYYY")
                        .font(.custom("Poppins-Medium", size: child.dob != nil ? 16 : 14))
                        .foregroundStyle(child.dob != nil ? Color.text.black80 : Color.text.black60)
                        .overlay {
                            DatePicker(
                                "",
                                selection: $dob,
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                            .blendMode(.destinationOver)
                            .onChange(of: dob, perform: { value in
                                onEdit(child.name, dob)
                            })
                        }
                    Spacer()
                    Image("chevron-down")
                }
                .padding(.vertical, 15)
                .padding(.leading, 20)
                .padding(.trailing, 12)
                .background(RoundedRectangle(cornerRadius: 8)
                    .stroke(style: .init(lineWidth: 1))
                    .foregroundStyle(Color(hex: "#C8C8C8"))
                )
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        )
    }
}

#Preview {
    CustomNavView {
        AddChildView(children: []) { _ in
            
        }
    }
}
