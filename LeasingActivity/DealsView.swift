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
    
    func createDeal(data: Data, onComplete: @escaping (NetworkResult<Data>) -> Void) {
        let url = URL(string: "http://localhost:8080/deals")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = data

        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                onComplete(.error)
                return
            }
            onComplete(.success(data))
        }
        
        urlSession.resume()
    }
    
    func viewDeals(onComplete: @escaping (NetworkResult<Data>) -> Void) {
        let url = URL(string: "http://localhost:8080/deals")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                onComplete(.error)
                return
            }
            onComplete(.success(data))
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
        }.onAppear { dealShell.viewDeals() }
    }
    
    func dealDescription(for deal: Deal) -> String {
        return "Deal Id: \(deal.id ?? -1), requirementSize: \(deal.requirementSize)"
    }
}

let dealShell = DealShell(serverRepository: LeasingActivityServerRepository())
let observableDealShell = ObservableDealShell()
