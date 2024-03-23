import UIKit

struct BalanceResponse: Codable {
    let balance: Int
}

// Define the Item struct to model the data fetched from the server.
struct Item: Decodable {
    let ItemName: String
    let itemRating: Double? // Assuming this can be null and is a string
    let totalPrice: Double? // Assuming this can be null and is a string
    let itemID: String? // Assuming this can be null and is a string
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Array to hold fetched items
    @IBOutlet weak var balanceLbl: UILabel!
    var items: [Item] = []
    
    @IBOutlet weak var tbl: UITableView! // Make sure this IBOutlet is connected to your UITableView in the storyboard.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
        fetchItems()
        fetchBalance()
    }
    
    
    private func fetchBalance() {
            guard let url = URL(string: "http://127.0.0.1:5000/getBalance") else { return }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                // Check for errors or no data
                guard let data = data, error == nil else {
                    print("Error fetching balance: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Attempt to decode the JSON response
                do {
                    let balanceResponse = try JSONDecoder().decode(BalanceResponse.self, from: data)
                    
                    // Update the label on the main thread
                    DispatchQueue.main.async {
                        self?.balanceLbl.text = "$\(balanceResponse.balance)"
                    }
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
    
    // Function to make the POST request and fetch items
    func fetchItems() {
        guard let url = URL(string: "http://127.0.0.1:5000/getRented") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // If your server expects a JSON body, uncomment and modify the following line accordingly:
        // request.httpBody = ...
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task2 = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Received response: \(responseString)")
            }
            // Existing JSON parsing code here
        }
        task2.resume()

        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let fetchedItems = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    self?.items = fetchedItems
                    self?.tbl.reloadData()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? customTableViewCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.name.text = item.ItemName
        cell.rating.text = item.itemRating.map { String($0) } ?? "0"
        cell.price.text = item.totalPrice.map { String($0) } ?? "0"

        
        return cell
    }
    
    
}

extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform the segue
        performSegue(withIdentifier: "firstToThird", sender: self.items[indexPath.row].itemID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "firstToThird" {
            if let destinationVC = segue.destination as? thirdViewController,
               let itemID = sender as? String {
                destinationVC.itemID = itemID
                destinationVC.hideRequest = true
            }
            
            
        }
    }
}
