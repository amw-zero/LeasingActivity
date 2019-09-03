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

func makeRequest(
    _ path: String,
    method: String = "GET",
    body: Data? = nil,
    onComplete: @escaping (NetworkResult<Data>) -> Void
) {
    let url = URL(string: path)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = method
    
    if let body = body {
        request.httpBody = body
    }

    let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            onComplete(.error)
            return
        }
        onComplete(.success(data))
    }
    
    urlSession.resume()
}

struct LeasingActivityServerRepository: ServerRepository {
    var successfulResponse: Bool = true
    static let dealsEndpoint = "http://localhost:8080/deals"
    
    func createDeal(data: Data, onComplete: @escaping (NetworkResult<Data>) -> Void) {
        makeRequest(
            LeasingActivityServerRepository.dealsEndpoint,
            method: "POST",
            body: data,
            onComplete: onComplete
        )
    }
    
    func viewDeals(onComplete: @escaping (NetworkResult<Data>) -> Void) {
        makeRequest(
            LeasingActivityServerRepository.dealsEndpoint,
            onComplete: onComplete
        )
    }
}

struct DealsView: View {
    @ObservedObject var observed = observableDealShell
    
    var body: some View {
        VStack {
            Button(action: { dealShell.createDeal(requirementSize: 200) }) {
                Text("Create a Deal")
            }
            if observed.deals.count == 0 {
                Text("You have no deals. Create some.")
            } else {
                List(observed.deals) { deal in
                    Text(self.dealDescription(for: deal))
                }
            }
        }.onAppear { dealShell.viewDeals() }
    }
    
    func dealDescription(for deal: Deal) -> String {
        return "Deal Id: \(deal.id ?? -1), requirementSize: \(deal.requirementSize)"
    }
}

let dealShell = DealShell(serverRepository: LeasingActivityServerRepository())
let observableDealShell = ObservableDealShell()
