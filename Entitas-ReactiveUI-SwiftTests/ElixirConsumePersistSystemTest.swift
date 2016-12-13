//
//  ElixirConsumePersistSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ElixirConsumePersistSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testReactOnConsumtion() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        ctx.setUniqueEntityWith(TickComponent(value: 30))
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values.first, ConsumtionEntry(tick: 30, amount: 1))
    }
    
    func testIgnoreIfTickIsNotSet() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values.first, nil)
    }
    
    func testIgnoreIfNoConsumtionWasCreated() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        ctx.setUniqueEntityWith(TickComponent(value: 30))
        // when
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values.first, nil)
    }
    
    func testIgnoreIfConsumtionIsNotPresentOnSystemExecute() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        ctx.setUniqueEntityWith(TickComponent(value: 30))
        let e = ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        ctx.destroyEntity(e)
        // when
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values.first, nil)
    }
    
    func testIgnoreIfInPause() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        ctx.setUniqueEntityWith(TickComponent(value: 30))
        ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values.first, nil)
    }
    
    func testCreationOfMultipleConsumptions() {
        // given
        let s = ElixirConsumePersistSystem(ctx: ctx)
        
        let consumptionFrequency = 25
        
        // when
        
        for i in 0...100 {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(i)))
            if i % consumptionFrequency == 0 {
                ctx.createEntity().set(ConsumeElixirComponent(value: 1))
            }
            s.execute()
        }
        
        //then
        let values = ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values
        XCTAssertEqual(values.count, 5)
        XCTAssertEqual(values[0], ConsumtionEntry(tick: 0, amount: 1))
        XCTAssertEqual(values[1], ConsumtionEntry(tick: 25, amount: 1))
        XCTAssertEqual(values[2], ConsumtionEntry(tick: 50, amount: 1))
        XCTAssertEqual(values[3], ConsumtionEntry(tick: 75, amount: 1))
        XCTAssertEqual(values[4], ConsumtionEntry(tick: 100, amount: 1))
    }
}
