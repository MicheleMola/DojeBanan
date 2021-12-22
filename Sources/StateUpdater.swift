//
//  StateUpdater.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import Foundation

public protocol StateUpdater: AnyStateUpdater {
  associatedtype S: State

  func update(_ state: inout S)
}

public protocol AnyStateUpdater: Dispatchable {
  func anyUpdate(_ state: State) -> State
}

public extension StateUpdater {
  func anyUpdate(_ state: State) -> State {
    guard var typedState = state as? S else {
      fatalError("Invalid State type.")
    }
    
    update(&typedState)
    return typedState
  }
}
