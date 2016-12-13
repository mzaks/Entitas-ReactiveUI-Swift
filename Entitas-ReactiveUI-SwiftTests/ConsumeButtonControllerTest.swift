//
//  ConsumeButtonControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ConsumeButtonControllerTest: XCTestCase {
    
    var progress : UIProgressView!
    var button : UIButton!
    var controller : ConsumeButtonController!
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        // given
        ctx = Context()
        progress  = UIProgressView()
        button = UIButton()
        button.tag = 3
        controller = ConsumeButtonController(consumeButton: button, consumeButtonProgress: progress, ctx: ctx)
    }
    
    func testProgress() {
        // when
        controller.elixirChanged(amount: 1)
        // then
        XCTAssertEqualWithAccuracy(progress.progress, 0.6666, accuracy: 0.001)
    }
    
    func testProgressFull() {
        // when
        controller.elixirChanged(amount: 0)
        // then
        XCTAssertEqual(progress.progress, 1)
    }
    
    func testProgressEmpty() {
        // when
        controller.elixirChanged(amount: 5)
        // then
        XCTAssertEqual(progress.progress, 0)
    }
    
    func testButtonIsDisabledOnPause() {
        // when
        controller.pauseStateChanged(paused: true)
        // then
        XCTAssertEqual(button.isEnabled, false)
    }
    
    func testButtonIsEnabledOnResume() {
        // when
        controller.pauseStateChanged(paused: true)
        controller.pauseStateChanged(paused: false)
        // then
        XCTAssertEqual(button.isEnabled, true)
    }
    
    func testButtonIsDisabledOnNotEnoughElixir() {
        // when
        controller.elixirChanged(amount: 1)
        // then
        XCTAssertEqual(button.isEnabled, false)
    }
}
