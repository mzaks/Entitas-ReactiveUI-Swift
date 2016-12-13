//
//  PauseButtonControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import Entitas_ReactiveUI_Swift

class PauseButtonControllerTest: XCTestCase {
    
    
    func testInPause() {
        // given 
        let button = UIButton()
        let c = PauseButtonController(pauseButton: button)
        // when
        c.pauseStateChanged(paused: true)
        // then
        XCTAssertEqual(button.titleLabel?.text, "Resume")
    }
    
    func testNotInPause() {
        // given
        let button = UIButton()
        let c = PauseButtonController(pauseButton: button)
        // when
        c.pauseStateChanged(paused: false)
        // then
        XCTAssertEqual(button.titleLabel?.text, "Pause")
    }
    
}
