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
  
  public let dependencies: D
  
  init(dependencies: D, getState: @escaping () -> S, dispatch: @escaping AnyDispatch) {
    self.getStateClosure = getState
    self.dispatchClosure = dispatch
    self.dependencies = dependencies
  }
  
  public func getState() -> S {
    getStateClosure()
  }
  
  public func dispatch<T: ReturningSideEffect>(_ dispatchable: T) async throws -> T.ReturnType {
    try await dispatchClosure(dispatchable) as! T.ReturnType
  }
  
  public func dispatch<T: SideEffect>(_ dispatchable: T) async throws -> Void {
    let _ = try await dispatchClosure(dispatchable)
  }
  
  public func dispatch<T: StateUpdater>(_ dispatchable: T) async -> Void {
    let _ = try? await dispatchClosure(dispatchable)
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
