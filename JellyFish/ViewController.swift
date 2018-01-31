//
//  ViewController.swift
//  JellyFish
//
//  Created by Lyle Christianne Jover on 1/30/18.
//  Copyright © 2018 OnionApps Inc. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    let configuration = ARWorldTrackingConfiguration()
    var timer = Each(1).seconds
    var countdown = 10
    var points = 0
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
        self.timer.stop()
        self.restoreTimer()
        self.playBtn.isEnabled = true
        self.points = 0
        self.pointsLabel.text = String(self.points)
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    @IBAction func didPressPlay(_ sender: Any) {
        self.setTimer()
        addNode()
        self.playBtn.isEnabled = false
    }
    
    func addNode() {
        let jellyFishScene = SCNScene.init(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        jellyFishNode?.position = SCNVector3(randomNumber(firstNum: -1, secondNum: 1),randomNumber(firstNum: -0.5, secondNum: 0.5),randomNumber(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("Nothing was touched")
        } else {
            if countdown > 0 {
                let results = hitTest.first!
                let node = results.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                            node.removeFromParentNode()
                        }
                        self.addNode()
                        self.restoreTimer()
                        self.addPoint()
                    }
                    SCNTransaction.commit()
                }
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
    
    func randomNumber(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLabel.text = "YOU LOSE"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countdown = 10
        self.timerLabel.text = String(self.countdown)
    }
    
    func addPoint() {
        points += 1
        self.pointsLabel.text = String(points)
    }
    
}

