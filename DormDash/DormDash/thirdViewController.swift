import UIKit

// Ensure Item3 remains untouched and Decodable
struct Item3: Decodable {
    var active: Bool
    var address: String
    var city: String
    var description: String
    var instructions: String
    var itemID: String
    var itemName: String
    var merchantID: String
    var pictures: [String]
    var price: Double
    var rating: Double
    var quality: String
    var reviews: [String]
}

class thirdViewController: UIViewController {

    @IBOutlet weak var reviewRight: UIButton!
    @IBOutlet weak var reviewLeft: UIButton!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var reviewAnon: UILabel!
    @IBOutlet weak var reviewBase: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var totalPrice: UILabel! // price * term
    @IBOutlet weak var termDays: UILabel!
    @IBOutlet weak var instruc: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var merchant: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var price: UILabel!
    var itemID: String?
    var hideRequest: Bool?
    var globRev = [String]()
    var globIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if let hideRequest = hideRequest{
            requestBtn.isHidden = true
        }
        reviewRight.isHidden = true
        reviewLeft.isHidden = true
        reviewText.isHidden = true
        reviewAnon.isHidden = true
        reviewBase.isHidden = true
        // Fetch item details when the view loads
        if let itemID = itemID {
            fetchItemDetails(with: itemID)
        }
    }
    @IBAction func hideReviews(_ sender: Any) {
        reviewRight.isHidden = true
        reviewLeft.isHidden = true
        reviewText.isHidden = true
        reviewAnon.isHidden = true
        reviewBase.isHidden = true
    }
    @IBAction func showReviews(_ sender: Any) {
        reviewText.text = globRev[globIndex]
        reviewRight.isHidden = false
        reviewLeft.isHidden = false
        reviewText.isHidden = false
        reviewAnon.isHidden = false
        reviewBase.isHidden = false
    }
    
    struct Payload: Encodable {
        let itemID: String
        let price: Double
    }
    
    @IBAction func approveItemRent(_ sender: Any) {
        guard let url = URL(string: "http://127.0.0.1:5000/makePurchase") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = Payload(itemID: itemID ?? "", price: globPrice)
        do {
            let data = try JSONEncoder().encode(payload)
            request.httpBody = data
        } catch {
            print("Error encoding itemID: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching item details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let itemDetails = try JSONDecoder().decode(Item3.self, from: data)
                DispatchQueue.main.async {
                    print("Tig")
                    print(itemDetails)
                    self?.updateUI(with: itemDetails)
                }
            } catch {
                print("Error decoding item details: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    @IBAction func createRequest(_ sender: Any) {
        guard let url = URL(string: "http://127.0.0.1:5000/createRequest") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = Payload(itemID: itemID ?? "", price: (globPrice * 3))
        do {
            let data = try JSONEncoder().encode(payload)
            request.httpBody = data
        } catch {
            print("Error encoding itemID: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching item details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let itemDetails = try JSONDecoder().decode(Item3.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI(with: itemDetails)
                }
            } catch {
                print("Error decoding item details: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func fetchItemDetails(with itemID: String) {
        guard let url = URL(string: "http://127.0.0.1:5000/getItemDetails") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["itemID": itemID]
        do {
            let data = try JSONEncoder().encode(payload)
            request.httpBody = data
        } catch {
            print("Error encoding itemID: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching item details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let itemDetails = try JSONDecoder().decode(Item3.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI(with: itemDetails)
                }
            } catch {
                print("Error decoding item details: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    @IBOutlet weak var requestBtn: UIButton!
    
    @IBAction func requestBtn(_ sender: Any) {
    }
    @IBAction func goLeft(_ sender: Any) {
        globIndex = (globIndex + 1) % globRev.count
        
        reviewText.text = globRev[globIndex]
    }
    
    @IBAction func goRight(_ sender: Any) {
        
        globIndex = (globIndex - 1) % globRev.count
        
        reviewText.text = globRev[globIndex]
        
    }
    var globPrice: Double = 0.0
    private func updateUI(with item: Item3) {
        rating.text = String(item.rating) + "/5.0"
        globRev = item.reviews
        nameLbl.text = item.itemName
        price.text = "\(item.price)"
        globPrice = item.price
        instruc.text = item.instructions
        address.text = "\(item.address), \(item.city)"
        desc.text = item.description
        merchant.text = item.merchantID
        // Assuming rating is calculated or obtained differently as it's not in Item3
        
        totalPrice.text = "\(3 * item.price)"
        // Assuming termDays is a static value or calculated separately
        // totalPrice will need to be calculated based on price and termDays
        // This example assumes termDays is static or already set; you will need to adjust accordingly
    }
}
