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
    
    func viewDeals(queryParams: String?, onComplete: @escaping (NetworkResult<Data>) -> Void) {
        var endpoint = LeasingActivityServerRepository.dealsEndpoint
        if let queryParams = queryParams {
            endpoint += "?\(queryParams)"
        }
        
        makeRequest(endpoint, onComplete: onComplete)
    }
}

struct DealsView: View {
    @EnvironmentObject var observed: ObservableDealShell
    
    var body: some View {
        NavigationView {
            VStack {
                if observed.deals.count == 0 {
                    Button("Clear Filter") {
                        dealShell.viewDeals()
                    }
                    Text("You have no deals. Create some.")
                } else {
                    FilterableDealList()
                }
                NavigationLink(destination: DealForm()) {
                    Text("Create Deal")
                }
            }
            .onAppear { dealShell.viewDeals() }
            .navigationBarTitle("Leasing Activity")
        }
    }
}

struct FilterableDealList: View {
    @EnvironmentObject var observed: ObservableDealShell
    @State var tenantNameFilter: String = ""
    
    var body: some View {
        Group {
            HStack {
                TextField("Filter by Tenant Name", text: $tenantNameFilter)
                Button("Filter") {
                    dealShell.viewDeals(filter: .tenantName(self.tenantNameFilter))
                }
            }.padding()
            Button("Clear Filter") {
                dealShell.viewDeals()
            }
            List(observed.deals) { deal in
                Text(self.dealDescription(for: deal))
            }
        }
    }
    
    func dealDescription(for deal: Deal) -> String {
        return "\(deal.tenantName) | \(deal.requirementSize)sf"
    }
}

struct DealForm: View {
    @State var requirementSize: String = ""
    @State var tenantName: String = ""

    static var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.none
        return f
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Requirement Size", text: $requirementSize)
                TextField("Tenant Name", text: $tenantName)
            }
            Section {
                Button("Save") {
                    if !self.requirementSize.isEmpty, let size = Int(self.requirementSize) {
                        dealShell.createDeal(
                            requirementSize: size,
                            tenantName: self.tenantName
                        )
                    }
                }
            }
        }
        .navigationBarTitle("Create a Deal")
    }
}

let dealShell = DealShell(serverRepository: LeasingActivityServerRepository())
let observableDealShell = ObservableDealShell()
