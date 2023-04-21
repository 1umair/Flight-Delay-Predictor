
import UIKit
import MapKit
import CoreLocation
import CoreML

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var flights: [String: (lat: Double, long: Double)] = [:]
    var inputParameters = [String: Airport]()
    var flightDelay: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func predict() {
        do {
            // Try one hot Encoding
            let model = try testcoreML(configuration: .init())
            let destinationDict = [
                    "LAX": 0,
                    "SFO": 1,
                    "JFK": 2
                ]

                let arrivalDict = [
                    "LAX": 0,
                    "SFO": 1,
                    "JFK": 2
                ]

                // One-hot encode the destination and arrival
                var destOneHot = [Double](repeating: 0, count: destinationDict.count)
                if let destIndex = destinationDict["SFO"] {
                    destOneHot[destIndex] = 1
                }

                var arrivalOneHot = [Double](repeating: 0, count: arrivalDict.count)
                if let arrivalIndex = arrivalDict["JFK"] {
                    arrivalOneHot[arrivalIndex] = 1
                }

                // Convert the date to a numeric value
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let dateValue = dateFormatter.date(from: "04-17-2023")?.timeIntervalSince1970 ?? 0

                // Create a multiarray to hold the input
                let inputArray = try MLMultiArray(shape: [NSNumber(value: destOneHot.count + arrivalOneHot.count + 1)], dataType: .double)

                // Set the values in the multiarray
                for i in 0..<destOneHot.count {
                    inputArray[i] = NSNumber(value: destOneHot[i])
                }
                for i in 0..<arrivalOneHot.count {
                    inputArray[destOneHot.count + i] = NSNumber(value: arrivalOneHot[i])
                }
                inputArray[destOneHot.count + arrivalOneHot.count] = NSNumber(value: dateValue)

            // Make a prediction
            let p = try model.prediction(input: inputArray)
            flightDelay = p.classLabel
        } catch {
            let alert = UIAlertController(title: "Error", message: "Please retry.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        predict()
        // callFlightsAPI()
        let depAirport: Airport? = inputParameters["DA"]
        let arrAirport: Airport? = inputParameters["AA"]

        displayBottomSheet(fromViewController: self, delay: flightDelay ?? "", sourceAirportCode: depAirport!.iataCode, destinationAirportCode: arrAirport!.iataCode)



        // Coordinates of departure airport
        let depCoordinate = CLLocationCoordinate2D(latitude: depAirport?.latitude ?? 0.0, longitude: depAirport?.longitude ?? 0.0)

        // Coordinates of arrival airport
        let arrCoordinate = CLLocationCoordinate2D(latitude: arrAirport?.latitude ?? 0.0, longitude: arrAirport?.longitude ?? 0.0)

        if let polyline = curvedPolyline(start: depCoordinate, end: arrCoordinate) {
            mapView.addOverlay(polyline)
        } else {
            print("Failed to create polyline")
        }
        self.zoomToRegion()
        self.setMapKitDelegate()
        self.resetMap()
    }

    private func setMapKitDelegate() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    lazy var containerStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [spacer])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()

    // Add subviews and set constraints
    func setupConstraints() {
        view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            containerStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
            containerStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
        ])
    }

    @objc func openSearchFlightVC(sender: UIButton) {
        self.performSegue (withIdentifier: SearchFlightVC.storyboardID, sender: sender)
    }

    @IBAction func mapTypeSelect(_ sender: Any) {
        switch mapTypeSegment.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .hybrid
        }
    }

    private func zoomToRegion() {
        /*guard let userLocation = mapView.userLocation.location else {
               return
           }
           let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
           mapView.setRegion(region, animated: true)*/
        mapView.showAnnotations(mapView.annotations, animated: false)
    }

    private func resetMap() {
        removeAllAnnotations()
    }

    private func removeAllAnnotations() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        addAnnotations()
    }

    private func addAnnotations() {
        let depAirport: Airport? = inputParameters["DA"]
        let arrAirport: Airport? = inputParameters["AA"]

        let depPosition = Position(airportCode: depAirport!.iataCode, airportName: depAirport!.name, latitude: depAirport!.latitude, longitude: depAirport!.longitude)
        let depAnnotation = PinAnnotation(position: depPosition, coordinate: CLLocationCoordinate2D(latitude: depPosition.latitude.truncate(places: 6), longitude: depPosition.longitude.truncate(places: 6)))
        mapView.addAnnotations([depAnnotation])

        let arrPosition = Position(airportCode: arrAirport!.iataCode, airportName: arrAirport!.name, latitude: arrAirport!.latitude, longitude: arrAirport!.longitude)
        let arrAnnotation = PinAnnotation(position: arrPosition, coordinate: CLLocationCoordinate2D(latitude: arrPosition.latitude.truncate(places: 6), longitude: arrPosition.longitude.truncate(places: 6)))
        mapView.addAnnotations([arrAnnotation])
    }

    func displayBottomSheet(fromViewController viewController: UIViewController, delay: String, sourceAirportCode: String, destinationAirportCode: String) {
        var flightDelay = delay
        let bottomSheetVC = UIViewController()
        bottomSheetVC.view.backgroundColor = .black

        // Flight Delay Label
        let flightDelayLabel = UILabel(frame: CGRect(x: 0, y: 60, width:  bottomSheetVC.view.frame.width, height: 60))
        flightDelayLabel.font = UIFont(name: "AvenirNext-Regular", size: 20.0)
        flightDelayLabel.textColor = .white
        flightDelayLabel.textAlignment = .center
        flightDelayLabel.numberOfLines = 2
        flightDelayLabel.text = "Your flight is predicted \n to be:"
        bottomSheetVC.view.addSubview(flightDelayLabel)


        let delayLabel = UILabel(frame: CGRect(x: 0, y: 160, width: bottomSheetVC.view.frame.width, height: 80))
        delayLabel.font = UIFont(name: "AvenirNext-Bold", size: 26.0)
        delayLabel.textAlignment = .center
        delayLabel.textColor = .systemRed
        delayLabel.numberOfLines = 2
        bottomSheetVC.view.addSubview(delayLabel)

         // Format the predicted class label for display
         if flightDelay == "20=<DELAY<40" {
             delayLabel.text = "Delayed by 20 to 40 minutes"

         } else if flightDelay == "40=<DELAY<60" {
             delayLabel.text = "Delayed by 40 to 60 minutes"

         } else if flightDelay == "60=<DELAY" {
             delayLabel.text = "Delayed by more than 60 minutes"

         } else if flightDelay == "DELAY<20" {
             delayLabel.text = "Delayed by less than 20 minutes"

         } else if flightDelay == "On time" {
             delayLabel.textColor = .systemGreen
             delayLabel.text = "\(flightDelay)"
         }

        // Set the size of the bottom sheet
        bottomSheetVC.preferredContentSize = CGSize(width: viewController.view.bounds.width, height: 300)

        // Add the bottom sheet as a child view controller
        viewController.addChild(bottomSheetVC)
        viewController.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: viewController)

        // Set the position of the bottom sheet off screen
        let height = viewController.view.frame.height
        let width = viewController.view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: height, width: width, height: 300)

        // Add swipe down gesture recognizer to dismiss the bottom sheet
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissBottomSheet(_:)))
        swipeGestureRecognizer.direction = .down
        bottomSheetVC.view.addGestureRecognizer(swipeGestureRecognizer)

        // Add tap gesture recognizer to dismiss the bottom sheet
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
       // bottomSheetVC.view.superview?.addGestureRecognizer(tapGestureRecognizer)

        // Animate the presentation of the bottom sheet
        UIView.animate(withDuration: 0.3) {
            bottomSheetVC.view.frame = CGRect(x: 0, y: height - 300, width: width, height: 300)
        }
    }

    @objc func dismissBottomSheet(_ gestureRecognizer: UIGestureRecognizer) {
        guard let bottomSheetView = gestureRecognizer.view else { return }

        UIView.animate(withDuration: 0.3, animations: {
            bottomSheetView.frame.origin.y = UIScreen.main.bounds.height
        }) { (finished) in
            bottomSheetView.removeFromSuperview()
        }
    }

}

