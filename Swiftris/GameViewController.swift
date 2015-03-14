//
//  GameViewController.swift
//  Swiftris
//
//  Created by Gru on 03/09/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//
// 'Let Them Fall'
// 'Playing by the Rules'
//
// 'GameViewController', is responsible for handling user input and communicating
// between 'GameScene' and a game logic class you'll write soon.
//
// NOTES:
// (1)      var scene: GameScene!
// Lets us know that it is a variable, its name is scene, its type is GameScene
// and it is a non-optional value which will eventually be instantiated. Swift
// typically enforces instantiation either in-line where you declare the variable
// or during the initializer, init…. In order to circumvent this requirement
// we've added an ! after the type.

import UIKit
import SpriteKit

//extension SKNode {
//    class func unarchiveFromFile(file : NSString) -> SKNode? {
//        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
//            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//            
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
//    }
//}

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate  {

    var scene: GameScene!       // (1)
    var swiftris: Swiftris!

    // #1A Keep track of the last point on the screen at which a shape movement occurred or where a pan begins.
    var panPointReference: CGPoint?

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        println("Tap")
        swiftris.rotateShape()
    }

    @IBAction func dropButton(sender: UIButton, forEvent event: UIEvent) {
        println("Drop")
        swiftris.dropShape()
    }

    @IBOutlet weak var levelLabel: UILabel!

    @IBOutlet weak var scoreLabel: UILabel!

    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        println("Pan")
        // #2A
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3A
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4A
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }

    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        println("Swipe")
        swiftris.dropShape()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = view as SKView
            skView.multipleTouchEnabled = false

        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill

        scene.tick        = didTick
        swiftris          = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()

        // Present the scene.
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // 1B
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }

    // #2B
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }

    func gameShapeDidDrop(swiftris: Swiftris) {
        // #3B
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("Sounds/drop.mp3")
    }

    func didTick() {
        swiftris.letShapeFall()
//      swiftris.fallingShape?.lowerShapeByOneRow()
//      scene.redrawShape(swiftris.fallingShape!, completion: {} )
    }

    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                // #2
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }

    func gameDidBegin(swiftris: Swiftris) {

        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"

        scene.tickLengthMillis = TickLengthLevelOne
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }

    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
    }

    func gameDidLevelUp(swiftris: Swiftris ) {

        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
    }

    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        //nextShape()
        self.view.userInteractionEnabled = false
        // #1
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #2
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }

    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }


}
