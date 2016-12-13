//
//  ElixirConsumeSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class ElixirConsumeSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testReactOnConsumtion() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 3))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 2)
    }
    
    
    func testReactOnMultipleConsumtions() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 3))
        ctx.createEntity().set(ConsumeElixirComponent(value: 2))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 0)
    }
    
    func testIngonreConsumtionIfHigherThanGivenAmount() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 7))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 5)
    }
    
    func testIngonreConsumtionIfElixirNotSet() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        // when
        ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, nil)
    }
    
    func testEnsureConsomptionComponentIsPresent() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        ctx.setUniqueEntityWith(ElixirComponent(value: 5))
        // when
        let e = ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        ctx.destroyEntity(e)
        s.execute()
        //then
        XCTAssertEqual(ctx.uniqueComponent(ElixirComponent.self)?.value, 5)
    }
    
    func testCleanup() {
        // given
        let s = ElixirConsumeSystem(ctx: ctx)
        ctx.createEntity().set(ConsumeElixirComponent(value: 1))
        ctx.createEntity().set(ConsumeElixirComponent(value: 3))
        // when
        s.cleanup()
        //then
        XCTAssertEqual(ctx.entityGroup(ConsumeElixirComponent.matcher).count, 0)
    }
}
