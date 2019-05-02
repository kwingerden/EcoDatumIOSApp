//
//  CarbonSinkScanCodeViewController.swift
//  EcoDatumIOSApp
//
//  Created by Kenneth Wingerden on 4/29/19.
//  Copyright © 2019 Kenneth Wingerden. All rights reserved.
//

import EcoDatumCoreData
import EcoDatumModel
import AVFoundation
import UIKit

class CarbonSinkScanCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var sites: [SiteEntity] = []
    
    private var captureSession: AVCaptureSession!
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var selectedSite: SiteEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(deviceInput),
            captureSession.canAddOutput(metadataOutput) else {
                let alertController = UIAlertController(
                    title: "Scanning Not Supported",
                    message: "Your device does not support scanning a QR code.",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                    self.captureSession = nil
                })
                alertController.addAction(okAction)
                present(alertController, animated: true)
                return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CarbonSinkDetailTabBarController {
            vc.site = selectedSite
        } else {
            log.error("Unknown segue \(segue)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        guard let metadataObject = metadataObjects.first,
            let readableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableCodeObject.stringValue else {
                let alertController = UIAlertController(
                    title: "Scanning Failure",
                    message: "Failed to scan QR code.",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(okAction)
                present(alertController, animated: true)
                return
        }
        
        selectedSite = sites.filter {
            $0.name == stringValue
        }.first
        
        if selectedSite == nil {
            let alertController = UIAlertController(
                title: "Scanning Failure",
                message: "Failed to find site \(stringValue).",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            performSegue(withIdentifier: "detailView", sender: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

