import FluentSQLite
import Vapor

struct Deal: SQLiteModel {
  var id: Int?
  let requirementSize: Int
}

extension Deal: Content { }

extension Deal: Migration { }