//
//  ViewWithViewModel.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import SwiftUI

public protocol ViewModel {
  func subscribe()
  
  func unsubscribe()
}

public struct ViewWithViewModel<VM: ViewModel, V: View>: View {
  let viewModel: VM
  let content: () -> V
  
  public init(
    viewModel: VM,
    @ViewBuilder content: @escaping () -> V
  ) {
    self.viewModel = viewModel
    self.content = content
  }
  
  public var body: some View {
    content()
      .onAppear {
        viewModel.subscribe()
      }
      .onDisappear {
        viewModel.unsubscribe()
      }
  }
}
