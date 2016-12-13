//
//  Components.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 06.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import Foundation
import Entitas

struct TickComponent : UniqueComopnent {
    let value : UInt64
}

struct ElixirComponent : UniqueComopnent {
    let value : Float
}

struct ConsumeElixirComponent : Component {
    let value : Int
}

struct PauseComponent : UniqueComopnent{}

struct JumpIntTimeComponent : UniqueComopnent {
    let value : UInt64
}

struct ConsumtionEntry : Equatable {
    let tick : UInt64
    let amount : Int
    static func ==(o1 : ConsumtionEntry, o2 : ConsumtionEntry) -> Bool {
        return o1.tick == o2.tick && o1.amount == o2.amount
    }
}

struct ConsumtionHistoryComponent : UniqueComopnent {
    let values : [ConsumtionEntry]
}

struct EconomySystemChainComponent : UniqueComopnent {
    let ref : SystemChain
}

protocol TickListener {
    func tickChanged(tick : UInt64)
}
struct TickListenerComponent : Component {
    let ref : TickListener
}

protocol PauseListener {
    func pauseStateChanged(paused : Bool)
}
struct PauseListenerComponent : Component {
    let ref : PauseListener
}

protocol ElixirListener {
    func elixirChanged(amount : Float)
}
struct ElixirListenerComponent : Component {
    let ref : ElixirListener
}
