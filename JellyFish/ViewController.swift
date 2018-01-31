//
//  ViewController.swift
//  JellyFish
//
//  Created by Lyle Christianne Jover on 1/30/18.
//  Copyright © 2018 OnionApps Inc. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playBtn: UIButton!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
       self.sceneView.session.run(configuration)
       self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
       let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
       self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressReset(_ sender: Any) {
    }
    
    @IBAction func didPressPlay(_ sender: Any) {
        addNode()
        self.playBtn.isEnabled = false
    }
    
    func addNode() {
        let jellyFishScene = SCNScene.init(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        jellyFishNode?.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)

    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("Nothing was touched")
        } else {
            let results = hitTest.first!
            let node = results.node
            if node.animationKeys.isEmpty {
                self.animateNode(node: node)
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,node.presentation.position.y - 0.2,node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
}

