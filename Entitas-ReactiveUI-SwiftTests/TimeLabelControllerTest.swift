//
//  TimeLabelControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import Entitas_ReactiveUI_Swift

class TimeLabelControllerTest: XCTestCase {
    
    func testZero() {
        assert(ticks: 0, text: "00:00")
    }
    
    func testFive() {
        assert(ticks: 5*60, text: "00:05")
    }
    
    func testTwetyFive() {
        assert(ticks: 25*60, text: "00:25")
    }
    
    func testEightyFive() {
        assert(ticks: 85*60, text: "01:25")
    }
    
    func testThousendEightyFive() {
        assert(ticks: 1085*60, text: "18:05")
    }
    
    private func assert(ticks : UInt64, text : String){
        // given
        let label = UILabel()
        let c = TimeLabelController(timeLabel: label)
        // when
        c.tickChanged(tick: ticks)
        // then
        XCTAssertEqual(label.text, text)
    }
}
