//
//  File.swift
//  
//
//  Created by Michele Mola on 25/12/21.
//

import SwiftUI

public protocol ViewModelWithStore {
  associatedtype S: State
  associatedtype D: Dependencies
  
  init(store: Store<S, D>)
  
  func subscribe()
  
  func unsubscribe()
}

public struct ViewWithStore<VM: ViewModelWithStore & ObservableObject, V: View>: View {
  let store: Store<VM.S, VM.D>
  let content: (VM) -> V
  
  @StateObject private var viewModel: VM

  public init(
    _ store: Store<VM.S, VM.D>,
    viewModelType: VM.Type,
    @ViewBuilder content: @escaping (VM) -> V
  ) {
    self.store = store
    self.content = content
    
    self._viewModel = StateObject(wrappedValue: viewModelType.init(store: store))
  }
  
  public var body: some View {
    content(viewModel)
      .onAppear {
        viewModel.subscribe()
      }
      .onDisappear {
        viewModel.unsubscribe()
      }
  }
}
