//
//  ObservableViewModel.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import Combine
import Foundation

open class ObservableViewModel<S: State, D: Dependencies>: ViewModel {
  public let store: Store<S, D>
  
  private var cancellable = Set<AnyCancellable>()
  
  public init(store: Store<S, D>) {
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
