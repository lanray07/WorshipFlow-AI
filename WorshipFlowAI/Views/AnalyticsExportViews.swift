import Charts
import SwiftData
import SwiftUI

struct AnalyticsDashboardView: View {
    @Query private var songs: [Song]
    @Query private var volunteers: [Volunteer]
    @Query private var setLists: [SetList]

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Analytics", subtitle: "Song use, volunteers, keys, duration, and rehearsal completion placeholders")
                    AnalyticsChartCard(title: "Key Usage Trends") {
                        Chart(keyMetrics) { metric in
                            BarMark(x: .value("Key", metric.label), y: .value("Songs", metric.value))
                                .foregroundStyle(WFColor.gold)
                        }
                    }
                    ReportPreviewView(title: "Operating Metrics", lines: [
                        "Most used songs: \(songs.prefix(3).map(\.title).joined(separator: ", "))",
                        "Volunteer participation: \(volunteers.count) active volunteers",
                        "Average set duration: \(setLists.isEmpty ? 0 : 24) minutes placeholder",
                        "Scheduling consistency: \(setLists.count) upcoming set lists",
                        "Rehearsal completion: placeholder"
                    ])
                }
                .padding()
            }
        }
        .navigationTitle("Analytics")
    }

    private var keyMetrics: [AnalyticsMetric] {
        Dictionary(grouping: songs, by: \.originalKey)
            .map { AnalyticsMetric(label: $0.key, value: Double($0.value.count)) }
            .sorted { $0.label < $1.label }
    }
}

struct PDFExportView: View {
    @Environment(AppViewModel.self) private var appModel
    @Query(sort: \SetList.serviceDate) private var setLists: [SetList]
    @Query(sort: \Song.title) private var songs: [Song]
    @Query private var notes: [RehearsalNote]
    @State private var isSharePresented = false

    var body: some View {
        ZStack {
            StageBackground()
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "PDF Export", subtitle: "Printable set lists, chord charts, schedules, rehearsal notes, and service flow")
                ReportPreviewView(title: "Export Preview", lines: [
                    "Printable set list",
                    "Chord chart bundle",
                    "Volunteer schedule",
                    "Rehearsal notes",
                    "Service flow sheet"
                ])
                Button {
                    if let setList = setLists.first {
                        appModel.export(setList: setList, songs: songs, notes: notes)
                        isSharePresented = appModel.selectedPDFURL != nil
                    }
                } label: {
                    Label("Generate PDF", systemImage: "doc.richtext.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(WFColor.gold)
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isSharePresented) {
            if let url = appModel.selectedPDFURL {
                ShareSheet(items: [url])
            }
        }
        .navigationTitle("Exports")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
