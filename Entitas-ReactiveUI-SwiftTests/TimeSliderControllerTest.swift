//
//  TimeSliderControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class TimeSliderControllerTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        ctx = Context()
    }
    
    func testShow() {
        // given
        let slider = UISlider()
        let c = TimeSliderController(timeSlider: slider, ctx: ctx)
        // when
        c.pauseStateChanged(paused: true)
        // then
        XCTAssertEqual(slider.isHidden, false)
    }
    
    func testHide() {
        // given
        let slider = UISlider()
        let c = TimeSliderController(timeSlider: slider, ctx: ctx)
        // when
        c.pauseStateChanged(paused: false)
        // then
        XCTAssertEqual(slider.isHidden, true)
    }
    
    func testMaxValueIsEqualToTick() {
        // given
        ctx.setUniqueEntityWith(TickComponent(value:1024))
        let slider = UISlider()
        let c = TimeSliderController(timeSlider: slider, ctx: ctx)
        // when
        c.pauseStateChanged(paused: true)
        // then
        XCTAssertEqual(slider.maximumValue, 1024)
        XCTAssertEqual(slider.value, 1024)
    }
    
}
