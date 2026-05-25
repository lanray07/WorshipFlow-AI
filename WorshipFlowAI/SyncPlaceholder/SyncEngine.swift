import Foundation

protocol SyncEngine {
    func enqueueLocalChange(entityName: String, entityID: UUID)
    func syncIfAvailable() async
}

struct LocalOnlySyncEngine: SyncEngine {
    func enqueueLocalChange(entityName: String, entityID: UUID) {
        // Placeholder for future church-team cloud sync.
    }

    func syncIfAvailable() async {
        // Offline-first app: no remote sync is performed until backend credentials are supplied.
    }
}
