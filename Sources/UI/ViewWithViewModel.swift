//
//  ViewWithViewModel.swift
//  katana-async-await (iOS)
//
//  Created by Michele Mola on 21/12/21.
//

import SwiftUI

public struct ViewWithViewModel<VM: ViewModel, C: View>: View {
  let viewModel: VM
  let content: () -> C
  
  public init(
    viewModel: VM,
    @ViewBuilder content: @escaping () -> C
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
