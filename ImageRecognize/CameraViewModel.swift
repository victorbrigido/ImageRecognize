//
//  CameraViewModel.swift
//  ImageRecognize
//
//  Created by Victor Brigido on 08/08/24.
//
//import AVFoundation
//import Vision
//import UIKit
//
//class CameraViewModel: NSObject, ObservableObject {
//    @Published var capturedImage: UIImage?
//    @Published var detectedObjects: [VNRecognizedObjectObservation] = []
//    @Published var detectedText: [VNRecognizedTextObservation] = [] 
//
//    var captureSession: AVCaptureSession = AVCaptureSession()
//    let videoOutput = AVCaptureVideoDataOutput()
//    var objectDetectionRequest: VNCoreMLRequest?
//    var textDetectionRequest: VNCoreMLRequest?
//
//    override init() {
//        super.init()
//        setupObjectDetectionModel()
//        setupTextDetectionModel()
//    }
//
//    private func setupObjectDetectionModel() {
//        // Carregar o modelo Core ML para detecção de objetos
//        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else {
//            print("Modelo de detecção de objetos não encontrado")
//            return
//        }
//        let model = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//        objectDetectionRequest = VNCoreMLRequest(model: model!, completionHandler: handleObjectDetection)
//        objectDetectionRequest?.imageCropAndScaleOption = .scaleFill
//    }
//
//    private func setupTextDetectionModel() {
//        // Carregar o modelo Core ML para detecção de texto
//        guard let model = try? VNCoreMLModel(for: BERTSQUADFP16().model) else {
//            print("Modelo de detecção de texto não encontrado")
//            return
//        }
//        textDetectionRequest = VNCoreMLRequest(model: model, completionHandler: handleTextDetection)
//        textDetectionRequest?.imageCropAndScaleOption = .scaleFill
//    }
//
//    func startCamera() {
//        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            print("Erro: Não foi possível acessar a câmera.")
//            return
//        }
//        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
//            print("Erro: Não foi possível criar entrada da câmera.")
//            return
//        }
//
//        if captureSession.canAddInput(videoInput) {
//            captureSession.addInput(videoInput)
//        } else {
//            print("Erro: Não foi possível adicionar entrada ao captureSession.")
//        }
//
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        
//        if captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//        } else {
//            print("Erro: Não foi possível adicionar saída ao captureSession.")
//        }
//
//        captureSession.startRunning()
//        print("A câmera foi iniciada.")
//    }
//
//    func stopCamera() {
//        captureSession.stopRunning()
//    }
//
//    func handleObjectDetection(request: VNRequest, error: Error?) {
//        if let observations = request.results as? [VNRecognizedObjectObservation] {
//            DispatchQueue.main.async {
//                self.detectedObjects = observations
//                // Atualizar a UI com as observações
//            }
//        }
//    }
//
//    func handleTextDetection(request: VNRequest, error: Error?) {
//        if let observations = request.results as? [VNRecognizedTextObservation] {
//            DispatchQueue.main.async {
//                self.detectedText = observations
//            }
//        }
//    }
//}
//
//extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//        if let request = objectDetectionRequest {
//            do {
//                try requestHandler.perform([request])
//            } catch {
//                print("Error performing object detection request: \(error)")
//            }
//        } else if let request = textDetectionRequest {
//            do {
//                try requestHandler.perform([request])
//            } catch {
//                print("Error performing text detection request: \(error)")
//            }
//        }
//    }
//}


import AVFoundation
import Vision
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var recognizedText: String = "" // Adiciona uma propriedade para armazenar o texto reconhecido

    var captureSession: AVCaptureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()

    func startCamera() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Erro: Não foi possível acessar a câmera.")
            return
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Erro: Não foi possível criar entrada da câmera.")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Erro: Não foi possível adicionar entrada ao captureSession.")
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Erro: Não foi possível adicionar saída ao captureSession.")
        }

        captureSession.startRunning()
        print("A câmera foi iniciada.")
    }

    func stopCamera() {
        captureSession.stopRunning()
    }
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                var recognizedString = ""
                for observation in observations {
                    recognizedString += "\(observation.topCandidates(1).first?.string ?? "")\n"
                }
                DispatchQueue.main.async {
                    self?.recognizedText = recognizedString
                }
            }
        }

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }
}

