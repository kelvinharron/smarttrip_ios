import Alamofire
import SwiftyJSON
import RealmSwift

/// Login class defines the logic of the login view controller
class LoginViewController: UIViewController {
	
	/// API endpoint for logging in to use the service
	let loginURL = "http://192.168.1.65:54321/api/user/login"
	/// Email textfield from the storyboard view controller
	@IBOutlet weak var emailField: UITextField!
	/// Passwordtextfield from the storyboard view controller
	@IBOutlet weak var passwordField: UITextField!
	/// Error code generated by Alamofire if no connection established
	let offlineErrorCode = -1004
	
	/// Swift lifecycle function, called only once when the view is loaded
	override func viewDidLoad() {
		super.viewDidLoad()
		definesPresentationContext = true
	}
	
	/// Login button has an action defined from the storyboard view controller, allows us to complete validation on login request when pressed
	@IBAction func loginButton(sender: AnyObject) {
		validateFields()
	}
	
	/// Local validation for signup is simply ensuring no blank fields, the rest of validation is handled at the server upon request
	/// If no validation errors, call made to checkRequest function
	func validateFields() {
		if (emailField.text!.isEmpty) || (passwordField.text!.isEmpty) {
			alertMessage("Empty Fields", alertMessage: "Please fill out your email and password.")
		} else {
			checkRequest()
		}
	}
	
	/// POST request made to service to login user.
	/// First wrap textfield input into a parameter object required for post
	/// Custom alamofire manager defined as we need to specify the HTTP header type as json
	func checkRequest(){
		let parameters = ["email": emailField.text as! AnyObject,
		                  "password": passwordField.text as! AnyObject
		]
		let alamoManager = Manager.sharedInstance
		alamoManager.session.configuration.HTTPAdditionalHeaders = [
			"Content-Type":"application/json"
		]
		
		/// Alamofire request made with validated params returned with the response.
		alamoManager.request(.POST,loginURL,parameters: parameters, encoding: .JSON).validate().responseJSON { [weak self] serverResponse in
			
			// Before attempting to parse result, check if server is offline
			if (serverResponse.result.error!.code == self!.offlineErrorCode) {
				self!.alertMessage("Connection Error", alertMessage: "We can't reach the service at the moment. Please contact the admin.")
				return
			}
			
			/// SwiftyJSON used to easily parse JSON response, code sent by response includes message that is passed to message functions for display
			let data = serverResponse.data
			let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
			
			/// Switch on the HTTP code response from the service
			switch serverResponse.response!.statusCode {
			case 200:
				self!.successMessage("Login Success! ", alertMessage: responseData!)
				break
			case 400:
				self!.alertMessage("Invalid Details", alertMessage: responseData!)
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
		self.presentViewController(alert, animated: true){}
	}
	
	/// Popup alert used when the user succesfully registers. On proceed press, function to move to signed in application view called.
	///
	/// - Parameter alertTitle: String used as title of the success popup
	/// - Parameter alertMessage: String used as body of the success popup
	func successMessage(alertTitle: String, alertMessage: String) {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Proceed", style: .Default, handler: { action in
			self.moveToMainView()}))
		self.presentViewController(alert, animated: true){}
		
	}
	
	/// Once called, moves to a new storyboard identified as 'InitialController' in the main storyboard after login
	func moveToMainView(){
		var storyboard = UIStoryboard(name: "Trip", bundle: nil)
		var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UIViewController
		self.presentViewController(controller, animated: true, completion: nil)
	}
	
	func checkOfflineUser(){
		let realm = try! Realm()
		let offlineUser = realm.objects(User)
		
		/// if (offlineUser.email == emailField.text!) {
		///     print(login) success
		///  }
	}
}