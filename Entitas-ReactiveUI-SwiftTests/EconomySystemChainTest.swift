//
//  EconomySystemChainTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class EconomySystemChainTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testCreatingChainSetsEconomySystemChainComponent() {
        // when
        _ = createEconomyChain(ctx: ctx)
        // then
        XCTAssertNotNil(ctx.uniqueComponent(EconomySystemChainComponent.self))
    }
    
    func testRunProductionFor25Seconds() {
        // given
        let chain = createEconomyChain(ctx: ctx)
        // when
        chain.initialize()
        for _ in 1...60*25 {
            chain.execute()
            chain.cleanup()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 60*25)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 20*25 * 0.01, accuracy: 0.001)
    }
    
    func testRunProductionFor25SecondsWithConsumption() {
        // given
        let chain = createEconomyChain(ctx: ctx)
        let consumptionFrequency = 500;
        // when
        chain.initialize()
        for i in 1...60*25 {
            if i % consumptionFrequency == 0 {
                ctx.createEntity().set(ConsumeElixirComponent(value: 1))
            }
            chain.execute()
            chain.cleanup()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 60*25)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 2.0, accuracy: 0.001)
        XCTAssertEqual(ctx.entityGroup(ConsumeElixirComponent.matcher).count, 0)
        
    }
    
    func testRunProductionFor25SecondsWithConsumptionAndHistorisation() {
        // given
        let economyChain = createEconomyChain(ctx: ctx)
        let chain = SystemChain(named: "Test", contains: [economyChain, ElixirConsumePersistSystem(ctx:ctx)])
        let consumptionFrequency = 500;
        // when
        chain.initialize()
        for i in 1...60*25 {
            if i % consumptionFrequency == 0 {
                ctx.createEntity().set(ConsumeElixirComponent(value: 1))
            }
            chain.execute()
            chain.cleanup()
        }
        // then
        XCTAssertEqual(ctx.uniqueComponent(TickComponent.self)?.value, 60*25)
        XCTAssertEqualWithAccuracy((ctx.uniqueComponent(ElixirComponent.self)?.value)!, 2.0, accuracy: 0.001)
        XCTAssertEqual(ctx.entityGroup(ConsumeElixirComponent.matcher).count, 0)
        let values = ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values
        XCTAssertEqual(values.count, 3)
        XCTAssertEqual(values[0], ConsumtionEntry(tick: 500, amount: 1))
        XCTAssertEqual(values[1], ConsumtionEntry(tick: 1000, amount: 1))
        XCTAssertEqual(values[2], ConsumtionEntry(tick: 1500, amount: 1))
    }
}
