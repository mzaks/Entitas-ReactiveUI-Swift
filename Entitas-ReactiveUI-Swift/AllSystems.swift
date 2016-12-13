//
//  AppSystems.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 07.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import Foundation
import Entitas

class TickUpdateSystem : ExecuteSystem, InitialiseSystem {
    
    let ctx : Context
    
    init(ctx : Context) {
        self.ctx = ctx
    }
    
    func execute() {
        
        guard ctx.hasUniqueComponent(PauseComponent.self) == false,
            let currentTick = ctx.uniqueComponent(TickComponent.self)?.value else {
            return
        }
        ctx.setUniqueEntityWith(TickComponent(value: currentTick + 1))
    }
    
    func initialize() {
        ctx.setUniqueEntityWith(TickComponent(value: 0))
    }
}

class ElixirProduceSystem : ReactiveSystem, InitialiseSystem {
    var collector: Collector!
    let ctx : Context
    private let productionFrequency = 3
    private let elixirCapacity : Float = 10
    private let productionStep : Float = 0.01
    
    private(set) var limit: Int = 1
    
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(TickComponent.matcher), changeType: .added)
    }
    func initialize() {
        ctx.setUniqueEntityWith(ElixirComponent(value: 0))
    }
    func execute(input: ArraySlice<Entity>) {
        guard let tick = input.first?.get(TickComponent.self)?.value,
            (tick % UInt64(productionFrequency)) == 0,
            let elixirAmount = ctx.uniqueComponent(ElixirComponent.self)?.value else{
            return
        }
        
        let newAmount = min(elixirCapacity, elixirAmount + productionStep)
        ctx.setUniqueEntityWith(ElixirComponent(value: newAmount))
    }
}

class ElixirConsumeSystem : ReactiveSystem, CleanupSystem {
    var collector: Collector!
    let ctx : Context
    
    init(ctx: Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(ConsumeElixirComponent.matcher), changeType: .added)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard var elixirAmount = ctx.uniqueComponent(ElixirComponent.self)?.value else {
            return
        }
        
        for e in input {
            guard let consumeAmount = e.get(ConsumeElixirComponent.self)?.value,
                Float(consumeAmount) <= elixirAmount else {
                continue
            }
            elixirAmount = max(0, elixirAmount - Float(consumeAmount))
        }
        ctx.setUniqueEntityWith(ElixirComponent(value: elixirAmount))
    }
    
    func cleanup() {
        for e in ctx.entityGroup(ConsumeElixirComponent.matcher) {
            ctx.destroyEntity(e)
        }
    }
}

func createEconomyChain(ctx : Context) -> SystemChain {
    let chain = SystemChain(named: "Economy", contains: [
        TickUpdateSystem(ctx: ctx),
        ElixirProduceSystem(ctx: ctx),
        ElixirConsumeSystem(ctx: ctx)
        ])
    ctx.setUniqueEntityWith(EconomySystemChainComponent(ref: chain))
    return chain
}

class ElixirConsumePersistSystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(ConsumeElixirComponent.matcher), changeType: .added)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard ctx.hasUniqueComponent(PauseComponent.self) == false,
            let tick = ctx.uniqueComponent(TickComponent.self)?.value else {
            return
        }
        var entries = ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values ?? []
        for e in input {
            guard let consumeAmount = e.get(ConsumeElixirComponent.self)?.value else {
                continue
            }
            entries.append(ConsumtionEntry(tick: tick, amount: consumeAmount))
        }
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: entries))
    }
}

class ReplaySystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    var limit: Int = 1
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(JumpIntTimeComponent.matcher), changeType: .added)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard ctx.hasUniqueComponent(PauseComponent.self),
            let economyChain = ctx.uniqueComponent(EconomySystemChainComponent.self)?.ref,
            let targetTick = input.first?.get(JumpIntTimeComponent.self)?.value else {
            return
        }
        let actions = ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values ?? []
        
        economyChain.initialize()
        
        guard targetTick > 0 else { return }
        
        var actionIndex = 0
        
        for tick in 1...targetTick {
            ctx.setUniqueEntityWith(TickComponent(value: UInt64(tick)))
            if actions.count > actionIndex && actions[actionIndex].tick == tick {
                ctx.createEntity().set(ConsumeElixirComponent(value: actions[actionIndex].amount))
                actionIndex += 1
            }
            economyChain.execute()
            economyChain.cleanup()
        }
    }
}

class CleanupConsumtionHistorySystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    var limit: Int = 1
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(PauseComponent.matcher), changeType: .removed)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard ctx.hasUniqueComponent(PauseComponent.self) == false,
                let tick = ctx.uniqueComponent(TickComponent.self)?.value,
                let entries = ctx.uniqueComponent(ConsumtionHistoryComponent.self)?.values else {
            return
        }
        
        ctx.setUniqueEntityWith(ConsumtionHistoryComponent(values: entries.filter({$0.tick <= tick})))
    }
}

func createReplayChain(ctx : Context) -> SystemChain {
    let chain = SystemChain(named: "Replay", contains: [
        ElixirConsumePersistSystem(ctx: ctx),
        ReplaySystem(ctx: ctx),
        CleanupConsumtionHistorySystem(ctx: ctx)
    ])
    return chain
}

class NotifyTickListenersSystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    var limit: Int = 1
    let listeners : Group
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(TickComponent.matcher), changeType: .added)
        listeners = ctx.entityGroup(TickListenerComponent.matcher)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard let tick = input.first?.get(TickComponent.self)?.value else {
            return
        }
        for e in listeners {
            e.get(TickListenerComponent.self)?.ref.tickChanged(tick: tick)
        }
    }
}

class NotifyPauseListenersSystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    var limit: Int = 1
    let listeners : Group
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(PauseComponent.matcher), changeType: .addedAndRemoved)
        listeners = ctx.entityGroup(PauseListenerComponent.matcher)
    }
    
    func execute(input: ArraySlice<Entity>) {
        let paused = ctx.hasUniqueComponent(PauseComponent.self)
        for e in listeners {
            e.get(PauseListenerComponent.self)?.ref.pauseStateChanged(paused: paused)
        }
    }
}

class NotifyElixirListenersSystem : ReactiveSystem {
    var collector: Collector!
    let ctx : Context
    var limit: Int = 1
    let listeners : Group
    init(ctx : Context) {
        self.ctx = ctx
        collector = Collector(group: ctx.entityGroup(ElixirComponent.matcher), changeType: .added)
        listeners = ctx.entityGroup(ElixirListenerComponent.matcher)
    }
    
    func execute(input: ArraySlice<Entity>) {
        guard let elixirAmount = input.first?.get(ElixirComponent.self)?.value else {
            return
        }
        for e in listeners {
            e.get(ElixirListenerComponent.self)?.ref.elixirChanged(amount: elixirAmount)
        }
    }
}

func createNotificationChain(ctx : Context) -> SystemChain {
    let chain = SystemChain(named: "Notification", contains: [
        NotifyTickListenersSystem(ctx: ctx),
        NotifyPauseListenersSystem(ctx: ctx),
        NotifyElixirListenersSystem(ctx: ctx)
    ])
    return chain
}

func createRootChain(ctx : Context) -> SystemChain {
    let chain = SystemChain(named: "Root", contains: [
        createEconomyChain(ctx: ctx),
        createReplayChain(ctx: ctx),
        createNotificationChain(ctx: ctx)
    ])
    return chain
}
