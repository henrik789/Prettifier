import UIKit
import Prettifier

class ViewController: UIViewController {
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCSEK"
    var dictionary: [String: Any] = [:]
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJSON()
    }
    
    func getJSON() {
        
        guard let url = URL(string: baseURL) else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                var jsonResponse: [String: Any] = [:]
                jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: []) as! [String : Any]
                self.dictionary = jsonResponse
                self.setJSONText()
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    func setJSONText(){
        DispatchQueue.main.async {
            print(self.dictionary)
            self.textView.attributedText = prettyString(fromDictionary: self.dictionary)
        }
    }
}
