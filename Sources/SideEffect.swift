//
//  SideEffect.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import Foundation

public protocol AnySideEffect: Dispatchable {
  func anySideEffect(_ context: AnySideEffectContext) async throws -> Any
}

public protocol SideEffect: AnySideEffect {
  associatedtype S: State
  associatedtype D: Dependencies

  func sideEffect(_ context: SideEffectContext<S, D>) async throws
}

public extension SideEffect {
  func anySideEffect(_ context: AnySideEffectContext) async throws -> Any {
    guard let typedSideEffectContext = context as? SideEffectContext<S, D> else {
      fatalError("Invalid SideEffectContext type.")
    }
    
    try await sideEffect(typedSideEffectContext)
    return ()
  }
}
