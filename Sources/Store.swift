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
  
  let dependencies: D
  
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
      self.dispatch(dispatchable)
    }
  }
    
  public func dispatch(_ dispatchable: Dispatchable) {
    if let sideEffect = dispatchable as? AnySideEffect {
      Task(priority: .background) {
        try? await sideEffect.anySideEffect(sideEffectContext)
      }
    } else if let stateUpdater = dispatchable as? AnyStateUpdater {
      let newState = stateUpdater.anyUpdate(state)
      guard let typedNewState = newState as? S else {
        preconditionFailure("StateUpdater anyUpdate returned a wrong state type")
      }
      
      state = typedNewState
    }
  }
}
