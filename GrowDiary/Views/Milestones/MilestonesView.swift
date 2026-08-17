import SwiftData
import SwiftUI

struct MilestonesView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: Profile

    @State private var showingAddMilestone = false
    @State private var didSeedTemplates = false

    var body: some View {
        Group {
            if profile.milestones.isEmpty && !didSeedTemplates {
                ProgressView(L10n.string("milestone.loading"))
                    .task {
                        MilestoneTemplateProvider.seedMilestones(for: profile, context: modelContext)
                        didSeedTemplates = true
                    }
            } else if profile.sortedMilestones.isEmpty {
                EmptyStateView(
                    systemImage: "flag.fill",
                    title: L10n.string("milestone.empty.title"),
                    message: L10n.string("milestone.empty.message")
                )
            } else {
                List {
                    let completed = profile.sortedMilestones.filter(\.isCompleted)
                    let pending = profile.sortedMilestones.filter { !$0.isCompleted }

                    if !pending.isEmpty {
                        Section {
                            ForEach(pending) { milestone in
                                MilestoneRowView(milestone: milestone)
                            }
                        } header: {
                            Text(L10n.string("milestone.section.pending"))
                        }
                    }

                    if !completed.isEmpty {
                        Section {
                            ForEach(completed) { milestone in
                                MilestoneRowView(milestone: milestone)
                            }
                        } header: {
                            Text(L10n.string("milestone.section.completed"))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddMilestone = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMilestone) {
            AddEditMilestoneView(profile: profile)
        }
        .onAppear {
            if profile.milestones.isEmpty {
                MilestoneTemplateProvider.seedMilestones(for: profile, context: modelContext)
            }
        }
    }
}

struct MilestoneRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var milestone: Milestone
    @State private var showingEdit = false

    var body: some View {
        Button {
            showingEdit = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(milestone.isCompleted ? Color.green.opacity(0.15) : Color.secondary.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(milestone.isCompleted ? .green : .secondary)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.displayTitle)
                        .font(.body.weight(milestone.isCompleted ? .regular : .semibold))
                        .foregroundStyle(milestone.isCompleted ? .secondary : .primary)
                        .strikethrough(milestone.isCompleted)

                    if let date = milestone.achievedDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingEdit) {
            AddEditMilestoneView(profile: milestone.profile, milestone: milestone)
        }
    }
}
