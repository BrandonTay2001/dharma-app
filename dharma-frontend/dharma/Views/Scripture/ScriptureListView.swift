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

                    if viewModel.isLoading && viewModel.scriptures.isEmpty {
                        loadingState
                    } else if let errorMessage = viewModel.errorMessage, viewModel.scriptures.isEmpty {
                        errorState(message: errorMessage)
                    } else {
                        if let errorMessage = viewModel.errorMessage {
                            inlineError(message: errorMessage)
                        }

                        ForEach(viewModel.scriptures) { scripture in
                            NavigationLink {
                                ScriptureReaderView(viewModel: viewModel)
                                    .task {
                                        viewModel.selectScripture(scripture)
                                        await viewModel.loadVerses(for: scripture.title)
                                    }
                            } label: {
                                scriptureCard(scripture)
                            }
                            .buttonStyle(.plain)
                        }

                        if viewModel.scriptures.isEmpty {
                            Text("No sacred texts are available yet")
                                .font(DharmaTheme.Typography.uiBody(14))
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                                .padding(.top, DharmaTheme.Spacing.xl)
                        }
                    }
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.bottom, DharmaTheme.Spacing.xxxl)
            }
            .background(Color.white)
            .task {
                await viewModel.loadScriptures()
            }
            .refreshable {
                await viewModel.loadScriptures(forceReload: true)
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            ProgressView()
                .tint(DharmaTheme.Colors.saffron)

            Text("Loading sacred texts...")
                .font(DharmaTheme.Typography.uiBody(14))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DharmaTheme.Spacing.xxxl)
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

    private func errorState(message: String) -> some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Text("We couldn’t load the scriptures")
                .font(DharmaTheme.Typography.uiHeadline(18))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text(message)
                .font(DharmaTheme.Typography.uiBody(14))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadScriptures(forceReload: true)
                }
            }
            .buttonStyle(.saffron)
        }
        .frame(maxWidth: .infinity)
        .padding(DharmaTheme.Spacing.xl)
        .background(DharmaTheme.Colors.surfaceContainerLow)
        .cornerRadius(DharmaTheme.Radius.lg)
    }

    private func inlineError(message: String) -> some View {
        Text(message)
            .font(DharmaTheme.Typography.uiCaption())
            .foregroundColor(DharmaTheme.Colors.saffronDark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .background(DharmaTheme.Colors.surfaceContainerLow)
            .cornerRadius(DharmaTheme.Radius.md)
    }
}

#Preview {
    ScriptureListView(viewModel: {
        let viewModel = ScriptureViewModel()
        viewModel.scriptures = Scripture.allScriptures
        return viewModel
    }())
}
