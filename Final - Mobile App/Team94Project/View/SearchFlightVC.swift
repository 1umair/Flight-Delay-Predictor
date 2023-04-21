

import UIKit

class SearchFlightVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bttnShowPrediction: UIButton!

    var selectedAirportTypeIndex = 0
    var dateValue = Date()
    var txtFieldDepartureAirport = UITextField()
    var txtFieldArrivalAirport = UITextField()
    var txtFieldDate = UITextField()
    var flightDate = ""
    var pickerType = ""
    var inputParameters = [String: Airport]()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        tableView.accessibilityElementsHidden = true
        tableView.separatorColor = .gray
        // callWeatherAPI()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    @IBAction func bttnShowMap(_ sender: UIButton) {
        if txtFieldDate.text == "" || txtFieldArrivalAirport.text == "" || txtFieldDepartureAirport.text == "" {
            showMissingFieldsError()
        }

        if txtFieldArrivalAirport.text == txtFieldDepartureAirport.text  {
            showValidationError()
        }
        self.performSegue (withIdentifier: MapVC.storyboardID, sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MapVC.storyboardID {
            if let destinationVC = segue.destination as? MapVC {
                destinationVC.inputParameters = inputParameters
            }
        }
    }

    func showDatePicker() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: AppStoryboard.Main.rawValue, bundle: nil)
        guard let datePickerViewController = mainStoryboard.instantiateViewController(withIdentifier: DatePickerVC.storyboardID) as? DatePickerVC else {
            return
        }
        datePickerViewController.delegate = self
        datePickerViewController.modalPresentationStyle = .pageSheet
        datePickerViewController.modalTransitionStyle = .coverVertical
        datePickerViewController.modalPresentationCapturesStatusBarAppearance = false
        present(datePickerViewController, animated: true, completion: nil)
    }

    func showAirportPicker() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: AppStoryboard.Main.rawValue, bundle: nil)
        guard let airportViewController = mainStoryboard.instantiateViewController(withIdentifier: AirportListVC.storyboardID) as? AirportListVC else {
            return
        }
        airportViewController.airportDelegate = self
        airportViewController.modalPresentationStyle = .pageSheet
        airportViewController.modalTransitionStyle = .coverVertical
        airportViewController.modalPresentationCapturesStatusBarAppearance = false
        present(airportViewController, animated: true, completion: nil)
    }

    func showMissingFieldsError() {
        var errorDesc = ""
        if txtFieldDepartureAirport.text == "" {
            errorDesc = Alert.ErrorMissingDestinationAirportField
        }else if txtFieldArrivalAirport.text == "" {
            errorDesc = Alert.ErrorMissingArrivalAirportField
        } else if txtFieldDate.text == "" {
            errorDesc = Alert.ErrorMissingDateField
        }

        let alert = UIAlertController(title: "Error", message: errorDesc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showValidationError() {
        let alert = UIAlertController(title: "Error", message: Alert.ErrorSameAirportMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SearchFlightVC : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView = .none
        header.backgroundColor = .clear
        if let textlabel = header.textLabel {
            textlabel.font = textlabel.font.withSize(14)
            textlabel.textColor = .systemBlue
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Enter Departure Airport Code"
        case 1:
            return "Enter Arrival Airport Code"
        case 2:
            return "Enter Flight Departing Date & Time"
        default:
            break
        }
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell.accessibilityElementsHidden = true
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "sourcecell", for: indexPath)
            cell.textLabel?.text = "Departure Airport:"
            cell.detailTextLabel?.text = ""
            cell.selectionStyle = .none

            // add text field to destination cell
            txtFieldDepartureAirport = UITextField(frame: CGRect(x: cell.contentView.bounds.width - 110, y: 10, width: 100, height: cell.contentView.bounds.height - 20))
            txtFieldDepartureAirport.placeholder = "Airport Code"
            txtFieldDepartureAirport.borderStyle = .none
            txtFieldDepartureAirport.isEnabled = false
            txtFieldDepartureAirport.textAlignment = .right
            txtFieldDepartureAirport.autocapitalizationType = .allCharacters
            txtFieldDepartureAirport.delegate = self
            cell.contentView.addSubview(txtFieldDepartureAirport)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "destinationcell", for: indexPath)
            cell.textLabel?.text = "Arrival Airport:"
            cell.detailTextLabel?.text = ""
            cell.selectionStyle = .none

            txtFieldArrivalAirport = UITextField(frame: CGRect(x: cell.contentView.bounds.width - 110, y: 10, width: 100, height: cell.contentView.bounds.height - 20))
            txtFieldArrivalAirport.placeholder = "Airport Code"
            txtFieldArrivalAirport.borderStyle = .none
            txtFieldArrivalAirport.isEnabled = false
            txtFieldArrivalAirport.textAlignment = .right
            txtFieldArrivalAirport.autocapitalizationType = .allCharacters
            txtFieldArrivalAirport.delegate = self
            cell.contentView.addSubview(txtFieldArrivalAirport)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "timecell", for: indexPath)
            cell.textLabel?.text = "Date & Time:"
            cell.detailTextLabel?.text = flightDate
            cell.selectionStyle = .none

            txtFieldDate = UITextField(frame: CGRect(x: cell.contentView.bounds.width - 230, y: 10, width: 230, height: cell.contentView.bounds.height - 20))
            txtFieldDate.placeholder = "Date & Time"
            txtFieldDate.borderStyle = .none
            txtFieldDate.isEnabled = false
            txtFieldDate.textAlignment = .right
            txtFieldDate.autocapitalizationType = .allCharacters
            txtFieldDate.delegate = self
            cell.contentView.addSubview(txtFieldDate)
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0,1:
            selectedAirportTypeIndex = indexPath.section
            showAirportPicker()
        case 2:
            showDatePicker()
        default:
            break
        }
    }
}


extension SearchFlightVC: AirportSelectionDelegate {
    func didSelectAirport(_ airportDetails: Airport) {
        if selectedAirportTypeIndex == 0 {
            inputParameters["DA"] = airportDetails
            txtFieldDepartureAirport.text = airportDetails.iataCode
        } else{
            inputParameters["AA"] = airportDetails
            txtFieldArrivalAirport.text = airportDetails.iataCode
        }
    }
}

extension SearchFlightVC: DatePickerVCDelegate {
    func datePickerViewController(_ viewController: DatePickerVC, didSelectDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        let dateString = dateFormatter.string(from: date)
        txtFieldDate.text = dateString
    }
}

extension SearchFlightVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 4 // restrict the text field to 4 characters
    }
}


extension SearchFlightVC {
    //MARK: API Calls
    func callWeatherAPI() {
        let latitude = 40.6413
        let longitude = -73.7781
        let forecastDays = 7
        let hourly = "windgusts_10m"
        let temperature_unit = "fahrenheit"
        let windspeed_unit = "mph"
        let timezone = "America/New_York"

        let url = API.forecast + "?latitude=\(latitude)&longitude=\(longitude)&forecast_days=\(forecastDays)&hourly=\(hourly)&temperature_unit=\(temperature_unit)&windspeed_unit=\(windspeed_unit)&timezone=\(timezone)"


        NetworkEngine.callGetAPI(api: url, adminRequired: false){ data, response, error in
            do {
                guard let data = data else { return }
                let decoder = JSONDecoder()
                let weather = try decoder.decode(Weather.self, from: data)
                print(weather)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
}
