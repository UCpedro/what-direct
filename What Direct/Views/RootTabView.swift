import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Inicio", systemImage: "bolt.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Historial", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                SavedContactsView()
            }
            .tabItem {
                Label("Guardados", systemImage: "person.crop.circle.badge.checkmark")
            }

            NavigationStack {
                TemplatesView()
            }
            .tabItem {
                Label("Plantillas", systemImage: "text.bubble")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape")
            }
        }
        .tint(WDTheme.brand)
    }
}
