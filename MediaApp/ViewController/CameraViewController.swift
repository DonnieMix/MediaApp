//
//  ViewController.swift
//  MediaApp
//
//  Created by Kyrylo Derkach on 08.10.2023.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var recordTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var openMediaButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    private let iconSize: CGFloat = 25
    private var isRecording = false
    private var isCameraFront = false
    
    private var captureSession: AVCaptureSession?
    private var preview = AVCaptureVideoPreviewLayer()
    private var currentVideoInput: AVCaptureDeviceInput?
    private var currentAudioInput: AVCaptureDeviceInput?
    
    private var videoOutput = AVCaptureMovieFileOutput()
    private var videoRecordCompletionBlock: ((URL?, Error?) -> Void)?
    
    private var photoOutput = AVCapturePhotoOutput()
    private var settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureIcons()
        
        configureCamera()
        
        if let captureSession {
            DispatchQueue.global(qos: .userInteractive).async {
                captureSession.startRunning()
            }
        }
    }
    
    private func configureIcons() {
        let config = UIImage.SymbolConfiguration(pointSize: iconSize)
        flipCameraButton.configuration?.image = UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill", withConfiguration: config)
        recordButton.configuration?.image = UIImage(systemName: "circle.inset.filled", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize + 15))
        openMediaButton.configuration?.image = UIImage(systemName: "photo.stack.fill", withConfiguration: config)
    }
    
    private func configureCamera() {
        let videoDevice = AVCaptureDevice.default(for: .video)
        let audioDevice = AVCaptureDevice.default(for: .audio)
        captureSession = AVCaptureSession()
        
        guard let captureSession, let videoDevice, let audioDevice else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            photoOutput = AVCapturePhotoOutput()
            videoOutput = AVCaptureMovieFileOutput()
            captureSession.beginConfiguration()
            if captureSession.canAddInput(videoInput) &&
                captureSession.canAddOutput(photoOutput) &&
                captureSession.canAddOutput(videoOutput){
                captureSession.addInput(videoInput)
                captureSession.addOutput(photoOutput)
                captureSession.addOutput(videoOutput)
                currentVideoInput = videoInput
            }
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
                currentAudioInput = audioInput
            }
            captureSession.commitConfiguration()
        }
        catch {
            print("Error: \(error.localizedDescription)")
        }
        
        preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = cameraView.bounds
        cameraView.layer.addSublayer(preview)
        configurePhoto()
    }
    
    private func configurePhoto() {
        settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        settings.photoQualityPrioritization = .quality
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        photoOutput.maxPhotoQualityPrioritization = settings.photoQualityPrioritization
    }
    
    private func configureVideo() {
        if let captureSession {
            captureSession.beginConfiguration()
            captureSession.removeOutput(videoOutput)
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.commitConfiguration()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preview.frame = cameraView.bounds
    }

    @IBAction func onRecordTypeChanged(_ sender: Any) {
        guard let recordTypeControl = sender as? UISegmentedControl else { return }
        if recordTypeControl.selectedSegmentIndex == 0 {
            recordButton.configuration?.image = UIImage(systemName: "circle.inset.filled", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize + 15))
        } else {
            recordButton.configuration?.image = UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize + 15))
        }
    }
    
    @IBAction func onFlipCameraPressed(_ sender: Any) {
        if isCameraFront {
            DispatchQueue.global(qos: .userInteractive).async {
                self.switchCamera(camera: AVCaptureDevice.default(for: .video))
                self.captureSession?.startRunning()
            }
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                self.switchCamera(camera: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front))
                self.captureSession?.startRunning()
            }
        }
    }
    
    private func switchCamera(camera: AVCaptureDevice?) {
        guard let camera, let captureSession else { return }
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            captureSession.beginConfiguration()
            if let currentVideoInput = currentVideoInput {
                captureSession.removeInput(currentVideoInput)
            }
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                currentVideoInput = videoInput
            }
            captureSession.commitConfiguration()
            isCameraFront = !isCameraFront
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onRecordPressed(_ sender: Any) {
        if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
            if isRecording {
                stopRecording()
                recordButton.configuration?.image = UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize + 15))
                isRecording = false
                recordTypeSegmentedControl.isEnabled = true
                flipCameraButton.isEnabled = true
                openMediaButton.isEnabled = true
                MediaManager.shared.updateManagerData()
            } else {
                startRecording { result, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Oops...", message: "There was an error recording video", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alertController, animated: true)
                            return
                        }
                    }
                    
                }
                self.recordButton.configuration?.image = UIImage(systemName: "stop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: self.iconSize + 15))
                self.isRecording = true
                self.recordTypeSegmentedControl.isEnabled = false
                self.flipCameraButton.isEnabled = false
                self.openMediaButton.isEnabled = false
            }
        } else {
            let whiteView = UIView(frame: view.bounds)
            whiteView.backgroundColor = .white
            whiteView.alpha = 0
            cameraView.addSubview(whiteView)
            UIView.animate(withDuration: 0.2, animations: {
                whiteView.alpha = 0.7
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    whiteView.alpha = 0.0
                })
            })
            takePhoto()
            MediaManager.shared.updateManagerData()
        }
    }
    
    func startRecording(completion: @escaping (URL?, Error?) -> Void) {
        guard let captureSession, captureSession.isRunning else { return }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)
        let fileName = "\(formattedDate).mp4"
        
        let fileUrl = paths[0].appendingPathComponent(fileName)
        
        videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
        videoRecordCompletionBlock = completion
    }
    
    func stopRecording() {
        guard let captureSession, captureSession.isRunning else {
            print("Video not being recorded")
            return
        }
        videoOutput.stopRecording()
        configureVideo()
    }
    
    func takePhoto() {
        self.photoOutput.capturePhoto(with: self.settings, delegate: self)
        self.configurePhoto()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Open Media" {
            if let mediaViewController = segue.destination as? MediaViewController {
                let mediaManager = MediaManager.shared
                mediaViewController.collectionView.dataSource = mediaManager
            }
        }
    }
    
}
