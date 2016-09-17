import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class AddTripViewController: UIViewController {
	
	let createTripURL = "http://192.168.1.65:54321/api/trip/"
	/// Error code generated by Alamofire if no connection established
	let offlineErrorCode = -1004
	@IBOutlet weak var startDatePicker: UIDatePicker!
	@IBOutlet weak var endDatePicker: UIDatePicker!
	@IBOutlet weak var tripNameField: UITextField!
	@IBOutlet weak var tripCityField: UITextField!
	
	@IBAction func startDatePicker(sender: AnyObject) {
		/// Format date to simpler string format before making POST request
		/// Format: DD-MM-YYYY
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
		
	}
	
	@IBAction func endDatePicker(sender: AnyObject) {
		/// Format date to simpler string format before making POST request
		/// Format: DD-MM-YYYY
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
	}
	
	
	@IBAction func addTrip(sender: AnyObject) {
		validateFields()
	}
	
	func validateFields(){
		if(tripNameField.text!.isEmpty) || (tripCityField.text!.isEmpty) {
			alertMessage("Empty text fields", alertMessage: "Please fill out all text fields when registering.")
		}
		createTrip()
	}
	
	func createTrip() {
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
		let chosenStartDate = dateFormatter.stringFromDate(startDatePicker.date)
		let chosenEndDate = dateFormatter.stringFromDate(endDatePicker.date)
		
		let parameters = ["tripName": tripNameField.text as! AnyObject,
		                  "tripCity": tripCityField.text as! AnyObject,
		                  "startDate": chosenStartDate,
		                  "endDate": chosenEndDate
		]
		let alamoManager = Manager.sharedInstance
		alamoManager.session.configuration.HTTPAdditionalHeaders = [
			"Content-Type":"application/json"
		]
		
		/// Alamofire request made with validated params returend with the response.
		alamoManager.request(.POST,createTripURL,parameters: parameters, encoding: .JSON).validate().responseJSON { [weak self] serverResponse in
			
			
			// Before attempting to parse result, check if server is offline
			if serverResponse.result.error!.code == self!.offlineErrorCode {
				self!.alertMessage("Connection Error", alertMessage: "We can't reach the service at the moment. Please contact the admin.")
				return
			}
			
			/// SwiftyJSON used to easily parse JSON response, code sent by response includes message that is passed to message functions for display
			let data = serverResponse.data
			let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
			
			/// Switch on the HTTP code response from the service
			switch serverResponse.response!.statusCode {
			case 200:
				self!.successMessage("Success!", alertMessage: responseData!)
				///self!.saveOffline()
				break
			case 400:
				self!.alertMessage("Invalid details", alertMessage: responseData!)
				break
			default: break
			}
		}
	}
	
	/// Popup alert that can be dismissed. Used to inform/warn the user as a result of their action not being accepted.
	///
	/// - Parameter alertTitle: String used as title of the alert popup
	/// - Parameter alertMessage: String used as body of the alert popup
	func alertMessage(alertTitle: String, alertMessage: String){
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	/// Popup alert used when the user succesfully registers. On proceed press, function to move to signed in application view called.
	///
	/// - Parameter alertTitle: String used as title of the success popup
	/// - Parameter alertMessage: String used as body of the success popup
	func successMessage(alertTitle: String, alertMessage: String) {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Proceed", style: .Default, handler: { action in
			self.moveToTrip()}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	/// Once called, moves to a new storyboard identified as 'InitialController' in the main storyboard after login
	func moveToTrip(){
		let storyboard = UIStoryboard(name: "Trip", bundle: nil)
		let controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
		self.presentViewController(controller, animated: true, completion: nil)
	}
}