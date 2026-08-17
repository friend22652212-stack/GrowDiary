import SwiftData
import SwiftUI

struct TagChipView: View {
    @Environment(\.colorScheme) private var colorScheme
    let tag: DiaryTag

    var body: some View {
        Text(tag.name)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tag.color.opacity(colorScheme == .dark ? 0.24 : 0.16))
            .foregroundStyle(tag.color)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(tag.color.opacity(colorScheme == .dark ? 0.38 : 0.25), lineWidth: 1)
            }
    }
}

struct TagPickerSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryTag.name) private var allTags: [DiaryTag]

    @Binding var selectedTags: [DiaryTag]
    @State private var newTagName = ""

    var body: some View {
        Section {
            if !allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(allTags) { tag in
                            Button {
                                toggle(tag)
                            } label: {
                                TagChipView(tag: tag)
                                    .opacity(selectedTags.contains(where: { $0.id == tag.id }) ? 1 : 0.45)
                                    .overlay {
                                        if selectedTags.contains(where: { $0.id == tag.id }) {
                                            Capsule()
                                                .stroke(tag.color, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            HStack {
                TextField(L10n.string("tag.field.placeholder"), text: $newTagName)
                Button(L10n.string("tag.action.add")) { addTag() }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        } header: {
            Text(L10n.string("tag.section.title"))
        }
    }

    private func toggle(_ tag: DiaryTag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }

    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        if let existing = allTags.first(where: { $0.name == name }) {
            if !selectedTags.contains(where: { $0.id == existing.id }) {
                selectedTags.append(existing)
            }
        } else {
            let tag = DiaryTag(name: name)
            modelContext.insert(tag)
            selectedTags.append(tag)
        }
        newTagName = ""
    }
}
