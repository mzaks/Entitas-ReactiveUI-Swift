//
//  NotifyTickListenersSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class NotifyTickListenersSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    private class MockListener : TickListener {
        
        var changes : [UInt64] = []
        
        func tickChanged(tick: UInt64) {
            changes.append(tick)
        }
    }
    
    func testNotifyListener() {
        // given
        let s = NotifyTickListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        ctx.createEntity().set(TickListenerComponent(ref: mock1))
        ctx.setUniqueEntityWith(TickComponent(value: 25))
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [25])
    }
    
    func testNotifyMultipleListeners() {
        // given
        let s = NotifyTickListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(TickListenerComponent(ref: mock1))
        ctx.createEntity().set(TickListenerComponent(ref: mock2))
        ctx.setUniqueEntityWith(TickComponent(value: 23))
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [23])
        XCTAssertEqual(mock2.changes, [23])
    }
    
    func testNotifyMultipleListenersOverMultipleTicks() {
        // given
        let s = NotifyTickListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(TickListenerComponent(ref: mock1))
        ctx.createEntity().set(TickListenerComponent(ref: mock2))
        // when
        for i in 1...5 {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(i) + 3))
            s.execute()
        }
        
        // then
        XCTAssertEqual(mock1.changes, [4, 5, 6, 7, 8])
        XCTAssertEqual(mock2.changes, [4, 5, 6, 7, 8])
    }
    
    func testIgnoreIfTickIsNotPresent() {
        // given
        let s = NotifyTickListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        ctx.createEntity().set(TickListenerComponent(ref: mock1))
        ctx.setUniqueEntityWith(TickComponent(value: 23))
        ctx.destroyUniqueEntity(TickComponent.matcher)
        // when
        s.execute()
        
        // then
        XCTAssertEqual(mock1.changes, [])
    }
}
