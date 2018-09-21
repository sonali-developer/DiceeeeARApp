//
//  ViewController.swift
//  DiceeeeARApp
//
//  Created by Sonali Patel on 9/20/18.
//  Copyright © 2018 Sonali Patel. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To get the see the feature point detection task in terms of encountered plain in our view
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
    
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//       // material.diffuse.contents = UIColor.red
//
////        cube.materials = [material]
//
//         let sphere = SCNSphere(radius: 0.2)
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//
//
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0, z: -0.5)
////        node.geometry = cube
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        if ARWorldTrackingConfiguration.isSupported {
           let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            
            // Run the view's session
            sceneView.session.run(configuration)
        }
        
        
        print("AR Configuration is supported = \(ARConfiguration.isSupported)")
        print("AR World Tracking Configuration is supported = \(ARWorldTrackingConfiguration.isSupported)")

       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Converting this 2D touch location on iPhone or iPad  to 3D touch for SceneView
            let touchLocation = touch.location(in: sceneView)
        
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
                    
                    // Set the scene to the view
                    sceneView.scene.rootNode.addChildNode(diceNode)
                  roll(dice: diceNode)
                    
                }
                
            }
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("Plane Detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // Creating a plane node corresponding to the detected horizontal plane in real world.
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
            // Transforming the Vertical SCNPlane with (x,y) into a horizontal plane with (x,z) by rotating it 90 degrees
            
            planeNode.transform = SCNMatrix4MakeRotation(-(Float.pi / 2), 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
           // sceneView.scene.rootNode.addChildNode(planeNode)
           node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Rolling Dice Method
    
    func rollAll()  {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        // Rotation Angles along x and z axis
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        let rotationAction = SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5)
        
        dice.runAction(rotationAction)
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
}
