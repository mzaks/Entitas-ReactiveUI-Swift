//
//  System.swift
//  Entitas-ReactiveUI-Swift
//
//  Created by Maxim Zaks on 07.12.16.
//  Copyright © 2016 Maxim Zaks. All rights reserved.
//

import Foundation

public protocol ASystem : class {}

public protocol ExecuteSystem : ASystem {
    func execute()
}

public protocol ReactiveSystem : ExecuteSystem {
    var collector : Collector! {get set}
    var limit : Int {get}
    func execute(input : ArraySlice<Entity>)
}

public protocol InitialiseSystem : ASystem {
    func initialize()
}

public protocol CleanupSystem : ASystem {
    func cleanup()
}

public extension ReactiveSystem {
    func execute(){
        if let collector = collector {
            let entities = collector.pull(limit)
            if entities.count > 0 {
                execute(input: entities)
            }
        }
    }
    var limit : Int { return -1 }
}

public class SystemChain : ExecuteSystem, CleanupSystem, InitialiseSystem {
    let name : String
    let initSystems : [InitialiseSystem]
    let continuesSystems : [ExecuteSystem]
    let claenupSystems : [CleanupSystem]
    let precondition : (()->(Bool))?
    
    public init(named name: String, contains systems : [ASystem], withPrecondition precondition : (()->(Bool))? = nil) {
        self.name = name
        self.precondition = precondition
        var iSystems : [InitialiseSystem] = []
        var eSystems : [ExecuteSystem] = []
        var cSystems : [CleanupSystem] = []
        for s in systems {
            if let s = s as? InitialiseSystem {
                iSystems.append(s)
            }
            if let s = s as? ExecuteSystem {
                eSystems.append(s)
            }
            if let s = s as? CleanupSystem {
                cSystems.append(s)
            }
        }
        self.initSystems = iSystems
        self.continuesSystems = eSystems
        self.claenupSystems = cSystems
    }
    
    public func initialize() {
        for s in initSystems {
            s.initialize()
        }
    }
    
    public func execute() {
        if let precondition = precondition, precondition() {
            for s in continuesSystems {
                s.execute()
            }
        } else {
            for s in continuesSystems {
                s.execute()
            }
        }
    }
    
    public func cleanup() {
        for s in claenupSystems {
            s.cleanup()
        }
    }
}
