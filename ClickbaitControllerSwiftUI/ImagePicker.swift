//
//  ImagePicker.swift
//  ClickbaitControllerSwiftUI
//
//  Created by Simon on 01/10/2022.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    @EnvironmentObject var settings: SettingsStore
    
    @Binding var selectedImage: UIImage?
    var preOrPost: Bool
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator // confirming the delegate
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    // Connecting the Coordinator class with this struct
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
        imageUploadRequest(image: selectedImage, preorpost: self.picker.preOrPost, settings: self.picker.settings)
    }
    
}

