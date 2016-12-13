//
//  ReplaySystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ReplaySystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testReplayFirst25Seconds() {
        // given
        _ = createEconomyChain(ctx: ctx)
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: 25*60))
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 60*25)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 20*25 * 0.01, accuracy: 0.001)
    }
    
    func testJumpTo0() {
        // given
        _ = createEconomyChain(ctx: ctx)
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: 0))
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 0)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 0, accuracy: 0.001)
    }
    
    func testReplayFirst25SecondsAndConsume() {
        // given
        _ = createEconomyChain(ctx: ctx)
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: 25*60))
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: [
            ConsumtionEntry(tick: 1000, amount: 1),
            ConsumtionEntry(tick: 1020, amount: 2)
        ]))
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 60*25)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 20*25 * 0.01 - 3, accuracy: 0.001)
    }
    
    func testIgnoreReplayIfNotInPause() {
        // given
        _ = createEconomyChain(ctx: ctx)
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: 25*60))
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, nil)
        XCTAssertEqual((ctx.uniqueComponent(ElixirComponent.self)?.value), nil)
    }
    
    func testIgnoreReplayIfNoJumpInTimeComponent() {
        // given
        _ = createEconomyChain(ctx: ctx)
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, nil)
        XCTAssertEqual((ctx.uniqueComponent(ElixirComponent.self)?.value), nil)
    }
    
    func testIgnoreReplayIfNoChainCreated() {
        // given
        let s = ReplaySystem(ctx:ctx)
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(JumpIntTimeComponent(value: 25*60))
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, nil)
        XCTAssertEqual((ctx.uniqueComponent(ElixirComponent.self)?.value), nil)
    }
}
