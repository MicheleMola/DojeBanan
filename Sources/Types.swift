//
//  Types.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

public protocol State {}

public protocol Dependencies {}

public protocol Dispatchable {}

public typealias AnyDispatch = (_: Dispatchable) async throws -> Void

public protocol ViewModel {
  func subscribe()
  
  func unsubscribe()
}
