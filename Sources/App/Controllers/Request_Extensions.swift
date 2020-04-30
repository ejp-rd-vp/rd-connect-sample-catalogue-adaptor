import Foundation
import Vapor

extension Request {
    var filter: FilterParameters? {
        return try? query.decode(FilterParameters.self)
    }
}
