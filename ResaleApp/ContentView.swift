//
//  ContentView.swift
//  ResaleApp
//
//  Created by Angelo Dela Fuente on 6/4/24.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        switch viewModel.dataScannerStatus {
        case.scannerAvailable:
            mainView
        case.cameraNotAvailable:
            Text("Device does not have a camera")
        case.scannerNotAvailable:
            Text("Device does not have barcode scaning implementation")
        case.cameraAccessNotGranted:
            Text("Please provide access to the camera in your settings")
        case.notDetermined:
            Text("Requesting camera access")
        }
        
        
    }
    
    private var mainView: some View {
            DataScannerView(
                recognizedItems: $viewModel.recognizedItem,
                recognizedDataType: viewModel.recognizedDataType,
                recognizesMultipleTypes: viewModel.recognizesMultipleItems)
            .id(viewModel.dataScannerViewId)
            .background { Color.gray.opacity(0.3) }
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                infoView
                    .background(.ultraThinMaterial)
                    .presentationDetents([.medium, .fraction(0.25)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .onAppear {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                            return
                        }
                        controller.view.backgroundColor = .clear
                    }

            }

        
        //@TODO Onchange of 53:53 in youtube video
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $viewModel.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)

                }.pickerStyle(.segmented)
            }.padding(.top)
            if viewModel.scanType == .text {
                //if the scan type is text

            }
            
            Text(viewModel.headerText).padding(.top)
        }.padding(.horizontal)
    }
    
    private var infoView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.recognizedItem) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
}



