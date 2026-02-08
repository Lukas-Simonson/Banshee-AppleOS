import Foundation
import GRDB

/// Manages the GRDB database connection and migrations.
public final class DatabaseManager: @unchecked Sendable {

    /// Shared database queue for all database operations.
    public let dbQueue: DatabaseQueue

    /// Creates a DatabaseManager with the database at the specified path.
    /// - Parameter path: Path to the database file. If nil, uses default app support location.
    public init(path: String? = nil) throws {
        let databasePath = try path ?? DatabaseManager.defaultDatabasePath()

        var configuration = Configuration()
        configuration.prepareDatabase { db in
            // Enable foreign keys
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }

        dbQueue = try DatabaseQueue(path: databasePath, configuration: configuration)
        try migrator.migrate(dbQueue)
    }

    /// Returns the default path for the database file.
    private static func defaultDatabasePath() throws -> String {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = appSupportURL.appendingPathComponent("Banshee", isDirectory: true)
        print(directoryURL)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL.appendingPathComponent("banshee.sqlite").path
    }

    /// Database migrator with all schema migrations.
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        // Speed up development by nuking database when migrations change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v1_initial") { db in
            // Podcasts table
            try PodcastRecord.Migration.create(db)

            // Episodes table
            try EpisodeRecord.Migration.create(db)

            // Audio Progress table
            try AudioProgressRecord.Migration.create(db)
        }

        return migrator
    }
}
