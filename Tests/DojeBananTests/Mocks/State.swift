//
//  File.swift
//  
//
//  Created by Michele Mola on 22/01/22.
//

import Foundation

@testable import DojeBanan

struct Todo: Equatable {
  let title: String
  let id: String
}

struct User: Equatable {
  let username: String
}

struct TodoState: State, Equatable {
  var todos: [Todo]
}

extension TodoState {
  init() {
    self.todos = []
  }
}

struct UserState: State, Equatable {
  var users: [User]
}

extension UserState {
  init() {
    self.users = []
  }
}

struct AppState: State, Equatable {
  var todo: TodoState
  var user: UserState
}

extension AppState {
  init() {
    self.todo = TodoState()
    self.user = UserState()
  }
}
