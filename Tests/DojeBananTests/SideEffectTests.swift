//
//  File.swift
//  
//
//  Created by Michele Mola on 23/01/22.
//

import XCTest

@testable import DojeBanan

final class SideEffectTests: XCTestCase {
  func testDispatch_invokesTheSideEffect() async throws {
    let store = Store(state: AppState(), dependencies: AppDependencies())
    let expectation = self.expectation(description: "SideEffect is invoked")
    
    try await store.sideEffectContext.dispatch(SideEffectWithDelay(delay: 0) { _ in expectation.fulfill() })
    
    await self.waitForExpectations(timeout: 10)
  }
  
  func testDispatch_invokesTheSideEffectWithTheSameDependencyContainer() async throws {
    var firstDependencies: AppDependencies?
    var secondDependencies: AppDependencies?
    let sideEffect1 = SideEffectWithDelay(delay: 0) { context in firstDependencies = context.dependencies }
    let sideEffect2 = SideEffectWithDelay(delay: 0) { context in secondDependencies = context.dependencies }
    
    let store = Store(state: AppState(), dependencies: AppDependencies())

    try await store.sideEffectContext.dispatch(sideEffect1)
    try await store.sideEffectContext.dispatch(sideEffect2)
    
    XCTAssertTrue(firstDependencies == secondDependencies)
  }
  
  func testDispatch_invokesTheSideEffectsInProperOrder() async throws {
    var invocationResults: [String] = []
    
    let sideEffect1 = SideEffectWithDelay(delay: 3) { _ in invocationResults.append("1") }
    let sideEffect2 = SideEffectWithDelay(delay: 1) { _ in invocationResults.append("2") }
    let sideEffect3 = SideEffectWithDelay(delay: 0) { _ in invocationResults.append("3") }
    
    let store = Store(state: AppState(), dependencies: AppDependencies())
    
    try await store.sideEffectContext.dispatch(sideEffect1)
    try await store.sideEffectContext.dispatch(sideEffect2)
    try await store.sideEffectContext.dispatch(sideEffect3)
    
    XCTAssertEqual(invocationResults, ["1", "2", "3"])
  }
  
  func testDispatch_whenDispatchingFromSideEffect_dispatchesCorrectly() async throws {
    var invocationResults: [String] = []
    
    let sideEffect1 = SideEffectWithDelay(delay: 3) { _ in invocationResults.append("1") }
    let sideEffect2 = SideEffectWithDelay(delay: 1) { context in
      try await context.dispatch(sideEffect1)
      
      invocationResults.append("2")
    }
    let sideEffect3 = SideEffectWithDelay(delay: 0) { _ in invocationResults.append("3") }
    
    let store = Store(state: AppState(), dependencies: AppDependencies())
    
    try await store.sideEffectContext.dispatch(sideEffect2)
    try await store.sideEffectContext.dispatch(sideEffect3)
    
    XCTAssertEqual(invocationResults, ["1", "2", "3"])
  }
  
  func testDispatch_whenDispatchingBothStateUpdatersAndSideEffects_handlesAllOfThem() async throws {
    let todo = Todo(title: "title", id: "id")
    let user = User(username: "username")
    
    var firstState: AppState?
    var secondState: AppState?
    
    let sideEffect1 = SideEffectWithDelay { context in
      firstState = context.getState()
    }
    
    let sideEffect2 = SideEffectWithDelay { context in
      secondState = context.getState()
    }
    
    let addTodo = AddTodo(todo: todo)
    let addUser = AddUser(user: user)
    
    let store = Store(state: AppState(), dependencies: AppDependencies())
    
    await store.sideEffectContext.dispatch(addTodo)
    try await store.sideEffectContext.dispatch(sideEffect1)
    await store.sideEffectContext.dispatch(addUser)
    try await store.sideEffectContext.dispatch(sideEffect2)
    
    XCTAssertEqual(firstState?.todo.todos, [todo])
    XCTAssertEqual(firstState?.user.users.isEmpty, true)
    
    XCTAssertEqual(secondState?.todo.todos, [todo])
    XCTAssertEqual(secondState?.user.users, [user])
  }
  
  func testGetState_returnsTheUpdatedState() async throws {
    let todo = Todo(title: "title", id: "id")
    var firstState: AppState?
    var secondState: AppState?
    
    let store = Store(state: AppState(), dependencies: AppDependencies())

    let sideEffect = SideEffectWithDelay { context in
      firstState = context.getState()
      await context.dispatch(AddTodo(todo: todo))
      secondState = context.getState()
    }
    
    try await store.sideEffectContext.dispatch(sideEffect)
    
    XCTAssertEqual(firstState?.todo.todos.count, 0)
    XCTAssertEqual(secondState?.todo.todos.count, 1)
    XCTAssertEqual(secondState?.todo.todos.first, todo)
  }
  
  func testDispatch_propagatesErrors() async throws {
    let expectedError = NSError(domain: "Test error", code: -1, userInfo: nil)
    let store = Store(state: AppState(), dependencies: AppDependencies())
    let expectation = self.expectation(description: "SideEffects and StatUpdaters are invoked")
    
    let sideEffect = SideEffectWithDelay { _ in throw expectedError }
    
    do {
      try await store.sideEffectContext.dispatch(sideEffect)
      
      XCTFail("then should not be invoked")
    } catch {
      XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
      expectation.fulfill()
    }
    
    await self.waitForExpectations(timeout: 10)
  }
  
  func testReturningSideEffect() async throws {
    let store = Store(state: AppState(), dependencies: AppDependencies())

    let result = try await store.sideEffectContext.dispatch(Multiply(a: 5, b: 2))
    
    XCTAssertEqual(result, 10)
  }
  
  func testReturningSideEffect_whenNestedSideEffect_returnsComputedValue() async throws {
    let store = Store(state: AppState(), dependencies: AppDependencies())

    let result = try await store.sideEffectContext.dispatch(ReentrantMultiply(a: 5, b: 2))
    
    XCTAssertEqual(result, 20)
  }
}
