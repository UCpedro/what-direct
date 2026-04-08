import SwiftUI
import WidgetKit

struct QuickOpenEntry: TimelineEntry {
    let date: Date
}

struct QuickOpenProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickOpenEntry {
        QuickOpenEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickOpenEntry) -> Void) {
        completion(QuickOpenEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickOpenEntry>) -> Void) {
        completion(Timeline(entries: [QuickOpenEntry(date: .now)], policy: .after(.now.addingTimeInterval(900))))
    }
}

struct WhatDirectQuickWidgetEntryView: View {
    let entry: QuickOpenEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.95),
                    Color(red: 0.04, green: 0.45, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)

                Text("What Direct")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Ingreso rápido")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Link(destination: URL(string: "whatdirect://quick-entry")!) {
                    Text("Abrir")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white)
                        )
                }
            }
            .padding(16)
        }
    }
}

struct WhatDirectQuickWidget: Widget {
    let kind: String = "WhatDirectQuickWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickOpenProvider()) { entry in
            WhatDirectQuickWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ingreso rápido")
        .description("Abre What Direct y escribe un número al instante.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct WhatDirectWidgetBundle: WidgetBundle {
    var body: some Widget {
        WhatDirectQuickWidget()
    }
}
