//
//  GameViewController.swift
//  TappyPlane
//
//  Created by Phyllis Hollingshead on 4/20/15.
//  Copyright (c) 2015 Phyllis Hollingshead. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    
//    class func unarchiveFromFile(_ file : String) -> SKNode? {
//        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
//            var sceneData = Data(contentsOf: path, count: .DataReadingMappedIfSafe, deallocator: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//            
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
    
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let url = Bundle.main.url(forResource: file, withExtension: "sks") {
            do {
                let sceneData = try Data(contentsOf: url)
                let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
                archiver.finishDecoding()
                return scene
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
