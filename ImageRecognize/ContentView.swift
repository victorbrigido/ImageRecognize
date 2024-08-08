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
        ZStack(alignment: .top) {
            CameraView(viewModel: viewModel)
                .frame(width: 300, height: 400)
                .clipShape(Rectangle())
//            VStack(alignment: .leading) {
//                
//                Spacer()
//                ForEach(viewModel.detectedObjects, id: \.uuid) { observation in
//                    Text("Object: \(observation.labels.first?.identifier ?? "Unknown") - Confidence: \(observation.labels.first?.confidence ?? 0)")
//                        .padding()
//                }
//            }
            VStack{
                Spacer()
                Text(viewModel.recognizedText)
            }
        }
    }
}

