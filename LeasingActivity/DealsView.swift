//
//  ContentView.swift
//  LeasingActivity
//
//  Created by Alex Weisberger on 8/15/19.
//  Copyright © 2019 Alex Weisberger. All rights reserved.
//

import SwiftUI

class DealShell {
    let repository: ServerRepository
    var deals: [Deal] = []
    
    init(repository: ServerRepository) {
        self.repository = repository
    }
    
    func createDeal(requirementSize: Int) {
        repository.createDeal(requirementSize: requirementSize) { result in
            switch result {
            case let .success(deal):
                deals.append(deal)
            default:
                break
            }
        }
    }
}

enum NetworkResult<T> {
    case error
    case success(T)
}

struct Deal {
    let id: Int?
    let requirementSize: Int
}

protocol ServerRepository {
    var successfulResponse: Bool { get set }
    
    func createDeal(requirementSize: Int, onComplete: (NetworkResult<Deal>) -> Void)
}

struct StubServerRepository: ServerRepository {
    var successfulResponse: Bool = true
    
    func createDeal(requirementSize: Int, onComplete: (NetworkResult<Deal>) -> Void) {
        if successfulResponse {
            onComplete(.success(Deal(id: 1, requirementSize: requirementSize)))
        } else {
            onComplete(.error)
        }
    }
}

struct DealsView: View {
    var body: some View {
        Text("Hello World")
    }
}
