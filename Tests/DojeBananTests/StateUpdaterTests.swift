import XCTest

@testable import DojeBanan

class StateUpdaterTests: XCTestCase {
  func testDispatch_invokesTheStateUpdater() async {
    let todo = Todo(title: "test", id: "ABC")
    let store = Store(state: AppState(), dependencies: AppDependencies())
    
    await store.sideEffectContext.dispatch(AddTodo(todo: todo))
    
    XCTAssertEqual(store.state.todo.todos, [todo])
  }
  
  func testDispatch_whenChained_areInvokedInOrder() async {
    let todo = Todo(title: "test", id: "ABC")
    let user = User(username: "the_username")
    
    let store = Store(state: AppState(), dependencies: AppDependencies())

    await store.sideEffectContext.dispatch(AddTodo(todo: todo))
    XCTAssertEqual(store.state.todo.todos, [todo])
    XCTAssertTrue(store.state.user.users.isEmpty)
    
    await store.sideEffectContext.dispatch(AddUser(user: user))
    XCTAssertEqual(store.state.todo.todos, [todo])
    XCTAssertEqual(store.state.user.users, [user])
  }
  
  func testDispatch_whenNotChained_areInvokedInOrder() async {
    let todo1 = Todo(title: "test", id: "ABC")
    let todo2 = Todo(title: "test1", id: "DEF")
    let todo3 = Todo(title: "test2", id: "GHI")
    
    let store = Store(state: AppState(), dependencies: AppDependencies())

    let stateUpdater1 = AddTodoWithDelay(todo: todo1, waitingTime: 3)
    let stateUpdater2 = AddTodoWithDelay(todo: todo2, waitingTime: 2)
    let stateUpdater3 = AddTodoWithDelay(todo: todo3, waitingTime: 0)
    
    await store.sideEffectContext.dispatch(stateUpdater1)
    await store.sideEffectContext.dispatch(stateUpdater2)
    await store.sideEffectContext.dispatch(stateUpdater3)
    
    XCTAssertEqual(store.state.todo.todos, [todo1, todo2, todo3])
  }
}
