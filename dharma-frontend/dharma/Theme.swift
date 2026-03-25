import SwiftUI

// MARK: - Dharma Design System
// Pure White Foundation with Saffron Accents
// Typography: Serif for scripture, Sans-serif for UI

struct DharmaTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary
        static let saffron = Color(hex: "FF7722")
        static let saffronDark = Color(hex: "9F4200")
        
        // Surfaces
        static let surface = Color(hex: "F9F9F9")
        static let surfaceContainerLow = Color(hex: "F3F3F4")
        static let surfaceContainerLowest = Color.white
        static let surfaceContainer = Color(hex: "EEEEEE")
        
        // Text
        static let onSurface = Color(hex: "1A1C1C")
        static let onSurfaceVariant = Color(hex: "584237")
        static let secondaryText = Color(hex: "666666")
        
        // Chat
        static let aiBubble = Color(hex: "FF7722").opacity(0.15)
        static let userBubble = Color(hex: "F0F0F0")
        
        // Task card backgrounds
        static let cardHindu = Color(hex: "FFF3E0")
        static let cardBuddhist = Color(hex: "E3F2FD")
        static let cardMeditation = Color(hex: "E8DEF8")
        static let cardMantra = Color(hex: "FFF8E1")
        static let cardJournal = Color(hex: "FCE4EC")
        static let cardGratitude = Color(hex: "E8F5E9")
        
        // Outline
        static let outlineVariant = Color(hex: "E0C0B1").opacity(0.15)
        
        // Saffron gradient for CTAs
        static var saffronGradient: LinearGradient {
            LinearGradient(
                colors: [Color(hex: "9F4200"), Color(hex: "FF7722")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Typography
    struct Typography {
        // Scripture fonts (Serif)
        static func scriptureDisplay(_ size: CGFloat = 32) -> Font {
            .custom("Georgia", size: size)
        }
        
        static func scriptureHeadline(_ size: CGFloat = 24) -> Font {
            .custom("Georgia", size: size)
        }
        
        static func scriptureBody(_ size: CGFloat = 20) -> Font {
            .custom("Georgia", size: size)
        }
        
        static func scriptureCaption(_ size: CGFloat = 14) -> Font {
            .custom("Georgia", size: size)
        }
        
        // UI fonts (System Sans-Serif)
        static func uiTitle(_ size: CGFloat = 22) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }
        
        static func uiHeadline(_ size: CGFloat = 18) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        
        static func uiBody(_ size: CGFloat = 16) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
        
        static func uiCaption(_ size: CGFloat = 13) -> Font {
            .system(size: size, weight: .medium, design: .default)
        }
        
        static func uiLabel(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
    }
}

// MARK: - Color hex initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable View Modifiers
struct SaffronButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DharmaTheme.Typography.uiHeadline(16))
            .foregroundColor(.white)
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.vertical, DharmaTheme.Spacing.md)
            .background(DharmaTheme.Colors.saffronGradient)
            .cornerRadius(DharmaTheme.Radius.xl)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DharmaTheme.Typography.uiCaption())
            .foregroundColor(DharmaTheme.Colors.onSurface)
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.vertical, DharmaTheme.Spacing.sm)
            .background(DharmaTheme.Colors.surfaceContainerLowest)
            .cornerRadius(DharmaTheme.Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: DharmaTheme.Radius.xl)
                    .stroke(DharmaTheme.Colors.outlineVariant, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SaffronButtonStyle {
    static var saffron: SaffronButtonStyle { SaffronButtonStyle() }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
}
