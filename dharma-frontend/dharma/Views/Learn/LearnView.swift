import SwiftUI

struct LearnView: View {
    @Bindable var viewModel: LearnViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DharmaTheme.Spacing.xl) {
                    VStack(spacing: DharmaTheme.Spacing.sm) {
                        Text("Learn")
                            .font(DharmaTheme.Typography.scriptureHeadline(28))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Text("Deepen your spiritual understanding")
                            .font(DharmaTheme.Typography.uiBody(14))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.top, DharmaTheme.Spacing.xl)
                    
                    if viewModel.isLoading && viewModel.articles.isEmpty {
                        VStack(spacing: DharmaTheme.Spacing.md) {
                            ProgressView()
                                .tint(DharmaTheme.Colors.saffron)

                            Text("Loading teachings...")
                                .font(DharmaTheme.Typography.uiBody(14))
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DharmaTheme.Spacing.xxxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.articles.isEmpty {
                        errorState(message: errorMessage)
                    } else {
                        if let errorMessage = viewModel.errorMessage {
                            inlineError(message: errorMessage)
                        }

                        LazyVStack(spacing: DharmaTheme.Spacing.lg) {
                            ForEach(viewModel.articles) { article in
                                NavigationLink {
                                    LearnArticleDetailView(article: article)
                                } label: {
                                    articleCard(article)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if viewModel.articles.isEmpty {
                            Text("No articles available yet")
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
                await viewModel.loadArticles()
            }
            .refreshable {
                await viewModel.loadArticles(forceReload: true)
            }
        }
    }

    private func articleCard(_ article: LearnArticle) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
            AsyncImage(url: article.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackImage
                case .empty:
                    Rectangle()
                        .fill(DharmaTheme.Colors.surfaceContainerLow)
                        .overlay {
                            ProgressView()
                                .tint(DharmaTheme.Colors.saffron)
                        }
                @unknown default:
                    fallbackImage
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(DharmaTheme.Radius.lg)

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                HStack(spacing: DharmaTheme.Spacing.sm) {
                    ForEach(Array(article.tags.prefix(3)), id: \.self) { tag in
                        Text(tag.capitalized)
                            .font(DharmaTheme.Typography.uiCaption(11))
                            .foregroundColor(tagTextColor(for: tag))
                            .padding(.horizontal, DharmaTheme.Spacing.md)
                            .padding(.vertical, 6)
                            .background(tagBackgroundColor(for: tag))
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    if let estimatedReadMins = article.estimatedReadMins {
                        Label("\(estimatedReadMins) min", systemImage: "clock")
                            .font(DharmaTheme.Typography.uiCaption(11))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                }

                Text(article.title)
                    .font(DharmaTheme.Typography.uiHeadline(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                if let subtitle = article.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(DharmaTheme.Typography.uiBody(14))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Text(article.content?.isEmpty == false ? "Read article" : "Open article")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.saffronDark)

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                }
                .padding(.top, DharmaTheme.Spacing.xs)
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.bottom, DharmaTheme.Spacing.lg)
        }
        .background(DharmaTheme.Colors.surfaceContainerLowest)
        .cornerRadius(DharmaTheme.Radius.lg)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Text("We couldn’t load the library")
                .font(DharmaTheme.Typography.uiHeadline(18))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text(message)
                .font(DharmaTheme.Typography.uiBody(14))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.loadArticles(forceReload: true)
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
            .background(DharmaTheme.Colors.cardHindu)
            .cornerRadius(DharmaTheme.Radius.md)
    }

    private var fallbackImage: some View {
        LinearGradient(
            colors: [DharmaTheme.Colors.cardMantra, DharmaTheme.Colors.cardBuddhist],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "book.pages.fill")
                .font(.system(size: 32))
                .foregroundColor(DharmaTheme.Colors.saffron)
        }
    }

    private func tagBackgroundColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "buddhism":
            return DharmaTheme.Colors.cardBuddhist
        case "hinduism":
            return DharmaTheme.Colors.cardHindu
        default:
            return DharmaTheme.Colors.cardMantra
        }
    }

    private func tagTextColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "buddhism":
            return Color(hex: "285B88")
        case "hinduism":
            return DharmaTheme.Colors.saffronDark
        default:
            return Color(hex: "7A5D00")
        }
    }
}

#Preview {
    LearnView(viewModel: LearnViewModel())
}
