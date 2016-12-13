//
//  CleanupConsumtionHistorySystem.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class CleanupConsumtionHistorySystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testCleanupConsumptionHistoryRemoveOneOutOfTwo() {
        // given
        let s = CleanupConsumtionHistorySystem(ctx:ctx)
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
        ]))
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(TickComponent(value: 25))
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values, [ConsumtionEntry(tick: 20, amount: 1)])
    }
    
    func testCleanupConsumptionHistoryRemoveAll() {
        // given
        let s = CleanupConsumtionHistorySystem(ctx:ctx)
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
            ]))
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(TickComponent(value: 5))
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values, [])
    }
    
    func testCleanupConsumptionHistoryRemoveNone() {
        // given
        let s = CleanupConsumtionHistorySystem(ctx:ctx)
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
            ]))
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.setUniqueEntityWith(TickComponent(value: 500))
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values, [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
        ])
    }
    
    func testDoNothingWhenTickIsNotPresent() {
        // given
        let s = CleanupConsumtionHistorySystem(ctx:ctx)
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
            ]))
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        // when
        s.execute()
        // then
        XCTAssertEqual(ctx.uniqueComponent(ConsumtionHistoryComponent.self)!.values, [
            ConsumtionEntry(tick: 20, amount: 1),
            ConsumtionEntry(tick: 200, amount: 2)
            ])
    }
    
    func testDoNothingWhenConsumtionHistoryIsNotPresent() {
        // given
        let s = CleanupConsumtionHistorySystem(ctx:ctx)
        
        ctx.setUniqueEntityWith(TickComponent(value: 500))
        ctx.setUniqueEntityWith(PauseComponent())
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        // when
        s.execute()
        // then
        XCTAssertNil(ctx.uniqueComponent(ConsumtionHistoryComponent.self))
    }
}
