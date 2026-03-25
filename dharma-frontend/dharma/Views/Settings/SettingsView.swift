import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator area + title
            HStack {
                Text("Settings")
                    .font(DharmaTheme.Typography.uiHeadline(18))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DharmaTheme.Colors.secondaryText.opacity(0.5))
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.top, DharmaTheme.Spacing.xl)
            .padding(.bottom, DharmaTheme.Spacing.lg)
            
            Divider().opacity(0.3)
            
            VStack(spacing: 0) {
                // Help & Support
                Button {
                    // Help & Support action
                } label: {
                    HStack(spacing: DharmaTheme.Spacing.md) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(DharmaTheme.Colors.saffron)
                            .frame(width: 28)
                        
                        Text("Help & Support")
                            .font(DharmaTheme.Typography.uiBody())
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
                
                Divider().padding(.leading, 68).opacity(0.3)
                
                // Log Out
                Button {
                    // Log out action
                } label: {
                    HStack(spacing: DharmaTheme.Spacing.md) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28)
                        
                        Text("Log Out")
                            .font(DharmaTheme.Typography.uiBody())
                            .foregroundColor(.red.opacity(0.8))
                        
                        Spacer()
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
            }
            
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    SettingsView()
        .presentationDetents([.height(350)])
}
