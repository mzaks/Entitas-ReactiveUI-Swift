//
//  NotifyElixirListenersSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class NotifyElixirListenersSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    private class MockListener : ElixirListener {
        
        var changes : [Float] = []
        
        func elixirChanged(amount: Float) {
            changes.append(amount)
        }
    }
    
    func testNotifyListener() {
        // given
        let s = NotifyElixirListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        ctx.createEntity().set(ElixirListenerComponent(ref: mock1))
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [5])
    }
    
    func testNotifyMultipleListeners() {
        // given
        let s = NotifyElixirListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(ElixirListenerComponent(ref: mock1))
        ctx.createEntity().set(ElixirListenerComponent(ref: mock2))
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [5])
        XCTAssertEqual(mock2.changes, [5])
    }
    
    func testNotifyMultipleListenersOverMultipleTicks() {
        // given
        let s = NotifyElixirListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(ElixirListenerComponent(ref: mock1))
        ctx.createEntity().set(ElixirListenerComponent(ref: mock2))
        // when
        for i in 1...5 {
            ctx.setUniqueEntityWith(ElixirComponent(value: Float(i) + 3))
            s.execute()
        }
        
        // then
        XCTAssertEqual(mock1.changes, [4, 5, 6, 7, 8])
        XCTAssertEqual(mock2.changes, [4, 5, 6, 7, 8])
    }
    
    func testIgnoreIfTickIsNotPresent() {
        // given
        let s = NotifyElixirListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        ctx.createEntity().set(ElixirListenerComponent(ref: mock1))
        ctx.setUniqueEntityWith(ElixirComponent(value: 23))
        ctx.destroyUniqueEntity(ElixirComponent.matcher)
        // when
        s.execute()
        
        // then
        XCTAssertEqual(mock1.changes, [])
    }
    
}
