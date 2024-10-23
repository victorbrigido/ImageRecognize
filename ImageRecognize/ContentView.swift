//
//  ContentView.swift
//  ImageRecognize
//
//  Created by Victor Brigido on 08/08/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack() {
            CameraView(viewModel: viewModel)
            Text(viewModel.recognizedText)
                .foregroundColor(.white)
        }
    }
}

