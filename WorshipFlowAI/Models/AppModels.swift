import Foundation
import SwiftData

enum WorshipStyle: String, CaseIterable, Identifiable, Codable {
    case contemporary = "Contemporary"
    case gospel = "Gospel"
    case acoustic = "Acoustic"
    case youthWorship = "Youth Worship"
    case traditional = "Traditional"
    case mixed = "Mixed"

    var id: String { rawValue }
}

enum PrimaryRole: String, CaseIterable, Identifiable, Codable {
    case worshipLeader = "Worship Leader"
    case musician = "Musician"
    case vocalist = "Vocalist"
    case soundEngineer = "Sound Engineer"
    case admin = "Admin"

    var id: String { rawValue }
}

enum VolunteerRole: String, CaseIterable, Identifiable, Codable {
    case musician = "Musician"
    case vocalist = "Vocalist"
    case soundEngineer = "Sound Engineer"
    case projection = "Projection"
    case livestream = "Livestream"
    case worshipLeader = "Worship Leader"
}

enum SongCategory: String, CaseIterable, Identifiable, Codable {
    case praise = "Praise"
    case worship = "Worship"
    case communion = "Communion"
    case altarCall = "Altar Call"
    case youth = "Youth"
    case acoustic = "Acoustic"
    case choir = "Choir"
    case seasonal = "Seasonal"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case proMonthly = "Pro Monthly"
    case proYearly = "Pro Yearly"
    case churchMonthly = "Church Plan Monthly"

    var id: String { rawValue }

    var price: String {
        switch self {
        case .free: "£0"
        case .proMonthly: "£9.99"
        case .proYearly: "£79.99"
        case .churchMonthly: "£29.99"
        }
    }
}

@Model
final class ChurchProfile {
    @Attribute(.unique) var id: UUID
    var churchName: String
    var worshipStyle: String
    var primaryRole: String
    var teamSize: Int
    var notificationsEnabled: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        churchName: String,
        worshipStyle: WorshipStyle,
        primaryRole: PrimaryRole,
        teamSize: Int,
        notificationsEnabled: Bool,
        createdAt: Date = .now
    ) {
        self.id = id
        self.churchName = churchName
        self.worshipStyle = worshipStyle.rawValue
        self.primaryRole = primaryRole.rawValue
        self.teamSize = teamSize
        self.notificationsEnabled = notificationsEnabled
        self.createdAt = createdAt
    }
}

@Model
final class Song {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String
    var originalKey: String
    var bpm: Int
    var lyrics: String
    var chordChart: String
    var capoNotes: String
    var tags: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        originalKey: String,
        bpm: Int,
        lyrics: String,
        chordChart: String,
        capoNotes: String = "",
        tags: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.originalKey = originalKey
        self.bpm = bpm
        self.lyrics = lyrics
        self.chordChart = chordChart
        self.capoNotes = capoNotes
        self.tags = tags
        self.createdAt = createdAt
    }
}

@Model
final class SetList {
    @Attribute(.unique) var id: UUID
    var title: String
    var serviceDate: Date
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, serviceDate: Date, notes: String = "", createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.serviceDate = serviceDate
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class SetListSong {
    @Attribute(.unique) var id: UUID
    var setListId: UUID
    var songId: UUID
    var order: Int
    var selectedKey: String
    var tempo: Int
    var transitionNotes: String
    var worshipFlowNotes: String
    var scriptureReference: String
    var prayerMoment: String

    init(
        id: UUID = UUID(),
        setListId: UUID,
        songId: UUID,
        order: Int,
        selectedKey: String,
        tempo: Int,
        transitionNotes: String = "",
        worshipFlowNotes: String = "",
        scriptureReference: String = "",
        prayerMoment: String = ""
    ) {
        self.id = id
        self.setListId = setListId
        self.songId = songId
        self.order = order
        self.selectedKey = selectedKey
        self.tempo = tempo
        self.transitionNotes = transitionNotes
        self.worshipFlowNotes = worshipFlowNotes
        self.scriptureReference = scriptureReference
        self.prayerMoment = prayerMoment
    }
}

@Model
final class Volunteer {
    @Attribute(.unique) var id: UUID
    var fullName: String
    var role: String
    var availability: String
    var createdAt: Date

    init(id: UUID = UUID(), fullName: String, role: VolunteerRole, availability: String = "Available", createdAt: Date = .now) {
        self.id = id
        self.fullName = fullName
        self.role = role.rawValue
        self.availability = availability
        self.createdAt = createdAt
    }
}

@Model
final class VolunteerAssignment {
    @Attribute(.unique) var id: UUID
    var volunteerId: UUID
    var serviceDate: Date
    var role: String
    var confirmed: Bool

    init(id: UUID = UUID(), volunteerId: UUID, serviceDate: Date, role: VolunteerRole, confirmed: Bool = false) {
        self.id = id
        self.volunteerId = volunteerId
        self.serviceDate = serviceDate
        self.role = role.rawValue
        self.confirmed = confirmed
    }
}

@Model
final class RehearsalNote {
    @Attribute(.unique) var id: UUID
    var setListId: UUID
    var content: String
    var createdAt: Date

    init(id: UUID = UUID(), setListId: UUID, content: String, createdAt: Date = .now) {
        self.id = id
        self.setListId = setListId
        self.content = content
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = false, renewsAt: Date? = nil) {
        self.id = id
        self.plan = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}

struct ServiceTimelineItem: Identifiable, Hashable {
    let id = UUID()
    var time: Date
    var title: String
    var detail: String
}

struct AnalyticsMetric: Identifiable {
    let id = UUID()
    var label: String
    var value: Double
}
