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

        // Crie um AVCaptureVideoPreviewLayer com a session
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        // Defina a altura desejada e use a largura total da tela
        let desiredHeight: CGFloat = 700 // altura desejada
        let desiredWidth = viewController.view.bounds.width // largura total da tela
        
        // Aplique o frame com a largura total e altura fixa
        previewLayer.frame = CGRect(x: 0, y: 0, width: desiredWidth, height: desiredHeight)

        // Adicione a camada de visualização à view do viewController
        viewController.view.layer.addSublayer(previewLayer)

        // Iniciar a câmera
        viewModel.startCamera()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

