//
//  File.swift
//  
//
//  Created by Michele Mola on 22/01/22.
//

import DojeBanan
import Foundation

protocol TestStateUpdater: StateUpdater where S == AppState {}

protocol TestSideEffect: SideEffect where S == AppState, D == AppDependencies {}

protocol AppReturningSideEffect: ReturningSideEffect {
  associatedtype ReturnType
  
  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) async throws -> ReturnType
}

struct AddTodo: TestStateUpdater {
  let todo: Todo

  func updateState(_ state: inout AppState) {
    state.todo.todos.append(self.todo)
  }
}

struct AddUser: TestStateUpdater {
  let user: User

  func updateState(_ state: inout AppState) {
    state.user.users.append(self.user)
  }
}

struct AddTodoWithDelay: TestStateUpdater {
  let todo: Todo
  let waitingTime: TimeInterval
  
  func updateState(_ state: inout AppState) {
    // Note: this is just for testing, never do things like this in real apps
    Thread.sleep(forTimeInterval: self.waitingTime)
    state.todo.todos.append(self.todo)
  }
}

struct Multiply: AppReturningSideEffect {
  let a: Int
  let b: Int

  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) async throws -> Int {
    return a * b
  }
}

struct ReentrantMultiply: AppReturningSideEffect {
  let a: Int
  let b: Int
  
  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) async throws -> Int {
    let multiply = try await context.dispatch(Multiply(a: a, b: b))
    return multiply * b
  }
}

struct SideEffectWithDelay: TestSideEffect {
  let delay: TimeInterval
  var invocationClosure: (_ context: SideEffectContext<AppState, AppDependencies>) async throws -> Void
  
  init(
    delay: TimeInterval = 0,
    invocationClosure: @escaping (_ context: SideEffectContext<AppState, AppDependencies>) async throws -> Void = { _ in }
  ) {
    self.delay = delay
    self.invocationClosure = invocationClosure
  }
  
  func sideEffect(_ context: SideEffectContext<AppState, AppDependencies>) async throws {
    try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
    
    try await invocationClosure(context)
  }
}
