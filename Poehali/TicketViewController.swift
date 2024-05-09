//
//  TicketViewController.swift
//  Poehali
//
//  Created by Nurken Kidirmaganbetov  on 09.05.2024.
//

import UIKit

class TicketViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        
        if let localUsername = UserDefaults.standard.string(forKey: "username") {
            self.username = localUsername
        } else {
            print("Username not found in local")
        }
        
        if let localSecret = UserDefaults.standard.string(forKey: "secret") {
            self.secret = localSecret
        } else {
            print("Token not found in local")
        }
    }
    
    @IBOutlet weak var absenceHeading: UILabel!
    
    @IBOutlet weak var absenceDescr: UILabel!
    
    @IBOutlet weak var firstTicketLabel: UILabel!
    
    @IBOutlet weak var secondTicketLabel: UILabel!
    
    @IBOutlet weak var thirdTicketLabel: UILabel!
    
    @objc func timerCallback() {
        if isFetchActive {
            return
        }
        
        Task {
            await self.handleGettingTickets()
            self.firstTicketLabel.text = self.firstTicketEventName
            self.secondTicketLabel.text = self.secondTicketEventName
            self.thirdTicketLabel.text = self.thirdTicketEventName
        }
    }
    
    var username = ""
    var secret = ""
    var timer: Timer? = nil
    var isFetchActive = false
    var tickets: [Ticket] = []
    
    var firstTicketEventName: String = ""
    var secondTicketEventName: String = ""
    var thirdTicketEventName: String = ""
    
    func handleGettingTickets() async {
        if(isFetchActive) {
            return
        }
        
        do {
            isFetchActive = true
            
            try await fetchTickets() { result in
                switch result {
                case .success(let data):
                    let gotTickets = data.tickets
                    
                    // Imitation of programmatic UI updates
                    for index in 0..<gotTickets.count {
                        if(index == 0) {
                            self.firstTicketEventName = String(gotTickets[index].event!)
                        } else if(index == 1) {
                            self.secondTicketEventName = String(gotTickets[index].event!)
                        } else if(index == 2) {
                            self.thirdTicketEventName = String(gotTickets[index].event!)
                        } else {
                            break;
                        }
                    }
                case .failure(let error):
                    print("Error:", error)
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        isFetchActive = false
    }
    
    func fetchTickets(completion: @escaping (Result<JSONTicketsAPIResponse, APIError>) -> Void) async throws {
        let urlString = "http://localhost:3001/api/v1/tickets/all/"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": self.username, "secret": self.secret]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error converting data to JSON in fetching tickets")
            throw APIError.jsonSerializationError
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error in fetching tickets: \(error)")
                return
            }

            // Check for response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if(httpResponse.statusCode != 200) {
                print("HTTP wrong status code in fetching tickets: \(httpResponse.statusCode)")
                return
            }

            // Check for data
            guard let responseData = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decodedJsonData = try decoder.decode(JSONTicketsAPIResponse.self, from: responseData)
                
                completion(.success(decodedJsonData))
            } catch {
                print(String(describing: error))
            }
        }
        
        task.resume()
    }
}

struct JSONTicketsAPIResponse: Codable {
    var tickets: [Ticket]
}

struct Ticket: Codable {
    var _id: String?
    var quantity: Int?
    var price: Int?
    var isArchived: Bool?
    var event: String?
}
