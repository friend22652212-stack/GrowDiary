import SwiftData
import SwiftUI

struct AddGrowthMetricView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var profile: Profile
    var defaultType: GrowthMetricType

    @State private var type: GrowthMetricType
    @State private var valueText = ""
    @State private var date = Date()
    @State private var notes = ""

    init(profile: Profile, defaultType: GrowthMetricType) {
        self.profile = profile
        self.defaultType = defaultType
        _type = State(initialValue: defaultType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(L10n.string("common.type"), selection: $type) {
                        ForEach(GrowthMetricType.available(for: profile.type)) { metricType in
                            Text(metricType.displayName).tag(metricType)
                        }
                    }

                    HStack {
                        TextField(L10n.string("growth.field.value"), text: $valueText)
                            .keyboardType(.decimalPad)
                        Text(type.unit)
                            .foregroundStyle(.secondary)
                    }

                    DatePicker(L10n.string("common.date"), selection: $date, displayedComponents: .date)
                } header: {
                    Text(L10n.string("growth.form.section.data"))
                }

                Section {
                    TextField(L10n.string("common.optional"), text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text(L10n.string("common.notes"))
                }
            }
            .navigationTitle(L10n.format("growth.title.addMetric", type.displayName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.string("common.save")) { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        Double(valueText.replacingOccurrences(of: ",", with: ".")) != nil
    }

    private func save() {
        guard let value = Double(valueText.replacingOccurrences(of: ",", with: ".")) else { return }

        let metric = GrowthMetric(
            type: type,
            value: value,
            date: date,
            notes: notes,
            profile: profile
        )
        modelContext.insert(metric)
        profile.growthMetrics.append(metric)
        dismiss()
    }
}
