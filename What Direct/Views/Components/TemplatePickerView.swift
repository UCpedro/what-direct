import SwiftUI

struct TemplatePickerView: View {
    let templates: [MessageTemplate]
    let selectedTemplateID: UUID?
    let onSelect: (MessageTemplate?) -> Void
    let onManage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Plantillas")
                    .font(.headline)
                Spacer()
                Button("Gestionar", action: onManage)
                    .font(.subheadline.weight(.semibold))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    chip(title: "Sin mensaje", isSelected: selectedTemplateID == nil) {
                        onSelect(nil)
                    }

                    ForEach(templates) { template in
                        chip(title: template.title, isSelected: selectedTemplateID == template.id) {
                            onSelect(template)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.green : Color(.secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }
}
