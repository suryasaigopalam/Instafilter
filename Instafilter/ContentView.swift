//
//  ContentView.swift
//  Instafilter
//
//  Created by surya sai on 16/05/24.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import PhotosUI

struct ContentView: View {
    @State var processedImage:Image?
    @State var filterIntensity = 0.5
    @State var selectedItem:PhotosPickerItem?
    @State var currentFilter:CIFilter = CIFilter.sepiaTone()
    @State var showingFilters = false
    let context = CIContext()
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage = processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    }else {
                        ContentUnavailableView("No Picture", systemImage:"photo.badge.plus", description: Text("Tap import the image"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                if let _ = processedImage  {
                    HStack {
                        Text("Intensity")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                        
                    }
                    
                    
                    HStack {
                        Button("Change Filter",action: changeFilter)
                        Spacer()
                        
                        if let processedImage {
                            ShareLink(item:processedImage,preview: SharePreview("InstaFilter",image: processedImage))
                        }
                    }
                }
                
            }
            .padding()
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented:$showingFilters) {
                Button("Crystallize") {setFilter(CIFilter.crystallize())}
                Button("Edges") {setFilter(CIFilter.edges())}
                Button("Gaussian Blur") {setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate") {setFilter(CIFilter.pixellate())}
                Button("Sepia Tone") {setFilter(CIFilter.sepiaTone())}
                Button("Unsharp Mask") {setFilter(CIFilter.unsharpMask())}
                Button("Vignette") {setFilter(CIFilter.vignette())}
                Button("Xray"){setFilter(CIFilter.xRay())}
                Button("Line Screen"){setFilter(CIFilter.lineScreen())}
                Button("Box Blur"){setFilter(CIFilter.boxBlur())}
                Button("Cancel",role: .cancel) {}
            }
        }
    }
    func changeFilter() {
        showingFilters = true
    }
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {return}
            guard let inputImage = UIImage(data: imageData) else {return}
            
            let ciImage = CIImage(image: inputImage)
            
            currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
            applyProcessing()
            
            
        }
    }
    func applyProcessing() {
        let inputkeys = currentFilter.inputKeys
        if inputkeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputkeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200 , forKey: kCIInputRadiusKey)
        }
        if inputkeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        if inputkeys.contains(kCIInputSharpnessKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputSharpnessKey)
        }
        if inputkeys.contains(kCIInputWidthKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputWidthKey)
        }
        if inputkeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputCenterKey)
        }
        
        
        
        guard let outputImage = currentFilter.outputImage else {return}
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {return}
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    func setFilter(_ filter:CIFilter) {
        currentFilter = filter
        loadImage()
        filterIntensity = 0.5
    }
}

#Preview {
    ContentView()
}
