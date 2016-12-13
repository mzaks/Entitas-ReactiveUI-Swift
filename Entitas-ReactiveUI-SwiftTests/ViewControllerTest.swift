//
//  ViewControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 09.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ViewControllerTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testPause() {
        // given 
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let button = UIButton()
        // when
        vc.pauseResume(button)
        // then
        XCTAssert(ctx.hasUniqueComponent(PauseComponent.self))
    }
    
    func testResume() {
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let button = UIButton()
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        vc.pauseResume(button)
        // then
        XCTAssert(!ctx.hasUniqueComponent(PauseComponent.self))
    }
    
    func testConsumeAction(){
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let button = UIButton()
        button.tag = 5
        // when
        vc.consumeAction(button)
        // then
        XCTAssertEqual(ctx.uniqueComponent(ConsumeElixirComponent.self)?.value, 5)
    }
    
    func testTimeTravel(){
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let slider = UISlider()
        slider.maximumValue = 100
        slider.value = 45
        // when
        vc.timeTravel(slider)
        // then
        XCTAssertEqual(ctx.uniqueComponent(JumpIntTimeComponent.self)?.value, 45)
    }
    
    func testTimeLabel3Seconds() {
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.timeLabel = label
        // when
        vc.tickChanged(tick: 183)
        // then
        XCTAssertEqual(vc.timeLabel.text, "00:03")
    }
    
    func testTimeLabel13Seconds() {
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.timeLabel = label
        // when
        vc.tickChanged(tick: 13*60 + 2)
        // then
        XCTAssertEqual(vc.timeLabel.text, "00:13")
    }
    
    func testTimeLabel13Minutes() {
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.timeLabel = label
        // when
        vc.tickChanged(tick: 13*60*60 + 2)
        // then
        XCTAssertEqual(vc.timeLabel.text, "13:00")
    }
    
    func testElixirChangeSmall(){
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.elixirLabel = label
        let (b1, b2, b3) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        let (indicator, i1, i2 , i3) = (UIProgressView(), UIProgressView(), UIProgressView(), UIProgressView())
        vc.elixirIndicator = indicator
        vc.consumeButton1Progress = i1
        vc.consumeButton2Progress = i2
        vc.consumeButton3Progress = i3
        // when
        vc.elixirChanged(amount: 1)
        // then
        XCTAssertEqual(vc.elixirLabel.text, "1")
        XCTAssertEqual(vc.elixirLabel.textColor, UIColor.white)
        XCTAssertEqual(vc.elixirIndicator.progress, 0.1)
        XCTAssertEqual(vc.elixirIndicator.progressTintColor, UIColor.green)
        XCTAssertEqual(vc.consumeButton1.isEnabled, true)
        XCTAssertEqual(vc.consumeButton2.isEnabled, false)
        XCTAssertEqual(vc.consumeButton3.isEnabled, false)
        XCTAssertEqual(vc.consumeButton1Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton2Progress.progress, 0.5)
        XCTAssertEqual(vc.consumeButton3Progress.progress, 0.75)
    }
    
    func testElixirChangeMid(){
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.elixirLabel = label
        let (b1, b2, b3) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        let (indicator, i1, i2 , i3) = (UIProgressView(), UIProgressView(), UIProgressView(), UIProgressView())
        vc.elixirIndicator = indicator
        vc.consumeButton1Progress = i1
        vc.consumeButton2Progress = i2
        vc.consumeButton3Progress = i3
        // when
        vc.elixirChanged(amount: 5)
        // then
        XCTAssertEqual(vc.elixirLabel.text, "5")
        XCTAssertEqual(vc.elixirLabel.textColor, UIColor.white)
        XCTAssertEqual(vc.elixirIndicator.progress, 0.5)
        XCTAssertEqual(vc.elixirIndicator.progressTintColor, UIColor.green)
        XCTAssertEqual(vc.consumeButton1.isEnabled, true)
        XCTAssertEqual(vc.consumeButton2.isEnabled, true)
        XCTAssertEqual(vc.consumeButton3.isEnabled, true)
        XCTAssertEqual(vc.consumeButton1Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton2Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton3Progress.progress, 0)
    }
    
    func testElixirChangeMax(){
        // given
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.elixirLabel = label
        let (b1, b2, b3) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        let (indicator, i1, i2 , i3) = (UIProgressView(), UIProgressView(), UIProgressView(), UIProgressView())
        vc.elixirIndicator = indicator
        vc.consumeButton1Progress = i1
        vc.consumeButton2Progress = i2
        vc.consumeButton3Progress = i3
        // when
        vc.elixirChanged(amount: 10)
        // then
        XCTAssertEqual(vc.elixirLabel.text, "10")
        XCTAssertEqual(vc.elixirLabel.textColor, UIColor.yellow)
        XCTAssertEqual(vc.elixirIndicator.progress, 1)
        XCTAssertEqual(vc.elixirIndicator.progressTintColor, UIColor.yellow)
        XCTAssertEqual(vc.consumeButton1.isEnabled, true)
        XCTAssertEqual(vc.consumeButton2.isEnabled, true)
        XCTAssertEqual(vc.consumeButton3.isEnabled, true)
        XCTAssertEqual(vc.consumeButton1Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton2Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton3Progress.progress, 0)
    }
    
    func testElixirChangeMaxInPause(){
        // given
        ctx.setUniqueEntityWith(PauseComponent())
        let vc = ViewController()
        vc.setContext(ctx: ctx)
        let label = UILabel()
        vc.elixirLabel = label
        let (b1, b2, b3) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        let (indicator, i1, i2 , i3) = (UIProgressView(), UIProgressView(), UIProgressView(), UIProgressView())
        vc.elixirIndicator = indicator
        vc.consumeButton1Progress = i1
        vc.consumeButton2Progress = i2
        vc.consumeButton3Progress = i3
        // when
        vc.elixirChanged(amount: 10)
        // then
        XCTAssertEqual(vc.elixirLabel.text, "10")
        XCTAssertEqual(vc.elixirLabel.textColor, UIColor.yellow)
        XCTAssertEqual(vc.elixirIndicator.progress, 1)
        XCTAssertEqual(vc.elixirIndicator.progressTintColor, UIColor.yellow)
        XCTAssertEqual(vc.consumeButton1.isEnabled, false)
        XCTAssertEqual(vc.consumeButton2.isEnabled, false)
        XCTAssertEqual(vc.consumeButton3.isEnabled, false)
        XCTAssertEqual(vc.consumeButton1Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton2Progress.progress, 0)
        XCTAssertEqual(vc.consumeButton3Progress.progress, 0)
    }
    
    func testPaused(){
        // given
        let vc = ViewController()
        ctx.setUniqueEntityWith(TickComponent(value: 25))
        vc.setContext(ctx: ctx)
        let (b1, b2, b3, pauseButton) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        vc.pauseButton = pauseButton
        let slider = UISlider()
        vc.timeSlider = slider
        // when
        vc.pauseStateChanged(paused: true)
        // then
        XCTAssertEqual(vc.timeSlider.isHidden, false)
        XCTAssertEqual(vc.timeSlider.maximumValue, 25)
        XCTAssertEqual(vc.timeSlider.value, 25)
        XCTAssertEqual(vc.consumeButton1.isEnabled, false)
        XCTAssertEqual(vc.consumeButton2.isEnabled, false)
        XCTAssertEqual(vc.consumeButton3.isEnabled, false)
        XCTAssertEqual(vc.pauseButton.titleLabel?.text, "Resume")
    }
    
    func testNotPaused(){
        // given
        let vc = ViewController()
        ctx.setUniqueEntityWith(TickComponent(value: 25))
        vc.setContext(ctx: ctx)
        let (b1, b2, b3, pauseButton) = (UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom), UIButton(type: .custom))
        b1.tag = 1
        b2.tag = 2
        b3.tag = 4
        vc.consumeButton1 = b1
        vc.consumeButton2 = b2
        vc.consumeButton3 = b3
        vc.pauseButton = pauseButton
        let slider = UISlider()
        vc.timeSlider = slider
        // when
        vc.pauseStateChanged(paused: false)
        // then
        XCTAssertEqual(vc.timeSlider.isHidden, true)
        XCTAssertEqual(vc.consumeButton1.isEnabled, true)
        XCTAssertEqual(vc.consumeButton2.isEnabled, true)
        XCTAssertEqual(vc.consumeButton3.isEnabled, true)
        XCTAssertEqual(vc.pauseButton.titleLabel?.text, "Pause")
    }
}
