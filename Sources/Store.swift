//
//  Store.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 07/12/21.
//

import Combine
import Foundation

public class Store<S: State, D: Dependencies> {
  @Published var state: S
  
  public let dependencies: D
  
  var sideEffectContext: SideEffectContext<S, D> {
    SideEffectContext(dependencies: dependencies, getState: getStateClosure, dispatch: anyDispatchClosure)
  }
  
  public init(state: S, dependencies: D) {
    self.state = state
    self.dependencies = dependencies
  }
  
  private var getStateClosure: () -> S {
    return { [unowned self] in
      self.state
    }
  }
  
  private var anyDispatchClosure: AnyDispatch {
    return { [unowned self] dispatchable in
      try await self.anyDispatch(dispatchable)
    }
  }
    
  public func dispatch<T: ReturningSideEffect>(_ dispatchable: T) async throws -> T.ReturnType {
    try await self.anyDispatch(dispatchable) as! T.ReturnType
  }
  
  public func dispatch<T: SideEffect>(_ dispatchable: T) -> Void {
    Task(priority: .background) {
      try await self.anyDispatch(dispatchable)
    }
  }
  
  public func dispatch<T: StateUpdater>(_ dispatchable: T) -> Void {
    Task(priority: .background) {
      try await self.anyDispatch(dispatchable)
    }
  }
  
  @discardableResult
  public func anyDispatch(_ dispatchable: Dispatchable) async throws -> Any {
    if let sideEffect = dispatchable as? AnySideEffect {
      return try await sideEffect.anySideEffect(sideEffectContext)
    } else if let stateUpdater = dispatchable as? AnyStateUpdater {
      let newState = stateUpdater.anyUpdate(state)
      guard let typedNewState = newState as? S else {
        preconditionFailure("StateUpdater anyUpdate returned a wrong state type")
      }
      
      state = typedNewState
      return ()
    }
    
    fatalError("Invalid parameter")
  }
}
