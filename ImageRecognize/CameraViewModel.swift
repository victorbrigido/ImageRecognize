//
//  CameraViewModel.swift
//  ImageRecognize
//
//  Created by Victor Brigido on 08/08/24.
//

import AVFoundation
import Vision
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var recognizedText: String = ""

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

