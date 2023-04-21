
import MapKit
import UIKit
import Foundation

class CurvedPolyline: MKPolyline {

    var color: UIColor?
    var strokeWidth: CGFloat?

    convenience init(coordinates coords: UnsafeMutablePointer<CLLocationCoordinate2D>, count: Int, color: UIColor, strokeWidth: CGFloat) {
        self.init(coordinates: coords, count: count)
        self.color = color
        self.strokeWidth = strokeWidth
    }
}
