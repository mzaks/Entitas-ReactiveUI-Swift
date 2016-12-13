//
//  ElixirProduceSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ElixirProduceSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testInitialize() {
        // given 
        let s = ElixirProduceSystem(ctx: ctx)
        // when
        s.initialize()
        // then
        XCTAssert(ctx.uniqueComponent(ElixirComponent.self)?.value == 0)
    }
    
    func testReactOnTickChange() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        // when
        ctx.setUniqueEntityWith(TickComponent(value: 0))
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0.01)
    }
    
    func testExecuteWithoutInitialisation() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        // when
        ctx.setUniqueEntityWith(TickComponent(value: 0))
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, nil)
    }
    
    func testExecuteWihtoutTickChange() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0)
    }
    
    func testElixirIsAddedEveryThirdTick() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        // when
        for i in 0...3 {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(i)))
            s.execute()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0.02)
    }
    
    func testElixirIsAddedEveryThirdTickRuningFiveTicks() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        // when
        for i in 0...5 {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(i)))
            s.execute()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0.02)
    }
    
    func testElixirProductionIsCappedAt10() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        // when
        for i in 0...4_000 {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(i)))
            s.execute()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 10)
    }
    
    func testReinitialise() {
        // given
        let s = ElixirProduceSystem(ctx: ctx)
        s.initialize()
        ctx.setUniqueEntityWith(TickComponent(value: 0))
        s.execute()
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0.01)
        
        // when
        s.initialize()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0)
    }
}