// MARK: - Location Manager Delegate
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLocation = locValue
    }
}


extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .blue
            lineRenderer.fillColor = .blue
            lineRenderer.lineWidth = 5.0
            return lineRenderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PinAnnotation else {
            return nil
        }

        let identifier = "pin"
        var view: PinAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = PinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.performSegue (withIdentifier: SearchFlightVC.storyboardID, sender: nil)
        }
    }
}


extension MapVC {
    func curvedPolyline(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> CurvedPolyline? {
        let curveFactor = 0.8 // Change this value to adjust the curve.
        let midLatitude = (start.latitude + end.latitude) / 2
        let midLongitude = (start.longitude + end.longitude) / 2

        let c1 = CLLocationCoordinate2D(latitude: start.latitude + (midLatitude - start.latitude) * curveFactor,
                                         longitude: start.longitude + (midLongitude - start.longitude) * curveFactor)

        let c2 = CLLocationCoordinate2D(latitude: end.latitude + (midLatitude - end.latitude) * curveFactor,
                                         longitude: end.longitude + (midLongitude - end.longitude) * curveFactor)

        var coordinates = [start, c1, c2, end]
        var data = Data(bytes: &coordinates, count: MemoryLayout<CLLocationCoordinate2D>.size * coordinates.count)
        if let ptr = data.withUnsafeMutableBytes({ $0.baseAddress?.assumingMemoryBound(to: CLLocationCoordinate2D.self) }) {
            return CurvedPolyline(coordinates: ptr, count: coordinates.count, color: UIColor.blue, strokeWidth: 2.0)
        }
        return nil
    }
}
