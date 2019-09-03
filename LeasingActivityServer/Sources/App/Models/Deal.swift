import FluentSQLite
import Vapor

struct Deal: SQLiteModel {
  var id: Int?
  let requirementSize: Int
  let tenantName: String
}

extension Deal: Content { }

extension Deal: Migration { }
