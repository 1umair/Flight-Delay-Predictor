

import Foundation

struct Airport: Codable {
    let iataCode: String
    let name: String
    let icaoCode: String
    let latitude: Double
    let longitude: Double
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case iataCode = "iata_code"
        case name
        case icaoCode = "icao_code"
        case latitude = "lat"
        case longitude = "lng"
        case countryCode = "country_code"
    }
}
