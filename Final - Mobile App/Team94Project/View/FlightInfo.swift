

import Foundation

struct Position: Codable {
    var airportCode: String
    var airportName: String
    var latitude: Double
    var longitude: Double

    private enum CodingKeys: String, CodingKey {
        case airportCode
        case airportName
        case latitude
        case longitude
    }
}
