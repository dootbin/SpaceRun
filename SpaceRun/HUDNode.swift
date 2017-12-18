//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Benjamin Miles on 12/11/17.
//  Copyright © 2017 Benjamin Miles. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode {
    
    // Create a Heads-Up-Display (HUD) that will hold all of our display areas
    //
    // Once the node is added to the scene, we'll tell it to lay out its child
    // nodes.  The child nodes will not contain labels as we will use the blank
    // nodes as group containers and lay out the label nodes inside of them.
    //
    // We will left-align our Score and right-align the elapsed game time.
    //
    
    // Build two parent nodes (containers) as group containers that will hold
    // the score and value labels.
    
    // Properties
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "showPowerupTimer"
    
    private let HealthGroupName = "healthGroup"
    private let HealthValueName = "healthValue"
    private let HealthBarName = "healthbar"
    
    var health: Double = 2.0
    
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    lazy private var healthFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    override init() {
        super.init()
        
        createScoreGroup()
        
        createElapsedGroup()
        
        createPowerupGroup()
        
        createHealthGroup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //
    // Our labels are properly layed out within their parent group nodes,
    // but the group nodes are centered on the screen (scene).  We need
    // to create a layout method that will properly position the groups.
    //
    func layoutForScene() {
        
        // When a node exists in the Scene Graph, it can get access to the scene
        // via its scene property.  That property is nil if the node doesn't belong
        // to a scene yet, so this method is useless if the node is not yet added to the scene.
        if let scene = scene {
            
            let sceneSize = scene.size
            
            // the following will be used to calculate position of each group
            var groupSize = CGSize.zero
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 30.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No score group node was found in the Scene Graph node tree")
            }
            
            if let elapsedGroup = childNode(withName: ElapsedGroupName) {
                
                // Get size of elapsedGroup container (box)
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 30.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No elapsed group node was found in the Scene Graph node tree")
            }
            
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No powerup group node was found in the Scene Graph node tree")
            }
            
            if let healthGroup = childNode(withName: HealthGroupName) {
                
                groupSize = healthGroup.calculateAccumulatedFrame().size
                
                healthGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 30.0, y: sceneSize.height/2.0 - 100)
                
            } else {
                assert(false, "No h group node was found in the Scene Graph node tree")
            }
            
        }
        
    }
    
    func createScoreGroup() {
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Create an SKLabelNode for our title
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        scoreTitle.horizontalAlignmentMode = .center
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        scoreValue.horizontalAlignmentMode = .center
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(scoreGroup)
        
    }
    
    
    func createElapsedGroup() {
        
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // Create an SKLabelNode for our title
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        elapsedTitle.horizontalAlignmentMode = .center
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        elapsedValue.horizontalAlignmentMode = .center
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(elapsedGroup)
        
    }
    
    
    func createPowerupGroup() {
        
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        // Create an SKLabelNode for our title
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // set up actions to make our title pulse
        powerupTitle.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)])))
        
        powerupGroup.addChild(powerupTitle)
        
        
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        powerupValue.verticalAlignmentMode = .top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(powerupGroup)
        
        powerupGroup.alpha = 0.0   // make it invisible to start
        
    }
    
    
    /// Function to update ScoreValue label in HUD
    ///
    /// - parameter points: Integer
    func addPoints(_ points: Int) {
        
        score += points
        
        // Update HUD by looking up scoreValue label and updating it
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            // Format our score value using the thousands separator by using our
            // cached self.scoreFormatter property
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            // Scale the node up for brief period of time and then scale it back down
            scoreValue.run(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.02), SKAction.scale(to: 1.0, duration: 0.07)]))
            
        }
        
    }
    
    
    func showPowerupTimer(_ time: TimeInterval) {
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            if let powerupValue = powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                // Run the countdown sequence
                let start = Date.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsedTime = Date.timeIntervalSinceReferenceDate - start
                        
                        let timeLeft = max(time - elapsedTime, 0)
                        
                        let timeLeftFormat = weakSelf.timeFormatter.string(from: NSNumber(value: timeLeft))
                        
                        powerupValue.text = "\(timeLeftFormat ?? "0")s left"
                        
                    }
                }
                
                let countDownSequence = SKAction.sequence([block, SKAction.wait(forDuration: 0.05)])
                
                let countDown = SKAction.repeatForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run({ () -> Void in
                    
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                    
                })
                
                let visuals = SKAction.sequence([fadeIn, SKAction.wait(forDuration: time), fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
                
            }
            
        }
        
    }
    
    
    func startGame() {
        
        // Calculate the timestamp when starting the game.
        let startTime = Date.timeIntervalSinceReferenceDate
        
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            
            // Use a code block to update the elapsedTime property to be the
            // difference between the startTime and the current timeStamp
            let update = SKAction.run({
                [weak self] in
                
                if let weakSelf = self {
                    
                    let currentTime = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = currentTime - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.string(from: NSNumber(value: weakSelf.elapsedTime))
                    
                }
                
            })
            
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
            
        }
        
    }
    
    func endGame() {
        
        // Stop the timer sequence
        removeAction(forKey: TimerActionName)
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            powerupGroup.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
            
        }
        
    }
    
    func updateHealth(_ health: Double) {
    
        let healthPercent = health/self.health
        
        if let healthValue = childNode(withName: "\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            
            healthValue.text = healthFormatter.string(from: NSNumber(value: healthPercent))

        }
        
        if health > 3 {
            
            if let healthBar = childNode(withName: "\(HealthGroupName)/\(HealthBarName)") as! SKShapeNode? {
                
                healthBar.alpha = 0.4
                healthBar.strokeColor = SKColor.green
                healthBar.fillColor = SKColor.green
                healthBar.yScale = 1.0
                healthBar.position = CGPoint(x: 0.0, y: -83)

            }
            
        } else if health > 2 {
            
            if let healthBar = childNode(withName: "\(HealthGroupName)/\(HealthBarName)") as! SKShapeNode? {
                
                healthBar.alpha = 0.3
                healthBar.strokeColor = SKColor.green
                healthBar.fillColor = SKColor.green
                healthBar.yScale = 0.75
                healthBar.position = CGPoint(x: 0.0, y: (-83 * 0.75) + 5)
            }
            
        } else if health > 1 {
            
            if let healthBar = childNode(withName: "\(HealthGroupName)/\(HealthBarName)") as! SKShapeNode? {
                
                healthBar.alpha = 0.2
                healthBar.strokeColor = SKColor.red
                healthBar.fillColor = SKColor.red
                healthBar.yScale = 0.5
                healthBar.position = CGPoint(x: 0.0, y: (-83 * 0.5) + 10)
            }
            
        } else if health > 0 {
            
            if let healthBar = childNode(withName: "\(HealthGroupName)/\(HealthBarName)") as! SKShapeNode? {
                
                healthBar.alpha = 0.1
                healthBar.strokeColor = SKColor.red
                healthBar.fillColor = SKColor.red
                healthBar.yScale = 0.25
                healthBar.position = CGPoint(x: 0.0, y: (-83 * 0.25) + 10)
                
            }
            
        } else if health <= 0 {
            
            if let healthBar = childNode(withName: "\(HealthGroupName)/\(HealthBarName)") as! SKShapeNode? {
                
                healthBar.alpha = 0.0
                healthBar.strokeColor = SKColor.red
                healthBar.fillColor = SKColor.red
                healthBar.yScale = 0.0
                healthBar.position = CGPoint(x: 0.0, y: -83)
            }
            
        }
        

        
        
    }

    func createHealthGroup() {
        
        let healthGroup = SKNode()
        healthGroup.name = HealthGroupName
        
        // Create an SKLabelNode for our title
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        healthTitle.fontSize = 12.0
        healthTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        healthTitle.horizontalAlignmentMode = .center
        healthTitle.verticalAlignmentMode = .bottom
        healthTitle.text = "Health"
        healthTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        healthGroup.addChild(healthTitle)
        
        let healthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        healthValue.fontSize = 20.0
        healthValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        healthValue.horizontalAlignmentMode = .center
        healthValue.verticalAlignmentMode = .top
        healthValue.name = HealthValueName
        let healthPercent = health/self.health
        healthValue.text = healthFormatter.string(from: NSNumber(value: healthPercent))
        healthValue.position = CGPoint(x: 0.0, y: -4.0)
        
        let healthBar = SKShapeNode(rectOf: CGSize(width: 55, height: 200))
        healthBar.zRotation = CGFloat(Double.pi*2)
        healthBar.name = HealthBarName
        healthBar.fillColor = SKColor.red
        healthBar.strokeColor = SKColor.red
        healthBar.alpha = 0.20
        healthBar.yScale = 0.5
        healthBar.position = CGPoint(x: 0.0, y: (-83 * 0.5) + 10)
 
        
        healthGroup.addChild(healthValue)
        healthGroup.addChild(healthBar)
        // Add scoreGroup as a child of our HUD node
        addChild(healthGroup)

    }
    
    
    
}










































