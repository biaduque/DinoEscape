//
//  SettingsPopUpScene.swift
//  DinoEscape tvOS
//
//  Created by Carolina Ortega on 31/03/22.
//

import Foundation
import SpriteKit

class SettingsPopUpScene: SKSpriteNode {
    var btnHome = SKButton()
    var btnBack = SKButton()

    //invisible button
    var guideButton = SKButton()
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
        self.setUpScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    func setUpScene() {
        self.isUserInteractionEnabled = true
        
        removeAllChildren()
        removeAllActions()
        
        let background = SKShapeNode(rect: CGRect(x: self.size.width/2 * -1,
                                                  y: self.size.height/2 * -1,
                                                  width: self.size.width,
                                                  height: self.size.height))
        
        background.fillColor = SKColor(red: 235/255, green: 231/255, blue: 198/255, alpha: 1)
        print(background.position)
        self.addChild(background)
        
        background.addChild(createLabel(text: "Pause".localized(),
                                        fontSize: size.height/8,
                                        fontColor: SKColor(red: 57/255, green: 100/255, blue: 113/255, alpha: 1),
                                        position: CGPoint(x: 0, y: background.frame.size.height/3),
                                        alignmentH: SKLabelHorizontalAlignmentMode.center
                                       ))
        
        background.addChild(createLabel(text: "Music".localized(),
                                        fontSize: size.height/14,
                                        fontColor: SKColor(red: 57/255, green: 100/255, blue: 113/255, alpha: 1),
                                        position: CGPoint(x: background.frame.size.width/3 * -1, y: background.frame.size.height/8),
                                        alignmentH: SKLabelHorizontalAlignmentMode.left
                                       ))

        
        background.addChild(createSwitch(pos: CGPoint(x: background.frame.size.width/4, y: background.frame.size.height/8), type: .music))

        HapticService.shared.addVibration(haptic: "Haptic")

        btnBack = createBackButton(position: CGPoint(x: 0, y: background.frame.size.height/6.0 * -1))
        btnHome = createHomeButton(position: CGPoint(x: 0, y: background.frame.size.height/2.6 * -1))
        
        guideButton.position = CGPoint(x: background.frame.size.width/4, y: background.frame.size.height/6.0 * -1)
        guideButton.size = CGSize(width: 50, height: 50)
        //guideButton.color = .red
        addChild(guideButton)
        
        background.addChild(btnBack)
        background.addChild(btnHome)
        
        addTapGestureRecognizer()

    }
    
    func changeSwitchMusic() -> String {
        var imageName : String
        if UserDefaults.standard.bool(forKey: "music") {
            imageName = "switchON"
        } else {
            imageName = "switchOFF"
        }
        return imageName
    }
    
    func changeSwitchVibration() -> String {
        var imageName : String
        if UserDefaults.standard.bool(forKey: "vibration") == true {
            imageName = "switchON"
        } else {
            imageName = "switchOFF"
        }
        return imageName
    }
    
    
    func createSwitch(pos: CGPoint, type: SwitchType) -> SKButton {
        let texture: SKTexture
        switch type {
        case .music:
            texture = SKTexture(imageNamed: "\(self.changeSwitchMusic())")
        case .vibration:
            texture = SKTexture(imageNamed: "\(changeSwitchVibration())")
        }
        
        texture.filteringMode = .nearest
        
        let w: CGFloat = size.width / 8.0
        let h = w * texture.size().height / texture.size().width

        let switchButton: SKButton = SKButton(texture: texture, color: .clear, size: CGSize(width: w, height: h))
        switchButton.position = pos
        
        switchButton.selectedHandler = {
            switch type {
            case .music:
                _ = MusicService.shared.updateUserDefaults()
                switchButton.texture =  SKTexture(imageNamed: "\(self.changeSwitchMusic())")
                MusicService.shared.playLoungeMusic()
            case .vibration:
                HapticService.shared.updateUserDefaults()
                switchButton.texture =  SKTexture(imageNamed: "\(self.changeSwitchVibration())")
                HapticService.shared.addVibration(haptic: "Haptic")
            }
        }
        return switchButton
    }
    
    func createLabel(text: String, fontSize: CGFloat, fontColor: SKColor, position: CGPoint, alignmentH: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let label: SKLabelNode = SKLabelNode(text: text)
        label.fontName = "Aldrich-Regular"
        label.fontSize = fontSize
        label.numberOfLines = 2
        label.horizontalAlignmentMode = alignmentH
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.fontColor = fontColor
        label.position = position
        return label
    }
    
    func createBackButton(position: CGPoint) -> SKButton{
        let texture = SKTexture(imageNamed: "resumeButton")
        texture.filteringMode = .nearest
        
        let w: CGFloat = size.height / 1.8
        let h = w * texture.size().height / texture.size().width
        
        let button: SKButton = SKButton(texture: texture, color: .clear, size: CGSize(width: w, height: h))
        button.position = position
        button.selectedHandler = {
            self.removeFromParent()
            GameController.shared.gameData.gameStatus = .playing
            GameController.shared.pauseActionItems()
        }
        return button
    }

    func createHomeButton(position: CGPoint) -> SKButton {
        
        let texture = SKTexture(imageNamed: "homeBackButton")
        texture.filteringMode = .nearest
        
        let w: CGFloat = size.height / 2.2
        let h = w * texture.size().height / texture.size().width
        
        let button: SKButton = SKButton(texture: texture, color: .clear, size: CGSize(width: w, height: h))
        button.position = position
        button.selectedHandler = {
            GameController.shared.restartGame()
            self.scene?.view?.presentScene(HomeScene.newGameScene())
        }
        return button
    }
    func addTapGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped(sender:)))
        self.scene?.view?.addGestureRecognizer(tapRecognizer)
        
    }
    
    
    
    @objc func tapped(sender: AnyObject) {
        
        if (btnBack.isFocused){
            
            self.removeFromParent()
            GameController.shared.gameData.gameStatus = .playing
            GameController.shared.pauseActionItems()
            
        }
        else {
            print("não sei ler oq vc quer")
        }
    }
}