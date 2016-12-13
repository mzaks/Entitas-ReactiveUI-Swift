//
//  CustomControllers.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import UIKit
import Entitas

struct TimeLabelController : TickListener {
    let timeLabel : UILabel
    
    func tickChanged(tick: UInt64) {
        let sec = (tick / 60) % 60
        let min = (tick / 3600)
        let secText = sec > 9 ? "\(sec)" : "0\(sec)"
        let minText = min > 9 ? "\(min)" : "0\(min)"
        timeLabel.text = "\(minText):\(secText)"
    }
}

struct TimeSliderController : PauseListener {
    let timeSlider : UISlider
    let ctx : Context
    
    func pauseStateChanged(paused: Bool) {
        timeSlider.isHidden = !paused
        
        if paused, let tick = ctx.uniqueComponent(TickComponent.self)?.value {
            timeSlider.maximumValue = Float(tick)
            timeSlider.value = Float(tick)
        }
    }
}

struct ElixirAmountRepresentationController : ElixirListener {
    let elixirIndicator: UIProgressView
    let elixirLabel: UILabel
    
    func elixirChanged(amount: Float) {
        elixirLabel.text = "\(Int(amount))"
        elixirLabel.textColor = amount >= 10 ? UIColor.yellow : UIColor.white
        elixirIndicator.progress = min(amount / 10.0, 1.0)
        elixirIndicator.progressTintColor = amount >= 10 ? UIColor.yellow : UIColor.green
    }
}

struct PauseButtonController : PauseListener {
    let pauseButton : UIButton
    
    func pauseStateChanged(paused: Bool) {
        if paused {
            pauseButton.setTitle("Resume", for: [])
        } else {
            pauseButton.setTitle("Pause", for: [])
        }
    }
}

struct ConsumeButtonController : PauseListener, ElixirListener {
    let consumeButton : UIButton
    let consumeButtonProgress: UIProgressView
    let ctx : Context
    
    func pauseStateChanged(paused: Bool) {
        consumeButton.isEnabled = !paused
    }
    
    func elixirChanged(amount: Float) {
        let paused = ctx.hasUniqueComponent(PauseComponent.self)
        consumeButton.isEnabled = consumeButton.tag <= Int(amount) && !paused
        consumeButtonProgress.progress = 1 - min(1, (amount / Float(consumeButton.tag)))
    }
}
