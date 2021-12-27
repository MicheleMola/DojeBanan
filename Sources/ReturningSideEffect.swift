//
//  File.swift
//  
//
//  Created by Michele Mola on 27/12/21.
//

import Foundation

public protocol ReturningSideEffect: AnySideEffect {
  associatedtype S: State
  associatedtype D: Dependencies
  associatedtype ReturnType

  func sideEffect(_ context: SideEffectContext<S, D>) async throws -> ReturnType
}

public extension ReturningSideEffect {
  func anySideEffect(_ context: AnySideEffectContext) async throws -> Any {
    guard let typedSideEffectContext = context as? SideEffectContext<S, D> else {
      fatalError("Invalid SideEffectContext type.")
    }
    
    return try await sideEffect(typedSideEffectContext)
  }
}
