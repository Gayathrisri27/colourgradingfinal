//
//  ViewController.swift
//  grade
//
//  Created by Gayathri on 06/11/24.
//

import UIKit
import AVFoundation
import AVKit
import CoreImage

class ViewController: UIViewController {
    
    
    @IBOutlet weak var videoPlayer: UIView!
    
    
    @IBOutlet weak var playpauseButton: UIButton!
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var redSlider: UISlider!
    
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenSlider: UISlider!
    
    @IBOutlet weak var greenLabel: UILabel!
    
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var alphaSlider: UISlider!
    
    
    @IBOutlet weak var alphaLabel: UILabel!
    
    @IBOutlet weak var applyChanges: UIButton!
    
    
    
    
    @IBOutlet weak var resetButton: UIButton!
    
        
    private var player: AVPlayer?
       private var playerLayer: AVPlayerLayer?
       private var imageGenerator: AVAssetImageGenerator?
       private var asset: AVAsset?
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupVideoPlayer()
           setupSliders()
           setupButtons()
       }
       
       // MARK: - Setup Methods
       private func setupVideoPlayer() {
           guard let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
               print("Invalid video URL")
               return
           }
           
           asset = AVAsset(url: videoURL)
           imageGenerator = AVAssetImageGenerator(asset: asset!)
           imageGenerator?.appliesPreferredTrackTransform = true
           imageGenerator?.maximumSize = CGSize(width: 1280, height: 720)
           
           let playerItem = AVPlayerItem(asset: asset!)
           player = AVPlayer(playerItem: playerItem)
           playerLayer = AVPlayerLayer(player: player)
           
           playerLayer?.frame = videoPlayer.bounds
           playerLayer?.videoGravity = .resizeAspect
           videoPlayer.layer.addSublayer(playerLayer!)
           
           let interval = CMTime(seconds: 1.0 / 10.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) // 10 frames per second
           player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
               self?.updateImageForTime(time)
           }
           
           player?.play()
       }
       
    private func setupSliders() {
        redSlider.value = 1.0
        greenSlider.value = 1.0
        blueSlider.value = 1.0
        alphaSlider.value = 0.5
        updateLabels()
        
        // Customizing slider colors for red, green, blue, yellow, and brown for alpha
        redSlider.minimumTrackTintColor = .red
        redSlider.maximumTrackTintColor = .lightGray
        redSlider.thumbTintColor = .red
        
        greenSlider.minimumTrackTintColor = .green
        greenSlider.maximumTrackTintColor = .lightGray
        greenSlider.thumbTintColor = .green
        
        blueSlider.minimumTrackTintColor = .blue
        blueSlider.maximumTrackTintColor = .lightGray
        blueSlider.thumbTintColor = .blue
        
        alphaSlider.minimumTrackTintColor = .brown  // Set the color of the alpha slider to brown
        alphaSlider.maximumTrackTintColor = .lightGray
        alphaSlider.thumbTintColor = .brown
    }

    private func setupButtons() {
        // Styling buttons
        let buttons: [UIButton] = [playpauseButton, applyChanges, resetButton]
        for button in buttons {
            button.layer.cornerRadius = 10
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 4
            button.clipsToBounds = true
        }
        
        // Play/Pause button setup
        playpauseButton.setTitle("Pause", for: .normal)
        playpauseButton.frame = CGRect(x: self.view.frame.width / 2 - 60, y: self.view.frame.height - 130, width: 120, height: 50)  // Positioned in the middle
        playpauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        
        // Apply Changes button setup
        applyChanges.setTitle("Apply Changes", for: .normal)
        applyChanges.frame = CGRect(x: self.view.frame.width - 140, y: self.view.frame.height - 130, width: 120, height: 50)
        applyChanges.addTarget(self, action: #selector(applyChangesTapped), for: .touchUpInside)
        
        // Reset button setup
        resetButton.setTitle("Reset", for: .normal)
        resetButton.frame = CGRect(x: 20, y: self.view.frame.height - 130, width: 120, height: 50)  // Positioned to the left
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // Add buttons to the view
        self.view.addSubview(playpauseButton)
        self.view.addSubview(applyChanges)
        self.view.addSubview(resetButton)
    }
       
       @objc private func togglePlayPause(_ sender: UIButton) {
           if player?.timeControlStatus == .playing {
               player?.pause()
               sender.setTitle("Play", for: .normal)
           } else {
               player?.play()
               sender.setTitle("Pause", for: .normal)
           }
       }
       
       @objc private func applyChangesTapped() {
           guard let asset = asset else {
               print("Asset not available")
               return
           }
           
           let playerItem = AVPlayerItem(asset: asset)
           playerItem.videoComposition = createVideoComposition(for: asset)
           
           player?.pause()
           player?.replaceCurrentItem(with: playerItem)
           player?.play()
       }
       
       @objc private func resetButtonTapped() {
           redSlider.value = 1.0
           greenSlider.value = 1.0
           blueSlider.value = 1.0
           alphaSlider.value = 0.5
           updateLabels()
           
           if let currentTime = player?.currentTime() {
               updateImageForTime(currentTime)
           }
       }
       
       private func createVideoComposition(for asset: AVAsset) -> AVMutableVideoComposition {
           let redValue = CGFloat(redSlider.value)
           let greenValue = CGFloat(greenSlider.value)
           let blueValue = CGFloat(blueSlider.value)
           let alphaValue = CGFloat(alphaSlider.value)
           
           let videoComposition = AVMutableVideoComposition(asset: asset) { request in
               let source = request.sourceImage.clampedToExtent()
               let colorFilter = CIFilter(name: "CIColorMatrix")!
               
               colorFilter.setValue(CIVector(x: redValue, y: 0, z: 0, w: 0), forKey: "inputRVector")
               colorFilter.setValue(CIVector(x: 0, y: greenValue, z: 0, w: 0), forKey: "inputGVector")
               colorFilter.setValue(CIVector(x: 0, y: 0, z: blueValue, w: 0), forKey: "inputBVector")
               colorFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: alphaValue), forKey: "inputAVector")
               
               colorFilter.setValue(source, forKey: kCIInputImageKey)
               
               if let outputImage = colorFilter.outputImage?.cropped(to: request.sourceImage.extent) {
                   request.finish(with: outputImage, context: nil)
               } else {
                   request.finish(with: NSError(domain: "VideoColorAdjustment", code: 0, userInfo: nil))
               }
           }
           
           videoComposition.renderSize = asset.tracks(withMediaType: .video).first?.naturalSize ?? CGSize(width: 1280, height: 720)
           videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
           
           return videoComposition
       }
       
       private func updateImageForTime(_ time: CMTime) {
           guard let imageGenerator = imageGenerator else { return }
           
           Task {
               do {
                   let cgImage = try await imageGenerator.copyCGImage(at: time, actualTime: nil)
                   let image = UIImage(cgImage: cgImage)
                   imageView.image = applyColorGrading(to: image)
               } catch {
                   print("Error generating image: \(error)")
               }
           }
       }
       
       private func applyColorGrading(to image: UIImage) -> UIImage? {
           let redValue = CGFloat(redSlider.value)
           let greenValue = CGFloat(greenSlider.value)
           let blueValue = CGFloat(blueSlider.value)
           let alphaValue = CGFloat(alphaSlider.value)
           
           UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
           defer { UIGraphicsEndImageContext() }
           
           guard let context = UIGraphicsGetCurrentContext(), let cgImage = image.cgImage else { return nil }
           
           context.translateBy(x: 0, y: image.size.height)
           context.scaleBy(x: 1.0, y: -1.0)
           context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
           
           context.setFillColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
           context.setBlendMode(.sourceAtop)
           context.fill(CGRect(origin: .zero, size: image.size))
           
           return UIGraphicsGetImageFromCurrentImageContext()
       }
       
       private func updateLabels() {
           redLabel.text = String(format: "Red: %.2f", redSlider.value)
           greenLabel.text = String(format: "Green: %.2f", greenSlider.value)
           blueLabel.text = String(format: "Blue: %.2f", blueSlider.value)
           alphaLabel.text = String(format: "Alpha: %.2f", alphaSlider.value)
       }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           playerLayer?.frame = videoPlayer.bounds
       }
   }
