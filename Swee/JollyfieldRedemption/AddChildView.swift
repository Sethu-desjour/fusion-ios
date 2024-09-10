import SwiftUI

struct ChildDetailsView: View {
    var child: ChildModel
    var onEdit: (_ name: String, _ dob: Date?) -> Void
    @State var name: String = ""
    @State var dob: Date = .now
    @FocusState private var isKeyboardShowing: Bool
    
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

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hidden = true
    @State private var children: [ChildModel] = [.init()]
    private(set) var onSave: (_ children: [ChildModel]) -> Void
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(children.count == 0 ? "How many children do you have?" : "Number of Children")
                        .font(.custom("Poppins-Regular", size: 14))
                    Button {
                        hidden = false
                    } label: {
                        HStack {
                            Text(children.count == 0 ? "Select number" : "\(children.count)")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundStyle(Color.text.black60)
                            Spacer()
                            Image("chevron-down")
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 15)
                        .padding(.leading, 20)
                        .padding(.trailing, 12)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(style: .init(lineWidth: 1))
                            .foregroundStyle(Color(hex: "#C8C8C8"))
                        )
                        .padding(.bottom, 16)
                    }
                    .buttonStyle(EmptyStyle())
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
                    }
                }
                .padding()
            }
            BottomSheet(hide: $hidden) {
                VStack {
                    HStack {
                        Text("Number of children")
                            .font(.custom("Poppins-SemiBold", size: 20))
                            .foregroundStyle(Color.text.black80)
                        Spacer()
                        Image("close-circle")
                            .foregroundStyle(Color.text.black40)
                    }
                    .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.black.opacity(0.1))
                        .padding(.horizontal, -16)
                    
                    VStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { index in
                            Button {
                                let currentNr = children.count
                                if currentNr > index {
                                    // @todo what do we do?
                                } else {
                                    children.append(contentsOf: Array(repeating: ChildModel(name: "", dob: nil), count: index - currentNr))
                                }
                                hidden = true
                            } label: {
                                VStack(spacing: 0) {
                                    Text("\(index)")
                                        .font(.custom("Poppins-Medium", size: 18))
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity)
                                    if index != 5 {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundStyle(.black.opacity(0.1))
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(EmptyStyle())
                        }
                    }
                }
            }
        }
        .customNavigationTitle("Add child")
        .customNavTrailingItem {
            Button {
                onSave(children)
                dismiss()
            } label: {
                Text("Save")
                    .font(.custom("Poppins-Medium", size: 16))
            }
            .tint(Color.primary.brand)
        }
    }
}

#Preview {
    AddChildView { children in
        
    }
}
