import UIKit

// Define the Item struct to model the data fetched from the server.
struct Item2: Decodable {
    let itemName: String
    let itemRating: Double? // Assuming this can be null and is a string
    let price: Double? // Assuming this can be null and is a string
    let itemID: String? // Assuming this can be null and is a string
}

class secondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var txtfield: UITextField!
    // Array to hold fetched items
    var items: [Item2] = []
    

    @IBOutlet weak var tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
        fetchItems()
    }
    
    // Function to make the POST request and fetch items
    func fetchItems() {
        guard let url = URL(string: "http://127.0.0.1:5000/searchItems") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Removed the guard statement that checks if the text field is empty
        
        // Use the text field's text or an empty string if it's nil
        let nameValue = txtfield.text ?? ""
        
        // Create the JSON payload
        let jsonPayload: [String: Any] = ["name": nameValue]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonPayload, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON payload: \(error)")
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error in network request: \(String(describing: error))")
                return
            }
            
            // Debug print of the response, consider removing after ensuring it works
            if let responseString = String(data: data, encoding: .utf8) {
                print("Received response: \(responseString)")
            }
            
            do {
                let fetchedItems = try JSONDecoder().decode([Item2].self, from: data)
                DispatchQueue.main.async {
                    self?.items = fetchedItems
                    self?.tbl.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }

    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? secondTableViewCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.name.text = item.itemName
        cell.rating.text = String(item.itemRating ?? 0)
        cell.price.text = item.price != nil ? String(item.price!) : "Price not available"

        
        return cell
    }
    
    
    
    
    @IBAction func searchFunc(_ sender: Any) {
        fetchItems()
    }
}

extension secondViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform the segue
        performSegue(withIdentifier: "toItemSegue", sender: self.items[indexPath.row].itemID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemSegue" {
            if let destinationVC = segue.destination as? thirdViewController,
               let itemID = sender as? String {
                destinationVC.itemID = itemID
            }
        }
    }
}
