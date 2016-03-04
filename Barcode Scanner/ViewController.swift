//
//  ViewController.swift
//  Barcode Scanner
//
//  Created by Shane Qi on 3/2/16.
//  Copyright © 2016 Auctionsoftware. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	var codeFrame: UIView!
	var navBar:UIView!
	var logo:UIImageView!
	var captureSession:AVCaptureSession?
	var videoPreviewLayer:AVCaptureVideoPreviewLayer?
	var flashButton: UIButton!
	var captureDevice:AVCaptureDevice!
	
	override func viewDidLoad() {
		
		navBar = UIView()
		navBar.backgroundColor = UIColor(red: 100/255, green: 200/255, blue: 1, alpha: 0.8)
		navBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
		self.view.addSubview(navBar)
		
		logo = UIImageView()
		logo.image = UIImage(named: "logo")
		logo.frame = CGRect(x: 0, y: 35, width: self.view.frame.width, height: 30)
		logo.contentMode = UIViewContentMode.ScaleAspectFit
		self.view.addSubview(logo)
		
		codeFrame = UIView()
		codeFrame.layer.borderColor = UIColor(red: 100/255, green: 200/255, blue: 1, alpha: 1).CGColor
		codeFrame.layer.borderWidth = 2
		codeFrame.frame.size = CGSize(width: self.view.frame.width - 100, height: self.view.frame.width - 100)
		codeFrame.center = self.view.center
		self.view.addSubview(codeFrame)
		
		flashButton = UIButton()
		flashButton.frame.size = CGSize(width: 50, height: 50)
		flashButton.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height - 100)
		flashButton.setImage(UIImage(named: "flash"), forState: .Normal)
		flashButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		self.view.addSubview(flashButton)
		flashButton.addTarget(self, action: "toggleFlash", forControlEvents: UIControlEvents.TouchUpInside)
		
		var input:AnyObject! = nil
		captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

		
		do {
			input = try AVCaptureDeviceInput(device: captureDevice)
		} catch {
			print("\(error)")
		}
		captureSession = AVCaptureSession()
		captureSession?.addInput(input as! AVCaptureInput)
		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession?.addOutput(captureMetadataOutput)
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
		captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeDataMatrixCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeFace, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeUPCECode]
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
		videoPreviewLayer?.frame = view.layer.bounds
		view.layer.addSublayer(videoPreviewLayer!)
		
		captureSession?.startRunning()
		
		self.view.bringSubviewToFront(codeFrame)
		self.view.bringSubviewToFront(navBar)
		self.view.bringSubviewToFront(logo)
		self.view.bringSubviewToFront(flashButton)
	}
	
	func toggleFlash() {
		
		do {
			try captureDevice.lockForConfiguration()
			if captureDevice.torchMode == AVCaptureTorchMode.On && captureDevice.flashMode == AVCaptureFlashMode.On {
				captureDevice.torchMode = AVCaptureTorchMode.Off
				captureDevice.flashMode = AVCaptureFlashMode.Off
			}else {
				captureDevice.torchMode = AVCaptureTorchMode.On
				captureDevice.flashMode = AVCaptureFlashMode.On
			}

			captureDevice.unlockForConfiguration()
		} catch {
			print(error)
		}
	}
	
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
		if metadataObjects == nil || metadataObjects.count == 0 {
			codeFrame.frame.size = CGSize(width: 0, height: 0)
			return
		}
		
		let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
		let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
		codeFrame.frame = barCodeObject.bounds
		if metadataObj.stringValue != nil {
			if metadataObj.stringValue == "123456" {
				UIApplication.sharedApplication().openURL(NSURL(string: "http://fishbase.org/summary/SpeciesSummary.php?ID=6017&AT=blue+tang")!)
			}
			if metadataObj.stringValue == "654321" {
				UIApplication.sharedApplication().openURL(NSURL(string: "http://fishbase.org/summary/SpeciesSummary.php?ID=7451&AT=dragon+eel")!)
			}
		}
	}
	
}

