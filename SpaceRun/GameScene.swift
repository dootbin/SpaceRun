//
//  GameScene.swift
//  SpaceRun
//
//  Created by Benjamin Miles on 11/22/17.
//  Copyright © 2017 Benjamin Miles. All rights reserved.
//

import SpriteKit
//import GameplayKit

class GameScene: SKScene {
    
    // Constants
    private let SpaceshipNodeName = "ship"
    private let PhotonTorpedoName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HUDNodeName = "hud"
    private let ShipHealthNodeName = "health"
    private let ReplayNodeName = "replay"
    private let ShieldNodeName = "shield"

    private let EndGameGroupName = "endGameGroup"

    
    // Properties to hold sound actions.  We will be preloading the sounds
    // into these properties so there is no delay when they are implemented
    // for the first time.
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    private let defaultFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    
    
    // We will be using the explosion particle emitters over and over.
    // We don't want to load them from the .sks files every time we need them,
    // so instead we'll create properties and load (cache) them for quick reuse
    // much like we did for our sound properties.
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obstacleExplode.sks")!
    
    
    // Variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private var shipFireRate: Double = 0.5
    private var shipHealthRate: Double = 2.0
    private var score: Int = 0
    private var gameover: Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Called automatically when a touch occurs (begins)
        if let touch = touches.first {
            
            self.shipTouch = touch
            
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            
            if let name = touchedNode.name
            {
                if name == ReplayNodeName
                {
                    self.restartGame()
                }
            }
        }
        
    }
    
    func createEndGameDisplay() {
       
        
        let endGameGroup = SKNode()
        endGameGroup.name = EndGameGroupName
        endGameGroup.zPosition = 10000
        let screenSize = UIScreen.main.bounds
        

        
        let endGameBackground = SKShapeNode(rectOf: CGSize(width: screenSize.width, height: screenSize.height))
        
        endGameBackground.fillColor = SKColor.red
        endGameBackground.strokeColor = SKColor.red
        endGameBackground.alpha = 0.0
        endGameBackground.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        
        endGameGroup.addChild(endGameBackground)
        addChild(endGameGroup)
        var fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 5.0)
        endGameBackground.run(fadeIn)
        
        let gameOverText = SKLabelNode(fontNamed: "Helvetica")
        gameOverText.text = "Game Over!\nEnd score:\(score)"
        gameOverText.position = CGPoint(x: screenSize.width/2 , y:screenSize.height/3)
        gameOverText.numberOfLines = 3
        gameOverText.alpha = 0
        gameOverText.fontSize = 17
        
        var fadeInText = SKAction.fadeAlpha(by: 1.0, duration: 1)

 
        endGameGroup.addChild(gameOverText)
        gameOverText.run(fadeInText)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let replay = SKShapeNode(rectOf: CGSize(width: screenSize.width/2, height: screenSize.height/8), cornerRadius: 10)
            replay.name = self.ReplayNodeName
            replay.fillColor = SKColor.black
            replay.strokeColor = SKColor.black
            replay.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
            replay.alpha = 0
            endGameGroup.addChild(replay)
            
            fadeIn = SKAction.fadeAlpha(to: 1, duration: 2)
            
            replay.run(fadeIn)
            
            let replayText = SKLabelNode(fontNamed: "Helvetica")
            replayText.text = "Replay?"
            replayText.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2 - 10)
            replayText.alpha = 0
            replayText.name = self.ReplayNodeName
            endGameGroup.addChild(replayText)
            fadeInText = SKAction.fadeAlpha(by: 1.0, duration: 2)
            
            replayText.run(fadeInText)
        }
        
    }
    
    func restartGame() {
        
        
        self.removeAllChildren()
        self.gameover = false
        self.shipHealthRate = 2.0
        self.score = 0
        setupGame(size)
        
    }
    
    func endGame() {
        

        
        createEndGameDisplay()
        enumerateChildNodes(withName: HUDNodeName) {
            hudNode,_ in
        
            hudNode.removeFromParent()
            
        }
        
        
    }
    
    func setupGame(_ size: CGSize) {
        
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        ship.zPosition = -1
        ship.size = CGSize(width: 40.0, height: 40.0)
        ship.name = SpaceshipNodeName
        addChild(ship)
        
        // Add ship thruster particle effect to our ship
        if let thrust = SKEmitterNode.nodeWithFile("thrust.sks") {
            
            thrust.position = CGPoint(x: 0.0, y: -20.0)
            
            thrust.zPosition = 0
            
            
            // Now, add the thrust as a child of our ship sprite
            // so its position is relative the ship's position.
            ship.addChild(thrust)
            
        }
        
        // Add ship shield to our ship
        
        let shield = SKShapeNode.init(circleOfRadius: ship.size.width/2 + 4)
            
            shield.position = CGPoint(x: 0.0, y: 0.0)
            shield.fillColor = SKColor.purple
            shield.strokeColor = SKColor.purple
            shield.alpha = 0
            shield.zPosition = 10000
            shield.name = ShieldNodeName
            ship.addChild(shield)
        
        
        // Set up our HUD
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        
        // By default, nodes will overlap (stack) according to the order in which
        // they were added to the scene.  If we wish to alter the stacking order
        // we can use a node's zPosition property to do so.
        hudNode.zPosition = 100.0
        
        // Set the position of the HUD node to be at the center of the screen (scene).
        // All of the child nodes we will add to the HUD node will be positioneda
        // relative to the HUD node's origin point.
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(hudNode)
        
        hudNode.layoutForScene()
        
        // Start the game already...
        hudNode.startGame()
        
        // Add the star field parallax effect to the scene by creating
        // an instance of our StarField class and adding it as a child of our scene
        addChild(StarField())
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame was rendered
        let timeDelta = currentTime - lastUpdateTime
        
        
        if let shipTouch = shipTouch {
            
            moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                lastShotFireTime = currentTime
            }
            
        }
        
        // Release asteroids 1.5% of the time a frame is drawn.  Note that this
        // number could be changed to increase game difficulty
        if arc4random_uniform(1000) <= 15 {
            dropThing()
        }
        
        // Collision detection
        checkCollisions()
    
        
        lastUpdateTime = currentTime
        
    }
    
    
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(230)
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Determine the distance between the ship's current position and
            // the touch point (passed-in) using the Pythagorean theorem.
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // if distance remaining is greater than 4 points, keep moving the ship
            // toward the touch point.  Otherwise, stop the ship.  If we don't stop
            // the ship, it may jitter around the touch point due to imprecision
            // in floating point numbers.
            if distanceLeftToTravel > 4 {
                
                // Calculate how far we should move the ship during this frame
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
                
                // Convert the distance remaining back into (x,y) coordinates
                // using atan2() to determine the proper angle based on the ship's
                // position and destination (touch point).
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Then, using the angle along with sin() and cos() functions,
                // determine the x and y offset values (distances to move along these
                // axes).
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                // Use the offset values to reposition the ship for this frame
                // moving it a little closer to the touch point
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }
            
        }
        
    }
    
    
    //
    // Shoot a photon torpedo
    //
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Create our photon torpedo sprite node
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoName)
            
            photon.name = PhotonTorpedoName
            photon.position = ship.position
            
            self.addChild(photon)
            
            // Set up actions for the photon sprite
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
            
        }
        
    }
    
    
    //
    // Drop something from top of scene
    //
    func dropThing() {
        
        // Simulate a die roll from 0 - 99
        let dieRoll = arc4random_uniform(100)
        
        if dieRoll < 3 {
            dropHealth()
        } else if dieRoll < 10 {
            dropPowerUp()
        } else if dieRoll < 30 {
            dropEnemyShip()
        } else {
            dropAsteroid()
        }
        
    }
    
    
    //
    // Drop an asteroid obstacle onto the scene
    //
    func dropAsteroid() {
        
        // Define asteroid size.  Random number between 15 and 44
        let sideSize = Double(15 + arc4random_uniform(30))
        // maximum x-position for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        // Determine random starting point for the asteroid
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX*2)))) - quarterX
        let startY = Double(self.size.height) + sideSize  // above top edge of scene
        
        // Determine ending position of asteroid
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize   // below bottom edge of scene
        
        // Create asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Get the asteroid moving
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + arc4random_uniform(5)))
        
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Rotate the asteroid by 3 radians (just less than 180 degrees) over a 1-3 duration
        let spin = SKAction.rotate(byAngle: 3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.run(all)
        
        
    }

    //
    // Drop a weapons powerup
    //
    func dropPowerUp() {
        
        // Create a power-up sprite spinning and moving from top to bottom of screen.
        let sideSize = 30.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        // Create powerup sprite and set its properties
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        let powerUpPath = createBezierPath()
        
        // Actions for the sprite
        powerUp.run(SKAction.sequence([SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
        
    }
    
    
    //
    // Drop an enemy ship
    //
    func dropEnemyShip() {
        
        // Define enemy ship size.
        let sideSize = 30.0
        
        // Determine random starting point
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 40)) + 20)
        let startY = Double(self.size.height) + sideSize  // above top edge of scene
        
        // Create enemy ship sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        // Get the enemy ship moving
        let shipPath = createBezierPath()
        
        // perform actions to fly our ship along the path
        //
        // asOffset: a true value lets us treat the action point values of the path as offsets
        // from the enemy ship's starting point.  A false value would the tread the path's
        // points as absolute positions on the screen
        //
        // orientToPath: true causes the enemy ship to turn and face the direction
        // of the path automatically
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        enemy.run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
        
    }
    
    
    func createBezierPath() -> CGPath {
        
        let yMax = -1.0 * self.size.height
        
        // Bezier path uses two control points along a line to create
        // a curved path.  We will use the UIBezierPath class to build this kind of object.
        //
        // Bezier path produced using the PaintCode app (www.paintcodeapp.com)
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
        
    }
    
    
    func checkCollisions() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // If the ship bumps into a powerup, remove the powerup from the scene
            // and reset the shipFireRate to 0.1 to increase the ship's firing rate.
            enumerateChildNodes(withName: PowerupNodeName) {
                powerUp, _ in
                
                if ship.intersects(powerUp) {
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showPowerupTimer(self.powerUpDuration)
                    }
                    
                    // powerup go away
                    
                    powerUp.removeFromParent()
                    
                    // Increase ship's firing rate
                    self.shipFireRate = 0.1
                    
                    // But, we need to power back down after a short delay
                    // so we are not unbeatable == boring.
                    let powerDown = SKAction.run {
                        
                        self.shipFireRate = self.defaultFireRate
                        
                    }
                    
                    // Now, let's set up a delay before the powerDown occurs
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    
                    //ship.run(SKAction.sequence([wait, powerDown]))
                    
                    // If we collect an additional powerup while one is already
                    // in progress, we need to stop the one in progress and start
                    // a new one so we always get the full duration for the new one.
                    //
                    // Sprite Kit lets us run actions with a key that we can then
                    // use to identify and remove the action before it has a chance
                    // to run or before it finishes if it is already running.
                    //
                    // If no key is found, nothing happens...
                    //
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    
                    ship.run(SKAction.sequence([wait, powerDown]), withKey: powerDownActionKey)
                    
                }
                
            }
            
            enumerateChildNodes(withName: ShipHealthNodeName) {
                shipHealth, _ in
                
                if ship.intersects(shipHealth) {
                    
                    var points: Int = 0
                    // Health PowerUP goes away
                    
                    shipHealth.removeFromParent()
                    
                    //Add some points to our scoreboard
                    
                    if self.shipHealthRate < 4 {

                        points = 1000
                        
                    } else {
                        
                        points = 500
                        
                    }
                
                    //Add Health
                    self.childNode(withName: "\(self.SpaceshipNodeName)/\(self.ShieldNodeName)")?.alpha = 0.50
                    
                    if self.shipHealthRate < 4 {
                    
                        self.shipHealthRate = 4

                    }
                    
                    //update points
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.updateHealth(self.shipHealthRate)
                    }
                    
                    self.addScore(score: points)

                }
                
            }
            
            // Loop through all instances of obstacles in the Scene Graph node tree
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle,_ in
                
                if ship.intersects(obstacle) {
                    
                    obstacle.removeFromParent()
                    let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                    self.run(self.obstacleExplodeSound)
                    explosion.position = obstacle.position
                    explosion.dieOutInDuration(0.1)
                    self.addChild(explosion)

                    self.shipHealthRate -= 1
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.updateHealth(self.shipHealthRate)
                    }
                    
                    if self.shipHealthRate > 2 {
                        
                        
                        self.childNode(withName: "\(self.SpaceshipNodeName)/\(self.ShieldNodeName)")?.alpha = 0.20
                        
                        
                    } else {
                        
                        self.childNode(withName: "\(self.SpaceshipNodeName)/\(self.ShieldNodeName)")?.alpha = 0
                        
                    }
                    
                    if self.shipHealthRate < 1 {
                        
                        
                        // Ship, obstacle, and touch go away

                        
                        // We need to call the copy() method on the shipExplodeTemplate node
                        // because nodes can only be added to a scene once.
                        //
                        // If we try to add a node again that already exists in a scene,
                        // the game will crash with an error.  We will use the emitter node
                        // template in our cached property as a template from which to make
                        // copies.
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = ship.position
                        explosion.dieOutInDuration(0.3)
                        self.addChild(explosion)
                        
                        ship.removeFromParent()
                        obstacle.removeFromParent()
                        
                        self.run(self.shipExplodeSound)
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            hud.endGame()
                        }
                        self.gameover = true
                        self.endGame()
                
                    }
                    
                }
                
                // Note: need to use self to reference our class because we are
                // inside a closure that affects scope.
                self.enumerateChildNodes(withName: self.PhotonTorpedoName) {
                    myPhoton, stop in
                    
                    if myPhoton.intersects(obstacle) {
                        
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        self.run(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        // Update our score

                        self.addScore(score: 100)
                        // This is like a break statement in other languages
                        stop.pointee = true
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    func addScore(score: Int) {
        self.score += score
        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
            hud.addPoints(score)
        }
        
    }
    
    func dropHealth() {
        
        // Create a power-up sprite spinning and moving from top to bottom of screen.
        let sideSize = 20.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        // Create powerup sprite and set its properties
        let shipHealth = SKSpriteNode(imageNamed: "healthPower")
        
        shipHealth.size = CGSize(width: sideSize, height: sideSize)
        shipHealth.position = CGPoint(x: startX, y: startY)
        
        shipHealth.name = ShipHealthNodeName
        
        self.addChild(shipHealth)
        
        let shipHealthPath = createBezierPath()
        
        // Actions for the sprite
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 5.0)
        let decreaseSize = SKAction.scale(to: 0.5, duration: 5.0)
        let path = SKAction.follow(shipHealthPath, asOffset: true, orientToPath: true, duration: 5.0)
        
        shipHealth.run(SKAction.sequence([SKAction.group([path, fadeOut, decreaseSize]), SKAction.removeFromParent()]))
        
    }
    
}














































