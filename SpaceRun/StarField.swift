//
//  StarField.swift
//  SpaceRun
//
//  Created by Benjamin Miles on 12/6/17.
//  Copyright © 2017 Benjamin Miles. All rights reserved.
//

import SpriteKit

class StarField: SKNode {
    
    override init() {
        super.init()
        
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        initSetup()
    }
    
    func initSetup() {
        
        // Because we need to call a method on self (launchStar) inside a codebblock {}
        // we must create a weak reference top self. This is what we are doing with [weak self]
        // and then eventually assigning the "weak" self to a local constant called weakSelf.
        // Why
        
        // The run action holds a strong reference to the code block. and the node
        // (self)  holds a strong reference to the run action. If the code block
        // held a strong reference to the node. (self), then the run action, the code block
        // and the node (self) would all hold strong refreences to eachother.
        // forming a retain cycle which would never get deallocated. that is called
        // a memory leak.
        
        let update = SKAction.run {
            
            [weak self] in
            
            if arc4random_uniform(10) < 5 {
                
                if let weakSelf = self {
                    
                    weakSelf.launchStar()
                    
                }
                
            }
            
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.01), update])))
    
    }
    
    func launchStar() {
        
        // Make sure we have a reference to the scene
        //
        if let scene = self.scene {
            
            //Calculate a random starting point at top of screen
            let randomX: Double = Double(arc4random_uniform(uint(scene.size.width)))
            let maxY: Double = Double(scene.size.height)
            
            let randomStart: CGPoint = CGPoint(x: randomX, y: maxY)
            
            let star: SKSpriteNode = SKSpriteNode(imageNamed: "shootingstar")
            
            star.position = randomStart
            
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10.0)
            
            star.size = CGSize(width: 3.0 - star.alpha, height: 8 - star.alpha)
            
            // Stack the stars from dimest to brightest on the z axis
            
            star.zPosition = -100 + star.alpha * 10
            
            //Move the star toward the bottom of the screen using a random duration
            //removing the star when it passes the bottom edge.
            //The different speeds of the stars based on duration will give the
            // illusion of a parallax effect.
            
            let destY = 0.0 - scene.size.height - star.size.height
            
            let duration = Double(-star.alpha + 1.8)
            
            addChild(star)
            
            star.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: destY, duration: duration), SKAction.removeFromParent()]))
            
        }
        
    }

}
