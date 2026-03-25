import SwiftUI

struct ScriptureListView: View {
    @Bindable var viewModel: ScriptureViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DharmaTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: DharmaTheme.Spacing.sm) {
                        Text("Sacred Texts")
                            .font(DharmaTheme.Typography.scriptureHeadline(28))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Text("Read and reflect on timeless wisdom")
                            .font(DharmaTheme.Typography.uiBody(14))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.top, DharmaTheme.Spacing.xl)
                    
                    // Scripture Cards
                    ForEach(viewModel.scriptures) { scripture in
                        NavigationLink {
                            ScriptureReaderView(viewModel: viewModel)
                                .onAppear {
                                    viewModel.selectScripture(scripture)
                                }
                        } label: {
                            scriptureCard(scripture)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.bottom, DharmaTheme.Spacing.xxxl)
            }
            .background(Color.white)
        }
    }
    
    private func scriptureCard(_ scripture: Scripture) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
            HStack {
                Image(systemName: scripture.icon)
                    .font(.system(size: 28))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(scripture.title)
                        .font(DharmaTheme.Typography.scriptureHeadline(20))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                    
                    Text(scripture.tradition)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.saffron)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            
            Text("\(scripture.chapterCount) chapters available")
                .font(DharmaTheme.Typography.uiCaption())
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
        .padding(DharmaTheme.Spacing.xl)
        .background(DharmaTheme.Colors.surface)
        .cornerRadius(DharmaTheme.Radius.lg)
    }
}

#Preview {
    ScriptureListView(viewModel: ScriptureViewModel())
}
