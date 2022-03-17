//
//  GameController.swift
//  DinoEscape iOS
//
//  Created by Beatriz Duque on 07/03/22.
//

import Foundation
import SpriteKit
import GameController

class GameController{
    static var shared: GameController = {
        let instance = GameController()
        return instance
    }()
    
    var gameData: GameData
    var renderer: RenderController
    let joystickController: JoystickController = JoystickController()
    
    private init(){
        let player = Player(name: "DinoRex",
                            color: .yellow,
                            position: CGPoint(x: 0, y: 0),
                            size: CGSize(width: 50, height: 50),
                            skin: .dino1,
                            gameCommand: .UP,
                            powerUp: .none)
        gameData = GameData(player: player)
        renderer = RenderController()
    }
    
    func setScene(scene: MyScene){
        renderer.scene = scene
        
    }

    func setupScene(){
        
        //player
        let player = GameController.shared.gameData.player!
        player.position = CGPoint(x: renderer.scene.size.width/2, y: renderer.scene.size.height/2)
        
        #if os( iOS )
        joystickController.virtualController.position = CGPoint(x: renderer.scene.size.width/2, y: renderer.scene.size.height/7)
        #endif
        
        renderer.setUpScene()
        
        //controle da cena
        joystickController.delegate = self
        joystickController.observeForGameControllers()
        
        //fisica da cena
        renderer.scene.physicsBody = SKPhysicsBody(edgeLoopFrom: GameController.shared.renderer.scene.frame)
        renderer.scene.physicsWorld.contactDelegate = GameController.shared.renderer.scene.self
        recursiveActionItems()

    }
    
    func update(_ currentTime: TimeInterval){
        joystickController.update(currentTime)
        movePlayer(dx: gameData.player?.dinoVx ?? 0, dy: gameData.player?.dinoVy ?? 0)
        renderer.update(currentTime)
    }
    
    //MARK: Movimentacao
    func movePlayer(dx: CGFloat, dy: CGFloat){
        
        if let player = gameData.player {
            
            // Iguala size do player para size da hitBox
            player.size = CGSize(width: renderer.scene.size.height*0.05, height: renderer.scene.size.height*0.035)
            let mult = player.foodBar
            let midWidthPlayer = player.size.width/2
            let midHeightPlayer = player.size.height/2
            
            var xValue = player.position.x + dx * mult
            if xValue > renderer.scene.size.width * 0.94 - midWidthPlayer{
                xValue = renderer.scene.size.width * 0.94 - midWidthPlayer
            } else if xValue < renderer.scene.size.width * 0.06 + midWidthPlayer{
                xValue = renderer.scene.size.width * 0.06 + midWidthPlayer
            }
           
            
            var yValue = player.position.y + dy * mult
            if yValue > renderer.scene.size.height * 0.84 - midHeightPlayer{
                yValue = renderer.scene.size.height * 0.84 - midHeightPlayer
            } else if yValue < renderer.scene.size.height * 0.125 + midHeightPlayer{
                yValue = renderer.scene.size.height * 0.125 + midHeightPlayer
            }
            
            player.position = CGPoint(x: xValue, y: yValue)
        }
    }
    
    // MARK: Itens na tela
    func createItems(){
        
        let badOrGood = Int.random(in: 0...1)
        let spoiledOrMeteor = Int.random(in: 0...1)

        let directions: [GameCommand] = [.LEFT, .RIGHT, .UP, .DOWN]
        let goodImages: [String] = ["cherry","banana","apple"]
        let badImages: [String] = ["spoiledCherry", "spoiledBanana", "spoiledApple"]
        let direction = directions[Int.random(in: 0..<directions.count)]
        let item = Items(image: "", vy: 0, vx: 0, direction: direction)
        
        
        var xInitial: CGFloat = 0
        var yInitial: CGFloat = 0
        
        if badOrGood == 1 {
            item.texture = SKTexture(imageNamed: goodImages[Int.random(in: 0..<goodImages.count)])
            item.name = "good"
        } else {
            if spoiledOrMeteor == 1 {
                item.texture = SKTexture(imageNamed: badImages[Int.random(in: 0..<badImages.count)])
                item.name = "bad"
            } else {
                item.texture = SKTexture(imageNamed: "meteoro1")
                item.name = "meteoro"
            }
            
        }
        
        
        switch direction {
        case .UP:
            xInitial = CGFloat.random(in: renderer.scene.size.width * 0.06...renderer.scene.size.width * 0.94)
            yInitial = renderer.scene.size.height*1.1
            
            item.vy = -5
          
        case .DOWN:
            xInitial = CGFloat.random(in: renderer.scene.size.width * 0.06...renderer.scene.size.width * 0.94)
            yInitial = renderer.scene.size.height * -0.1
            
            item.vy = 5
        case .RIGHT:
            xInitial = renderer.scene.size.width * 1.1
            yInitial = CGFloat.random(in: renderer.scene.size.height * 0.125...renderer.scene.size.height * 0.84)
            
            item.vx = -5

        case .LEFT:
            xInitial = renderer.scene.size.width * -0.1
            yInitial = CGFloat.random(in: renderer.scene.size.height * 0.125...renderer.scene.size.height * 0.84)
            
            item.vx = 5
        case .NONE:
            print()
        case .DEAD:
            print()
        }
        
        item.size = CGSize(width: renderer.scene.size.height*0.05, height: renderer.scene.size.height*0.05)
        item.position = CGPoint(x: xInitial, y: yInitial)
        
        renderer.drawItem(item: item)
        
    }
    
    func nextLevel(points: Int){
        if points >= 250 {
            renderer.changeBackground(named: Backgrounds.shared.blueBackground())
        }
        else if points >= 500 {
            renderer.changeBackground(named: Backgrounds.shared.lightGreenBackground())
        }
        else if points >= 750 {
            renderer.changeBackground(named: Backgrounds.shared.GreenBackground())
        }
        else if points >= 1000 {
            renderer.changeBackground(named: Backgrounds.shared.cityBackground())
        }
        else if points >= 1500 {
            renderer.changeBackground(named: Backgrounds.shared.planetBackground())
        }
    }
    
    func recursiveActionItems(){
        let recursive = SKAction.sequence([
            SKAction.run(createItems),
            SKAction.wait(forDuration: 1),
            SKAction.run({[unowned self] in self.recursiveActionItems()})
        ])
        
        renderer.scene.run(recursive, withKey: "aKey")
    }
    
    func cancelActionItems() {
        renderer.scene.removeAction(forKey: "aKey")
    }
}

