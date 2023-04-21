
import MapKit
class PinAnnotation: NSObject, MKAnnotation {

    let title: String?
    var subtitle: String?
    var position: Position?
    var coordinate: CLLocationCoordinate2D

    init(position: Position, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.position = position
        self.title = position.airportCode
        self.subtitle = position.airportName
    }
}


extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
