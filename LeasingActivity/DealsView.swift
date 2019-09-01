//
//  ContentView.swift
//  LeasingActivity
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import SwiftUI
import Combine
import LeasingActivityBehavior

class ObservableDealShell: ObservableObject {
    let objectWillChange = PassthroughSubject<[Deal], Never>()
    var deals: [Deal] = [] {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send(self.deals)
            }
        }
    }
}

extension Deal: Identifiable { }

struct LeasingActivityServerRepository: ServerRepository {
    var successfulResponse: Bool = true
    
    func createDeal(requirementSize: Int, onComplete: @escaping (NetworkResult<Deal>) -> Void) {
        let url = URL(string: "http://localhost:8080/deals")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params = [
            "requirementSize": requirementSize
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])

        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                onComplete(.error)
                return
            }
            
            do {
                let deal = try JSONDecoder().decode(Deal.self, from: data)
                onComplete(.success(deal))
            } catch {
                print(error)
            }
        }
        
        urlSession.resume()
    }
}

struct DealsView: View {
    @ObservedObject var observed = observableDealShell
    
    var body: some View {
        VStack {
            Button(action: { dealShell.createDeal(requirementSize: 200) }) {
                Text("Create a Deal")
            }
            List(observed.deals) { deal in
                Text(self.dealDescription(for: deal))
            }
        }
    }
    
    func dealDescription(for deal: Deal) -> String {
        return "Deal Id: \(deal.id ?? -1), requirementSize: \(deal.requirementSize)"
    }
}

let dealShell = DealShell(repository: LeasingActivityServerRepository())
let observableDealShell = ObservableDealShell()
