import AVFoundation
import SwiftUI
import VisionKit

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authorizationState = AVCaptureDevice.authorizationStatus(for: .video)

    let onPick: (String) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    switch authorizationState {
                    case .authorized:
                        DataScannerContainerView { scannedText in
                            onPick(scannedText)
                            dismiss()
                        }
                    case .notDetermined:
                        permissionView
                    default:
                        unavailableView(
                            title: "Permiso de cámara requerido",
                            description: "Activa el permiso de cámara para escanear números desde texto real."
                        )
                    }
                } else {
                    unavailableView(
                        title: "Escáner no disponible",
                        description: "Este dispositivo o simulador no soporta el escaneo en tiempo real."
                    )
                }
            }
            .padding()
            .background(WDBackground())
            .navigationTitle("Escanear número")
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var permissionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 44))
                .foregroundStyle(WDTheme.brand)

            Text("Permite el acceso a la cámara")
                .font(.title3.weight(.semibold))

            Text("Usamos el escáner de texto de Apple para detectar números telefónicos en tarjetas, letreros o documentos.")
                .multilineTextAlignment(.center)
                .foregroundStyle(WDTheme.mutedText)

            Button("Continuar") {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        authorizationState = granted ? .authorized : .denied
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(WDTheme.brand)
        }
        .padding(24)
        .wdCard(padding: 24)
    }

    private func unavailableView(title: String, description: String) -> some View {
        EmptyStateCard(
            title: title,
            subtitle: description,
            systemImage: "text.viewfinder"
        )
    }
}

@available(iOS 16.0, *)
private struct DataScannerContainerView: UIViewControllerRepresentable {
    let onDetected: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDetected: onDetected)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onDetected: (String) -> Void

        init(onDetected: @escaping (String) -> Void) {
            self.onDetected = onDetected
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            guard case .text(let text) = item else { return }
            let digits = PhoneNumberFormatter.clean(text.transcript)
            guard digits.count >= 6 else { return }
            onDetected(digits)
        }
    }
}
