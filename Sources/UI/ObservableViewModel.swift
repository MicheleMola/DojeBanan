//
//  ObservableViewModel.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import Combine
import Foundation

open class ObservableViewModelWithStore<S: State, D: Dependencies>: ViewModelWithStore {
  public let store: Store<S, D>
  
  private var cancellable = Set<AnyCancellable>()
  
  required public init(store: Store<S, D>) {
    self.store = store
  }
  
  open func update(state: S) {}
  
  public func subscribe() {
    self.store.$state
      .receive(on: DispatchQueue.main)
      .print("\(Self.self)")
      .sink { [weak self] updatedState in
        self?.update(state: updatedState)
      }
      .store(in: &cancellable)
  }
  
  public func unsubscribe() {
    cancellable.removeAll()
  }
}

open class ObservableViewModelWithLocalState<S: State, D: Dependencies, LS: LocalState>: ViewModelWithStoreAndLocalState {
  public let store: Store<S, D>
  private let localState: LS
  
  private var cancellable = Set<AnyCancellable>()
  
  required public init(store: Store<S, D>, localState: LS) {
    self.store = store
    self.localState = localState
  }
  
  open func update(state: S) {}
  
  public func subscribe() {
    self.store.$state
      .receive(on: DispatchQueue.main)
      .print("\(Self.self)")
      .sink { [weak self] updatedState in
        self?.update(state: updatedState)
      }
      .store(in: &cancellable)
  }
  
  public func unsubscribe() {
    cancellable.removeAll()
  }
}

open class ObservableViewModel<S: State, D: Dependencies>: ViewModel {
  public let store: Store<S, D>
  
  private var cancellable = Set<AnyCancellable>()
  
  required public init(store: Store<S, D>) {
    self.store = store
  }
  
  open func update(state: S) {}
  
  public func subscribe() {
    self.store.$state
      .receive(on: DispatchQueue.main)
      .print("\(Self.self)")
      .sink { [weak self] updatedState in
        self?.update(state: updatedState)
      }
      .store(in: &cancellable)
  }
  
  public func unsubscribe() {
    cancellable.removeAll()
  }
}
