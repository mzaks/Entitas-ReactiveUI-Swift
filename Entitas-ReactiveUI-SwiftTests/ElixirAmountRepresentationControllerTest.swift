//
//  ElixirAmountRepresentationControllerTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 11.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
@testable import Entitas_ReactiveUI_Swift

class ElixirAmountRepresentationControllerTest: XCTestCase {
    
    var progress : UIProgressView!
    var label : UILabel!
    var controller : ElixirAmountRepresentationController!
    
    override func setUp() {
        super.setUp()
        // given
        progress  = UIProgressView()
        label = UILabel()
        controller = ElixirAmountRepresentationController(elixirIndicator: progress, elixirLabel: label)
    }
    
    func testLabel() {
        // when
        controller.elixirChanged(amount: 5.7)
        // then
        XCTAssertEqual(label.text, "5")
    }
    
    func testLabelColor() {
        // when
        controller.elixirChanged(amount: 5.7)
        // then
        XCTAssertEqual(label.textColor, UIColor.white)
    }
    
    func testLabelColorHigh() {
        // when
        controller.elixirChanged(amount: 10)
        // then
        XCTAssertEqual(label.textColor, UIColor.yellow)
    }
    
    func testLabelColorTooHigh() {
        // when
        controller.elixirChanged(amount: 12)
        // then
        XCTAssertEqual(label.textColor, UIColor.yellow)
    }
    
    func testProgress() {
        // when
        controller.elixirChanged(amount: 5.7)
        // then
        XCTAssertEqual(progress.progress, 0.57)
    }
    
    func testProgressCap() {
        // when
        controller.elixirChanged(amount: 15.7)
        // then
        XCTAssertEqual(progress.progress, 1)
    }
    
    func testProgressColor() {
        // when
        controller.elixirChanged(amount: 5.7)
        // then
        XCTAssertEqual(progress.progressTintColor, UIColor.green)
    }
    
    func testProgressColorOnTheCap() {
        // when
        controller.elixirChanged(amount: 10)
        // then
        XCTAssertEqual(progress.progressTintColor, UIColor.yellow)
    }
}
