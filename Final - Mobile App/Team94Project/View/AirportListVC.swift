
import Foundation
import UIKit
import MapKit
import CoreLocation

protocol AirportSelectionDelegate: AnyObject {
    func didSelectAirport(_ airportDetails: Airport)
}


class AirportListVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTypeSegment: UISegmentedControl!
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    weak var airportDelegate: AirportSelectionDelegate?
    @IBOutlet weak var tableView: UITableView!
    var airports: [Airport] = []
    // var selectedAirport = ""
    var selectedAirport: Airport?
    var modelAirport = ["ANC", "LAX", "SFO", "LAS", "DEN", "SLC", "PDX", "FAI", "MSP", "PHX", "ORD", "GEG", "HNL", "ONT", "MCO", "BOS", "DFW", "MKE", "IAH", "BNA", "BOI", "PHL", "IAD", "JFK", "FAT", "SMF", "AUS", "MCI", "ATL", "DCA", "SAT", "CHS", "SBA", "CLE", "OMA", "FLL", "TPA", "EWR", "OAK", "ABQ", "MIA", "BWI", "MSY", "OKC", "CLT", "RDU", "CVG", "DTW", "TUS", "PSC", "DAL", "PSP", "STL", "OGG", "SJC", "KOA", "HOU", "SAN", "COS", "BZN", "MDW", "LIH", "BLI", "SNA", "LGB", "BUR", "JNU", "JAC", "HDN", "MSO", "BIL", "KTN", "SIT", "SEA", "BUF", "IND", "BFL", "RNO", "PIT", "TUL", "LIT", "MHT", "CMH", "MRY", "MTJ", "SBP", "DRO", "DSM", "ELP", "SDF", "YUM", "GJT", "FLG", "HIB", "ABR", "BJI", "SBN", "PIA", "JAX", "IDA", "MSN", "BDL", "RIC", "CID", "SYR", "ROC", "LAN", "RSW", "LGA", "ATW", "MEM", "GRB", "FAR", "LEX", "CWA", "TTN", "RAP", "DLH", "FSD", "INL", "ORF", "MOT", "BIS", "HLN", "ALB", "LNK", "GTF", "XNA", "DAY", "ASE", "TVC", "IMT", "BRD", "DIK", "FCA", "GRR", "FWA", "EGE", "MLI", "MBS", "GFK", "RHI", "FNT", "LSE", "ICT", "AZO", "BMI", "RST", "OME", "BRW", "PSG", "YAK", "GST", "ITO", "OTZ", "EUG", "MFR", "RDM", "ACV", "SUN", "MMH", "CEC", "SMX", "RDD", "OTH", "PWM", "GSP", "GSO", "PBI", "PVD", "PNS", "TYS", "SAV", "ABE", "JAN", "ERI", "BHM", "ACY", "EAU", "SPI", "COD", "PAH", "CAE", "BTV", "GUC", "MOB", "MDT", "SCE", "STC", "HPN", "CAK", "CMI", "AVL", "HSV", "SUX", "LBE", "ALO", "MHK", "MHK", "DBQ", "AVP", "SGF", "COU", "ELM", "ROA", "CHA", "MYR", "CRW", "MQT", "CHO", "EVV", "SRQ", "MKG", "CMX", "TOL", "LBB", "AMA", "MAF", "CLD", "SAF", "CPR", "GCC", "LAR", "SHV", "HYS", "LFT", "RKS", "PUB", "PHF", "JMS", "SGU", "DVL", "SCC", "BRO", "VPS", "CRP", "TYR", "MLU", "BTR", "GPT", "MFE", "ECP", "GRK", "HRL", "AEX", "LRD", "CLL", "LCH", "HOB", "OAJ", "MGM", "MLB", "DAB", "TLH", "GNV", "EYW", "ILM", "FSM", "AGS", "DHN", "TRI", "VLD", "BQK", "FAY", "CSG", "EWN", "GTR", "ABY", "TWF", "EKO", "BTM", "PIH", "LWS", "VEL", "CDC", "CNY", "WYS", "LAW", "PIB", "BPT", "MEI", "ACT", "GGG", "GCK", "GRI", "JLN", "TXK", "SPS", "ABI", "SJT", "ROW", "ISP", "SWF", "ACK", "MVY", "HYA", "ESC", "PLN", "CIU", "APN", "BGM", "BGR", "ITH", "UST", "ORH", "ILG", "PBG", "IAG", "BET", "ADK", "CDV", "ADQ", "DLG", "AKN", "WRG"]


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityElementsHidden = true
        tableView.separatorColor = .gray
        self.navigationController?.navigationBar.isHidden = false
        mapView.isHidden = true
        tableView.isHidden = false
        callAirportListAPI()
    }

    private func setMapKitDelegate() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    //MARK: API Calls
    func callAirportListAPI() {
        let url = URL(string: "\(API.usaAirports)\(API.airlabAPIKey)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [], options: [])
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let airportResponse = json["response"] as? [[String: Any]] {
                var tempAirports = [Airport]()
                self.airports.removeAll()
                for airportDict in airportResponse {
                    if let airportData = try? JSONSerialization.data(withJSONObject: airportDict, options: []),
                       let airport = try? JSONDecoder().decode(Airport.self, from: airportData),  modelAirport.contains(airport.iataCode) {
                        tempAirports.append(airport)
                        print(airport)
                        print(airports.count)
                    }
                }
                tempAirports.sort { $0.iataCode < $1.iataCode }
                DispatchQueue.main.async {
                    self.airports = tempAirports
                    self.tableView.reloadData()
                    self.zoomToRegion()
                    self.setMapKitDelegate()
                    self.resetMap()
                }
            }
        }
        task.resume()
    }

    @IBAction func viewTypeSelect(_ sender: Any) {
        switch viewTypeSegment.selectedSegmentIndex {
        case 0:
            mapView.isHidden = true
            tableView.isHidden = false
        case 1:
            mapView.isHidden = false
            tableView.isHidden = true
        default:
            mapView.isHidden = true
            tableView.isHidden = false
        }
    }


    private func zoomToRegion() {
        guard let userLocation = mapView.userLocation.location else {
            return
        }
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        //mapView.showAnnotations(mapView.annotations, animated: false)
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
        let positions = airports.map { airport in
            return Position(airportCode: airport.iataCode, airportName: airport.name, latitude: airport.latitude, longitude: airport.longitude)
        }

        let annotations = positions.map { position -> PinAnnotation in
            return PinAnnotation(position: position, coordinate: CLLocationCoordinate2D(latitude: position.latitude.truncate(places: 6), longitude: position.longitude.truncate(places: 6)))
        }

        mapView.addAnnotations(annotations)
    }

}

extension AirportListVC : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if let textlabel = header.textLabel {
            textlabel.font = textlabel.font.withSize(18)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airports.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = airports[indexPath.row]
        var cell = UITableViewCell()
        cell.accessibilityElementsHidden = true
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = rowData.iataCode
        cell.detailTextLabel?.text = rowData.name
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = airports[indexPath.row]
        selectedAirport = rowData
        airportDelegate?.didSelectAirport(selectedAirport!)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.airportDelegate?.didSelectAirport(self.selectedAirport!)
        }
    }
}


// MARK: - Location Manager Delegate
extension AirportListVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLocation = locValue
    }
}


extension AirportListVC: MKMapViewDelegate {
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
            view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        }

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {

            if let annotation = view.annotation as? PinAnnotation, let airport = annotation.title {

                // Use the airport object to get the information you need
                print("Selected airport: \(airport)")
                dismiss(animated: true) { [self] in
                    self.selectedAirport = airports.first(where: { $0.iataCode == airport })

                    self.airportDelegate?.didSelectAirport(self.selectedAirport!)
                }
            }
        }
    }
}
