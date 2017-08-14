//
//  ViewController.swift
//  QRCodeReaerAssignment
//
//  Created by Apogee on 8/14/17.
//  Copyright © 2017 Apogee. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var square: UIImageView!
    
    let url = "http://192.168.0.36:8000/qrcode"

    var video = AVCaptureVideoPreviewLayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
        
        //Creating session
        let session = AVCaptureSession()
        
        //Define capture devcie
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do
        {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        }
        catch
        {
            print ("ERROR")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        self.view.bringSubview(toFront: square)
        
        session.startRunning()


    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects != nil && metadataObjects.count != 0
        {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            {
                if object.type == AVMetadataObjectTypeQRCode
                {
                    let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                    print("code value:=\(object.stringValue!)")
                    alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (nil) in
    
                        self.postDataToDatabase(para:object.stringValue!)
                        
                    }))
                    
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func postDataToDatabase(para:String)
    {
        
        print("para=\(para)")
        
        
        let parameter :[String:Any] = ["qrcode":para]
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default,headers: nil).validate().responseJSON{
            response in
            switch response.result{
            case .success:
                print(response)
                break
            case .failure(let error):
                print(error)
            }
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

