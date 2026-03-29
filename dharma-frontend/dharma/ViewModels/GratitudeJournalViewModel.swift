import Foundation
import Observation
import PostgREST
import Supabase

@Observable
@MainActor
final class GratitudeJournalViewModel {
    var gratitudeText = ""
    var previousEntries: [JournalEntry] = []
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var saveMessage: String?

    private var hasLoaded = false
    private var hasSavedEntryForToday = false

    var todayFormatted: String {
        Self.headerFormatter.string(from: Date())
    }

    var hasText: Bool {
        !gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var saveButtonTitle: String {
        if isSaving {
            return "Saving..."
        }

        return hasSavedEntryForToday ? "Update & Done" : "Save & Done"
    }

    func loadEntries(forceReload: Bool = false) async {
        guard !isLoading else { return }
        guard forceReload || !hasLoaded else { return }

        isLoading = true
        errorMessage = nil
        saveMessage = nil

        do {
            let entries: [JournalEntry] = try await supabase
                .from("journal_entries")
                .select()
                .order("date", ascending: false)
                .limit(10)
                .execute()
                .value

            apply(entries: entries)
            hasLoaded = true
        } catch {
            errorMessage = "Could not load your gratitude journal. Please try again."
        }

        isLoading = false
    }

    func saveEntry() async -> Bool {
        guard !isSaving else { return false }

        let trimmedText = gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            errorMessage = "Write something before saving."
            return false
        }

        isSaving = true
        errorMessage = nil
        saveMessage = nil

        do {
            let session = try await supabase.auth.session
            let payload = JournalEntryUpsert(
                userId: session.user.id,
                date: Self.storageDateString(from: Date()),
                content: trimmedText,
                updatedAt: Self.timestampString(from: Date())
            )

            let wasSavedPreviously = hasSavedEntryForToday

            try await supabase
                .from("journal_entries")
                .upsert(payload, onConflict: "user_id,date")
                .execute()

            gratitudeText = trimmedText
            hasLoaded = false
            await loadEntries(forceReload: true)
            saveMessage = wasSavedPreviously ? "Today's gratitude entry was updated." : "Today's gratitude entry was saved."
            isSaving = false
            return true
        } catch {
            errorMessage = "Could not save your gratitude journal. Please try again."
            isSaving = false
            return false
        }
    }

    private func apply(entries: [JournalEntry]) {
        let today = Self.storageDateString(from: Date())

        if let todayEntry = entries.first(where: { $0.date == today }) {
            gratitudeText = todayEntry.content
            hasSavedEntryForToday = true
        } else {
            hasSavedEntryForToday = false
        }

        previousEntries = entries.filter { $0.date != today }
    }

    private static func storageDateString(from date: Date) -> String {
        storageFormatter.string(from: date)
    }

    private static func timestampString(from date: Date) -> String {
        timestampFormatter.string(from: date)
    }

    private static let storageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    private static let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

private struct JournalEntryUpsert: Encodable {
    let userId: UUID
    let date: String
    let content: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case date
        case content
        case updatedAt = "updated_at"
    }
}
