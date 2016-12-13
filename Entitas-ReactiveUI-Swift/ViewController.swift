//
//  ViewController.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 06.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas

class ViewController: UIViewController, TickListener, ElixirListener, PauseListener {
    
    private(set) var ctx : Context!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var elixirIndicator: UIProgressView!
    @IBOutlet weak var elixirLabel: UILabel!
    
    @IBOutlet weak var consumeButton1: UIButton!
    @IBOutlet weak var consumeButton1Progress: UIProgressView!
    @IBOutlet weak var consumeButton2: UIButton!
    @IBOutlet weak var consumeButton2Progress: UIProgressView!
    @IBOutlet weak var consumeButton3: UIButton!
    @IBOutlet weak var consumeButton3Progress: UIProgressView!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBAction func pauseResume(_ sender: UIButton) {
        if ctx.hasUniqueComponent(PauseComponent.self) {
            ctx.destroyUniqueEntity(PauseComponent.matcher)
        } else {
            ctx.setUniqueEntityWith(PauseComponent())
        }
    }
    @IBAction func consumeAction(_ sender: UIButton) {
        ctx.createEntity().set(ConsumeElixirComponent(value: sender.tag))
    }
    @IBAction func timeTravel(_ sender: UISlider) {
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: UInt64(sender.value)))
    }
    
    func setContext(ctx : Context){
        self.ctx = ctx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeSlider.isHidden = true
        elixirLabel.text = "0"
        consumeButton1.tag = 2
        consumeButton1.setTitle("2", for: [])
        consumeButton2.tag = 3
        consumeButton2.setTitle("3", for: [])
        consumeButton3.tag = 4
        consumeButton3.setTitle("4", for: [])
        
        ctx.createEntity()
            .set(TickListenerComponent(ref: self))
            .set(ElixirListenerComponent(ref: self))
            .set(PauseListenerComponent(ref: self))
        
        
        // In case you want to extract the listeners logic
//        let timeVC = TimeLabelController(timeLabel: timeLabel)
//        ctx.createEntity().set(TickListenerComponent(ref: timeVC))
//        
//        let timeSliderVC = TimeSliderController(timeSlider: timeSlider, ctx: ctx)
//        ctx.createEntity().set(PauseListenerComponent(ref: timeSliderVC))
//        
//        let elixirIndicatorVC = ElixirAmountRepresentationController(elixirIndicator: elixirIndicator, elixirLabel: elixirLabel)
//        ctx.createEntity().set(ElixirListenerComponent(ref: elixirIndicatorVC))
//        
//        let pauseButtonVC = PauseButtonController(pauseButton: pauseButton)
//        ctx.createEntity().set(PauseListenerComponent(ref: pauseButtonVC))
//        
//        let buttonVC1 = ConsumeButtonController(consumeButton: consumeButton1, consumeButtonProgress: consumeButton1Progress, ctx: ctx)
//        ctx.createEntity().set(PauseListenerComponent(ref: buttonVC1)).set(ElixirListenerComponent(ref: buttonVC1))
//        
//        let buttonVC2 = ConsumeButtonController(consumeButton: consumeButton2, consumeButtonProgress: consumeButton2Progress, ctx: ctx)
//        ctx.createEntity().set(PauseListenerComponent(ref: buttonVC2)).set(ElixirListenerComponent(ref: buttonVC2))
//        
//        let buttonVC3 = ConsumeButtonController(consumeButton: consumeButton3, consumeButtonProgress: consumeButton3Progress, ctx: ctx)
//        ctx.createEntity().set(PauseListenerComponent(ref: buttonVC3)).set(ElixirListenerComponent(ref: buttonVC3))
    }

    func tickChanged(tick: UInt64) {
        let sec = (tick / 60) % 60
        let min = (tick / 3600)
        let secText = sec > 9 ? "\(sec)" : "0\(sec)"
        let minText = min > 9 ? "\(min)" : "0\(min)"
        timeLabel.text = "\(minText):\(secText)"
    }
    
    func elixirChanged(amount: Float) {
        elixirLabel.text = "\(Int(amount))"
        elixirLabel.textColor = amount == 10 ? UIColor.yellow : UIColor.white
        elixirIndicator.progress = amount / 10.0
        elixirIndicator.progressTintColor = amount == 10 ? UIColor.yellow : UIColor.green
        
        let paused = ctx.hasUniqueComponent(PauseComponent.self)
        
        consumeButton1.isEnabled = consumeButton1.tag <= Int(amount) && !paused
        consumeButton2.isEnabled = consumeButton2.tag <= Int(amount) && !paused
        consumeButton3.isEnabled = consumeButton3.tag <= Int(amount) && !paused
        
        consumeButton1Progress.progress = 1 - min(1, (amount / Float(consumeButton1.tag)))
        consumeButton2Progress.progress = 1 - min(1, (amount / Float(consumeButton2.tag)))
        consumeButton3Progress.progress = 1 - min(1, (amount / Float(consumeButton3.tag)))
    }
    
    func pauseStateChanged(paused: Bool) {
        if paused, let tick = ctx.uniqueComponent(TickComponent.self)?.value {
            timeSlider.isHidden = false
            timeSlider.maximumValue = Float(tick)
            timeSlider.value = Float(tick)
            pauseButton.setTitle("Resume", for: [])
        } else {
            timeSlider.isHidden = true
            pauseButton.setTitle("Pause", for: [])
        }
        consumeButton1.isEnabled = !paused
        consumeButton2.isEnabled = !paused
        consumeButton3.isEnabled = !paused
    }
}
