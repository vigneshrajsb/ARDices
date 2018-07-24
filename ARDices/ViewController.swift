//
//  ViewController.swift
//  ARDices
//
//  Created by Vigneshraj Sekar Babu on 7/21/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var diceArray =  [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - Sample Code
    
    func makeCubeOrMoon() {
        //   Create a new scene
        //                let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //                // Set the scene to the view
        //                sceneView.scene = scene
        //
        //               let isDice  = false
        //
        //                print("World tracking supported = \(ARWorldTrackingConfiguration.isSupported)")
        //                print("ARConfig supported = \(ARConfiguration.isSupported)")
        //
        //                if isDice {
        //                let dice = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.008)
        //                let material = SCNMaterial()
        //                material.diffuse.contents = UIColor.red
        //                dice.materials = [material]
        //                let diceNode = SCNNode(geometry: dice)
        //                diceNode.position = SCNVector3(0, 0.1, -0.2)
        //                sceneView.scene.rootNode.addChildNode(diceNode)
        //                sceneView.autoenablesDefaultLighting = true
        //                } else {
        //                    let sphere = SCNSphere(radius: 0.1)
        //                    let material = SCNMaterial()
        //                    material.diffuse.contents = UIImage(named: "art.scnassets/jupiter.jpg")
        //                    sphere.materials = [material]
        //                    let sphereNode = SCNNode(geometry: sphere)
        //                    sphereNode.position = SCNVector3(0, 0.1, -0.2)
        //                    sceneView.scene.rootNode.addChildNode(sphereNode)
        //                    sceneView.autoenablesDefaultLighting = true
        //                }
        //
        //                let dicescene = SCNScene(named: "art.scnassets/diceCollada.scn")
        //
        //                if let diceNode =  dicescene?.rootNode.childNode(withName: "Dice", recursively: true) {
        //                diceNode.position = SCNVector3(0, 0, -0.02)
        //                sceneView.scene.rootNode.addChildNode(diceNode)
        //                }
    }
    
    //MARK: - Renderer
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createNode(withPlaneAnchor: planeAnchor)
        diceArray.append(planeNode)
        node.addChildNode(planeNode)
    }
    
    func createNode(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [planeMaterial]
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.geometry = plane
        return planeNode
    }
    
    //MARK: - Methods to render dices
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //            if !results.isEmpty {
            //                print("touch detected in Scene View")
            //            } else {
            //                print("touched outside the Scene View")
            //            }
            
            if let hitResult = results.first {
                //print(hitResult)
                renderDice(atLocation: hitResult)
                
            }
        }
    }
    
    func renderDice(atLocation location : ARHitTestResult){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        
        if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y + diceNode.boundingSphere.radius / 2,
                location.worldTransform.columns.3.z
            )
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    
    @IBAction func rollButtonTapped(_ sender: UIBarButtonItem) {
        rollAllDices()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDices()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        for dice in diceArray {
            dice.removeFromParentNode()
        }
    }
    
    
    func rollAllDices() {
        for dice in diceArray {
            roll(dice: dice)
        }
    }
    
    func roll(dice : SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        
        let rotateX = Float(arc4random_uniform(8))
        let rotateY = Float(arc4random_uniform(8))
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * rotateX),
                y: 0,
                z: CGFloat(randomZ * rotateY),
                duration: 0.5)
        )
    }
    
    
}


