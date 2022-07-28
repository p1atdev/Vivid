//
//  ContentView.swift
//  Vivid
//
//  Created by p1atdev on 2022/07/28.
//

import SwiftUI
import AVKit
import Photos
import PhotosUI

struct ContentView: View {
    
    let videoURL = Bundle.main.url(forResource: "test_dusk",
                                   withExtension: "mov")!
    
    @State var isGenerated: Bool = false
    @State var progress: CGFloat = 0
    @State var isButtonDisabled: Bool = false
    
    @State var livePhoto: PHLivePhoto? = nil
    @State var resources: LivePhoto.LivePhotoResources? = nil
    
    @State var isSuccess: Bool = false
    
    var body: some View {
        VStack {
            if !isGenerated {
                
                Text("Source video")
                
                VideoPlayer(player: AVPlayer(url: videoURL))
                
                Slider(value: Binding(get: {
                    return progress
                }, set: {_,_ in}))
                
                
                Button {
                    isButtonDisabled = true
                    Task {
                        await generate(videoURL: videoURL)
                        isButtonDisabled = false
                    }
                } label: {
                    Text("Generate")
                }
                .disabled(isButtonDisabled)
                
            } else {
                if let livePhoto {
                    Text("LivePhoto has benn successfully generated")
                    
                    if isSuccess {
                        Text("LivePhoto has benn saved to library")
                    }
                    
                    _LivePhotoView(livePhoto: livePhoto)
                        .aspectRatio(
                            livePhoto.size.width / livePhoto.size.height,
                            contentMode: .fill
                        )
                        .padding()
                    
                    Button {
                        Task {
                            await save()
                        }
                    } label: {
                        Text("Save")
                    }
                    
                } else {
                    Text("LivePhoto is nil")
                }
            }
        }
        .padding()
    }
    
    func generate(videoURL: URL) async {
        LivePhoto.generate(from: nil,
                                 videoURL: videoURL,
                                 progress: { value in
            progress = value
        }) { (_livePhoto, _resources) in
            self.livePhoto = _livePhoto
            self.resources = _resources
            
            self.isGenerated = true
        }
    }
    
    func save() async {
        if let resources {
            let success = await LivePhoto.saveToLibrary(resources)
            self.isSuccess = success
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


fileprivate struct _LivePhotoView: UIViewRepresentable {
    
    let livePhoto: PHLivePhoto
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let livePhotoView = PHLivePhotoView(frame: .zero)
        livePhotoView.livePhoto = livePhoto
        return livePhotoView
    }
    
    func updateUIView(_ livePhotoView: PHLivePhotoView, context: Context) {
    }
}
