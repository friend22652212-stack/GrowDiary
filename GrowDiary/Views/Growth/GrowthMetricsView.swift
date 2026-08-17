import Charts
import SwiftData
import SwiftUI

struct GrowthMetricsView: View {
    @Bindable var profile: Profile
    @State private var selectedMetricType: GrowthMetricType
    @State private var showingAddMetric = false

    init(profile: Profile) {
        self.profile = profile
        _selectedMetricType = State(
            initialValue: GrowthMetricType.available(for: profile.type).first ?? .weight
        )
    }

    private var filteredMetrics: [GrowthMetric] {
        profile.growthMetrics
            .filter { $0.type == selectedMetricType }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker(L10n.string("growth.picker.metricType"), selection: $selectedMetricType) {
                ForEach(GrowthMetricType.available(for: profile.type)) { type in
                    Label(type.displayName, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if filteredMetrics.isEmpty {
                EmptyStateView(
                    systemImage: selectedMetricType.systemImage,
                    title: L10n.format("growth.empty.title", selectedMetricType.displayName),
                    message: L10n.string("growth.empty.message")
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        GrowthChartView(
                            metrics: filteredMetrics,
                            type: selectedMetricType,
                            profileType: profile.type
                        )
                            .frame(height: 220)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            ForEach(filteredMetrics.reversed()) { metric in
                                GrowthMetricRowView(metric: metric)
                                if metric.id != filteredMetrics.reversed().first?.id {
                                    Divider().padding(.leading)
                                }
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                        .adaptiveCardShadow()
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddMetric = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMetric) {
            AddGrowthMetricView(profile: profile, defaultType: selectedMetricType)
        }
    }
}

struct GrowthMetricRowView: View {
    let metric: GrowthMetric

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.formattedValue)
                    .font(.headline)
                Text(metric.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !metric.notes.isEmpty {
                    Text(metric.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct GrowthChartView: View {
    let metrics: [GrowthMetric]
    let type: GrowthMetricType
    let profileType: ProfileType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.format("growth.chart.title", type.displayName))
                .font(.headline)
                .padding(.horizontal, 4)

            Chart(metrics) { metric in
                LineMark(
                    x: .value(L10n.string("growth.chart.axis.date"), metric.date),
                    y: .value(type.displayName, metric.value)
                )
                .foregroundStyle(AppTheme.tint(for: profileType))

                PointMark(
                    x: .value(L10n.string("growth.chart.axis.date"), metric.date),
                    y: .value(type.displayName, metric.value)
                )
                .foregroundStyle(AppTheme.tint(for: profileType))
            }
            .chartYAxisLabel(type.unit)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .adaptiveCardShadow()
    }
}
