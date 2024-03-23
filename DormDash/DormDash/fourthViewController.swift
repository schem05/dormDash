import UIKit

struct Item9: Decodable {
    let ItemName: String
    let itemRating: Double? // Assuming this can be null and is a string
    let totalPrice: Double? // Assuming this can be null and is a string
    let itemID: String? // Assuming this can be null and is a string
}
// Define the Item struct to model the data fetched from the server.
class fourthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Array to hold fetched items
    var items: [Item9] = []
    
    @IBOutlet weak var tbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
        fetchItems()
    }
    
    // Function to make the POST request and fetch items
    func fetchItems() {
        guard let url = URL(string: "http://127.0.0.1:5000/getRequested") else { return }
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
                let fetchedItems = try JSONDecoder().decode([Item9].self, from: data)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? fourthTableViewCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.name.text = item.ItemName
        cell.rating.text = item.itemRating.map { String($0) } ?? "0"

        
        
        return cell
    }
    
    
    
}

extension fourthViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform the segue
        performSegue(withIdentifier: "fourthToThird", sender: self.items[indexPath.row].itemID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fourthToThird" {
            if let destinationVC = segue.destination as? thirdViewController,
               let itemID = sender as? String {
                destinationVC.itemID = itemID
                destinationVC.hideRequest = true
            }
            
            
        }
    }
}
