//
//  ViewController.swift
//  MeasurementApp
//
//  Created by Sonoma on 26/10/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var meterValue: Double?
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
       sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
                        let hitTestResults = sceneView.hitTest(touchLocation, types:.featurePoint)
                        if let hitResult = hitTestResults.first{
                            self.addDot(at: hitResult)
                        }
        }
    }
    func addDot(at hitResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        let points = hitResult.worldTransform.columns.3
        dotNode.position = SCNVector3(x: points.x, y: points.y, z: points.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            self.calculate()
        }
    }
    
    func calculate(){
        let start = dotNodes[0]
        let end  = dotNodes[1]
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        meterValue = Double(abs(distance))
        guard let meter = meterValue else {return}

        let heightMeter = Measurement(value: meter, unit: UnitLength.meters)
        let heightInches = heightMeter.converted(to: UnitLength.inches)
       // let heightCentimeters = heightMeter.converted(to: UnitLength.centimeters)
        let value = "\(heightInches)"
        let finalMeasurement = String(value.prefix(3   ))
        self.updateText(text: finalMeasurement, atposition: end.position)
    }
    
    func updateText(text:String, atposition position: SCNVector3){
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
