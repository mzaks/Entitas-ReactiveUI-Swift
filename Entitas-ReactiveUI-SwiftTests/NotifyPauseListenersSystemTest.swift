//
//  NotifyPauseListenersSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class NotifyPauseListenersSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    private class MockListener : PauseListener {
        
        var changes : [Bool] = []
        
        func pauseStateChanged(paused: Bool) {
            changes.append(paused)
        }
    }
    
    func testNotifyListener() {
        // given
        let s = NotifyPauseListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        ctx.createEntity().set(PauseListenerComponent(ref: mock1))
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [true])
    }
    
    func testNotifyMultipleListeners() {
        // given
        let s = NotifyPauseListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(PauseListenerComponent(ref: mock1))
        ctx.createEntity().set(PauseListenerComponent(ref: mock2))
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        // then
        XCTAssertEqual(mock1.changes, [true])
        XCTAssertEqual(mock2.changes, [true])
    }
    
    func testNotifyMultipleListenersOverMultipleTicks() {
        // given
        let s = NotifyPauseListenersSystem(ctx: ctx)
        let mock1 = MockListener()
        let mock2 = MockListener()
        ctx.createEntity().set(PauseListenerComponent(ref: mock1))
        ctx.createEntity().set(PauseListenerComponent(ref: mock2))
        // when
        for i in 1...5 {
            
            if i % 2 == 0 {
                ctx.setUniqueEntityWith(PauseComponent())
            } else {
                ctx.destroyUniqueEntity(PauseComponent.matcher)
            }
            s.execute()
        }
        
        // then
        XCTAssertEqual(mock1.changes, [true, false, true, false])
        XCTAssertEqual(mock2.changes, [true, false, true, false])
    }
    
}
