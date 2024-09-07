//
//  AppViewModel.swift
//  ResaleApp
//
//  Created by Angelo Dela Fuente on 6/6/24.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit

enum AccessLevel {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

enum ScanType {
    case barcode, text
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerStatus: AccessLevel = .notDetermined
    @Published var recognizedItem: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?

    @Published var recognizesMultipleItems = false

    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    var headerText: String {
        if recognizedItem.isEmpty {
            return "Scanning..."

//            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItem.count) item(s)"
        }
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }

    func RequestScannerAccess() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerStatus = .cameraAccessNotGranted
            }
            
        default: break
            
        }
    }
}
