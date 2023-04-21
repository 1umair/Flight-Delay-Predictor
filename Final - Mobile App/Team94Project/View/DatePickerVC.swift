
import UIKit

protocol DatePickerVCDelegate: AnyObject {
    func datePickerViewController(_ viewController: DatePickerVC, didSelectDate date: Date)
}

class DatePickerVC: UIViewController {
    weak var delegate: DatePickerVCDelegate?

    @IBOutlet weak var datePicker: UIDatePicker!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date() // set minimum date to current date
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 16, to: Date()) // set maximum date to 16 days in future
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.datePickerViewController(self, didSelectDate: self.datePicker.date)
        }
    }
}
