//
//  GameViewController.swift
//  Game_Janag
//
//  Created by Evan Perry on 2/23/24.
//

import UIKit
import QuartzCore
import SceneKit
import SwiftUI

struct GameView: View {
    var updateNumBlocksFall: (Int) -> Void
    var updateNumBlocksTapped: (Int) -> Void
    
    var body: some View {
        GameViewControllerWrapper(updateNumBlocksFall: updateNumBlocksFall, updateNumBlocksTapped: updateNumBlocksTapped)
    }
}
struct GameViewControllerWrapper: UIViewControllerRepresentable {
    var updateNumBlocksFall: (Int) -> Void
    var updateNumBlocksTapped: (Int) -> Void
    
    func makeUIViewController(context: Context) -> GameViewControllerSCENE {
        let viewController = GameViewControllerSCENE()
        viewController.updateNumBlocksFall = updateNumBlocksFall
        viewController.updateNumBlocksTapped = updateNumBlocksTapped
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GameViewControllerSCENE, context: Context) {
        // Update the view controller if needed
    }
}
class GameViewControllerSCENE: UIViewController {
    var scnView: SCNView!
    var updateNumBlocksFall: ((Int) -> Void)?
    var updateNumBlocksTapped: ((Int) -> Void)?// Closure to update NumBlocksFall
    private var numBlocksFall: Int = 0
    private var numBlocksTapped: Int = 0  // Local storage
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Janga.scn")!
        let physicsWorld = scene.physicsWorld
        physicsWorld.timeStep = 1.0 / 60.0 // This sets the time step to 60fps4
        physicsWorld.updateCollisionPairs()
        
        // Create and add a camera to the scene
        // Create a pivot node for the camera to orbit around
               let pivotNode = SCNNode()
                pivotNode.position = SCNVector3(x: 0, y: 3, z: 0) // Point to orbit around
                scene.rootNode.addChildNode(pivotNode)
                
                // Create and add a camera to the pivot node
                let cameraNode = SCNNode()
                let constraint = SCNDistanceConstraint(target: pivotNode)
                let lookat = SCNLookAtConstraint(target: pivotNode)
                constraint.maximumDistance = 12
                cameraNode.camera = SCNCamera()
                cameraNode.position = SCNVector3(x: 0, y: 3, z: 12)
                cameraNode.camera?.focalLength = 12
                //cameraNode.constraints = [constraint,lookat]
                pivotNode.addChildNode(cameraNode)
                
                // Rotate the pivot node to orbit the camera
                let orbit = SCNAction.rotateBy(x: 0, y: CGFloat(Double.pi * 2), z: 0, duration: 10)
                let repeatOrbit = SCNAction.repeatForever(orbit)
                pivotNode.runAction(repeatOrbit)
        
        
        // Create the Tower
        Make_Tower(scene: scene)
        
        // Retrieve the SCNView
        scnView = SCNView(frame: self.view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set the scene to the view
        scnView.scene = scene
        
        // Allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        scnView.cameraControlConfiguration.allowsTranslation = false
        
        
        
        // Show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // Configure the view
        scnView.backgroundColor = UIColor.black
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
        
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            self.updateBlockPositions(scene: scene)
        }
        //let temp = timer
        
        // Add the SCNView as a subview
        self.view.addSubview(scnView)
    }
    
    // Check the blocks
    @objc func updateBlockPositions(scene: SCNScene) {
        // Define the threshold Y-coordinate below which blocks should be removed
        let thresholdY: Float = -20.00 // Adjust as needed
        // Perform the necessary updates to check and remove blocks below the threshold
        for blockNode in scene.rootNode.childNodes {
            let worldPosition = blockNode.presentation.worldPosition
            if worldPosition.y < thresholdY {
                // Remove the block from the scene
                blockNode.removeFromParentNode()
                numBlocksFall += 1
                updateNumBlocksFall?(numBlocksFall)
                print(numBlocksFall)
                print(numBlocksTapped)
            }
        }
    }
    
    func Make_Tower(scene: SCNScene) {
        // Block settings
        let NumWidth = 3
        let NumHight = 15
        
        let NumOfBlocksHight = 1...NumHight
        let NumOfBlocksWidth = 1...NumWidth
        
        let BlockWidth = 3
        let BlockHeight = 0.6
        let BlockLength = 1
        
        let blockColor = UIColor.brown
        
        
        let BlockMaterial = SCNMaterial()
        BlockMaterial.lightingModel = .physicallyBased
        BlockMaterial.diffuse.contents = blockColor
        
        for HightNum in NumOfBlocksHight {
            print(1)
            for WidthNum in NumOfBlocksWidth {
                if HightNum % 2 == 0 {
                    let block = SCNBox(width: CGFloat(BlockLength), height: BlockHeight, length: CGFloat(BlockWidth), chamferRadius: 0.05)
                    let blockNode = SCNNode(geometry: block)
                    let PosY = Float(HightNum) * Float(BlockHeight) + 0.5
                    let PosZ = Float(WidthNum) * Float(BlockLength) + 0.01
                    blockNode.geometry?.materials = [BlockMaterial]
                    blockNode.name = "Block"
                    blockNode.position = SCNVector3(x: PosZ - 2, y: PosY, z: 0)
                    blockNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: block, options: nil))
                    scene.rootNode.addChildNode(blockNode)
                } else {
                    let block = SCNBox(width: CGFloat(BlockWidth), height: BlockHeight, length: CGFloat(BlockLength), chamferRadius: 0.05)
                    let blockNode = SCNNode(geometry: block)
                    let PosY = Float(HightNum) * Float(BlockHeight) + 0.5
                    let PosZ = Float(WidthNum) * Float(BlockLength) + 0.01
                    blockNode.geometry?.materials = [BlockMaterial]
                    blockNode.name = "Block"
                    blockNode.position = SCNVector3(x: 0, y: PosY, z: PosZ - 2)
                    blockNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: block, options: nil))
                    scene.rootNode.addChildNode(blockNode)
                }
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard let scnView = self.scnView else { return }
        
        // Check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        
        // Check that we clicked on at least one object
        if hitResults.count > 0 {
            // Retrieved the first clicked object
            let result = hitResults[0]
            
            // Ensure that the tapped node has the name "Block" and has a physics body
            if result.node.name == "Block", let physicsBody = result.node.physicsBody {
                // Get normal
                let worldNormal = result.worldNormal
                let scaleFactor: Float = 20.0
                let HitNormal = SCNVector3(worldNormal.x * scaleFactor,
                                           worldNormal.y * scaleFactor,
                                           worldNormal.z * scaleFactor)
                // Apply force to update sim
                physicsBody.applyForce(HitNormal, asImpulse: true);
                scnView.scene?.physicsWorld.updateCollisionPairs()
                
                // Remove physics body and node
                numBlocksTapped += 1
                print(numBlocksTapped)
                updateNumBlocksTapped?(numBlocksTapped)
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

