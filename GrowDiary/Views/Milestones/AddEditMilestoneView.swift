import SwiftData
import SwiftUI

struct AddEditMilestoneView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var profile: Profile?
    var milestone: Milestone?

    @State private var title = ""
    @State private var isCompleted = false
    @State private var achievedDate = Date()
    @State private var hasAchievedDate = false
    @State private var notes = ""

    private var isEditing: Bool { milestone != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.string("common.title"), text: $title)
                    Toggle(L10n.string("milestone.field.completed"), isOn: $isCompleted)
                    if isCompleted {
                        Toggle(L10n.string("milestone.field.setDate"), isOn: $hasAchievedDate)
                        if hasAchievedDate {
                            DatePicker(L10n.string("milestone.field.achievedDate"), selection: $achievedDate, displayedComponents: .date)
                        }
                    }
                } header: {
                    Text(L10n.string("milestone.form.section.title"))
                }

                Section {
                    TextField(L10n.string("common.optional"), text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text(L10n.string("common.notes"))
                }

                if isEditing, milestone?.templateId == nil {
                    Section {
                        Button(L10n.string("milestone.action.delete"), role: .destructive) {
                            if let milestone {
                                modelContext.delete(milestone)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(L10n.string(isEditing ? "milestone.title.edit" : "milestone.title.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.string("common.save")) { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExisting)
        }
    }

    private func loadExisting() {
        guard let milestone else { return }
        title = milestone.title
        isCompleted = milestone.isCompleted
        notes = milestone.notes
        if let date = milestone.achievedDate {
            hasAchievedDate = true
            achievedDate = date
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let milestone {
            milestone.title = trimmed
            milestone.isCompleted = isCompleted
            milestone.notes = notes
            milestone.achievedDate = isCompleted && hasAchievedDate ? achievedDate : nil
        } else if let profile {
            let newMilestone = Milestone(
                title: trimmed,
                sortOrder: profile.milestones.count,
                profile: profile
            )
            newMilestone.isCompleted = isCompleted
            newMilestone.notes = notes
            newMilestone.achievedDate = isCompleted && hasAchievedDate ? achievedDate : nil
            modelContext.insert(newMilestone)
            profile.milestones.append(newMilestone)
        }

        dismiss()
    }
}
