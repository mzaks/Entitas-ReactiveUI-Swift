//
//  TickSystemTest.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 08.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import XCTest
import Entitas
@testable import Entitas_ReactiveUI_Swift

class TickSystemTest: XCTestCase {
    
    var ctx : Context!
    
    override func setUp() {
        super.setUp()
        ctx = Context()
    }
    
    func testInitialisation() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        // when
        s.initialize()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 0)
    }
    
    func testExecution() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        s.initialize()
        // when
        s.execute()
        s.execute()
        s.execute()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 3)
    }
    
    func testExecutionWhileInPause() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        s.initialize()
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        s.execute()
        s.execute()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 0)
    }
    
    func testExecutionWhileInPauseAndAfterPauseRemoved() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        s.initialize()
        ctx.setUniqueEntityWith(PauseComponent())
        // when
        s.execute()
        s.execute()
        s.execute()
        ctx.destroyUniqueEntity(PauseComponent.matcher)
        s.execute()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 1)
    }
    
    func testExecutionWithoutInitialisation() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        // when
        s.execute()
        s.execute()
        s.execute()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == nil)
    }
    
    func testReinitialize() {
        // given
        let s = TickUpdateSystem(ctx: ctx)
        s.initialize()
        s.execute()
        s.execute()
        s.execute()
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 3)
        // when
        s.initialize()
        //then
        XCTAssert(ctx.uniqueComponent(TickComponent.self)?.value == 0)
    }
}
