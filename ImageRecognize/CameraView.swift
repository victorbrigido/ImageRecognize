//
//  CameraView.swift
//  ImageRecognize
//
//  Created by Victor Brigido on 08/08/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Não há necessidade de desempacotar, pois captureSession não é opcional
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.frame
        viewController.view.layer.addSublayer(previewLayer)
        
        viewModel.startCamera()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


//#Preview {
//    CameraView()
//}
