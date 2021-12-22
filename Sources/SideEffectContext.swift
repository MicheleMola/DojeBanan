//
//  SideEffectContext.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import Foundation

public struct SideEffectContext<S: State, D: Dependencies> {
  private let getStateClosure: () -> S
  
  private let dispatchClosure: AnyDispatch
  
  let dependencies: D
  
  init(dependencies: D, getState: @escaping () -> S, dispatch: @escaping AnyDispatch) {
    self.getStateClosure = getState
    self.dispatchClosure = dispatch
    self.dependencies = dependencies
  }
  
  public func getState() -> S {
    getStateClosure()
  }
  
  public func dispatch(_ dispatchable: Dispatchable) {
    Task(priority: .background) {
      try? await dispatchClosure(dispatchable)
    }
  }
}

public protocol AnySideEffectContext {
  func getAnyState() -> State
}

extension SideEffectContext: AnySideEffectContext {
  public func getAnyState() -> State {
    getState()
  }
}
