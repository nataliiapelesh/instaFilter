//
//  ContentView.swift
//  Instafilter
//
//  Created by Наталья Пелеш on 29.03.2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntessity = 0.5
    @State private var filterRadius = 20.0
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    var context = CIContext()
    
    @State private var showingFilterShit = false
    
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack{
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntessity)
                        .onChange(of: filterIntessity) { _ in applyProcessing() }
                }
                
                HStack{
                    Text("Radius")
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius) { _ in applyProcessing() }
                }
                .padding(.vertical)
                
                HStack{
                    Button("Change filter"){
                        showingFilterShit = true
                    }
                    Spacer()
                    Button("Save", action: save)
                        .disabled(hasAnImage() == false)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterShit) {
                Button("Cristallize"){ setFilter(CIFilter.crystallize()) }
                Button("Sepia tone"){ setFilter(CIFilter.sepiaTone()) }
//                Button("Pixellate"){ setFilter(CIFilter.pixellate()) }
                Button("Vignette"){ setFilter(CIFilter.vignette()) }
                Button("Unsharp mask"){ setFilter(CIFilter.unsharpMask()) }
                Button("Edges"){ setFilter(CIFilter.edges()) }
                Button("Gaussian blur"){ setFilter(CIFilter.gaussianBlur()) }
                Button("Cancel", role: .cancel){ }
            }
        }
//
    }
    
    func hasAnImage() -> Bool{
        guard let inputImage = inputImage else { return false }
        return true
    }
    
    func loadImage(){
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save(){
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Ooops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing(){
        let inputKey = currentFilter.inputKeys
        if inputKey.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntessity, forKey: kCIInputIntensityKey)}
        if inputKey.contains(kCIInputRadiusKey){
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)}
        if inputKey.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntessity * 10, forKey: kCIInputRadiusKey)}
     
        
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
