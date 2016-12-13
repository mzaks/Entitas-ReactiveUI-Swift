//
//  Matcher.swift
//  Entitas
//
//  Created by Maxim Zaks on 21.12.14.
//  Copyright (c) 2014 Maxim Zaks. All rights reserved.
//

public func == (lhs: Matcher, rhs: Matcher) -> Bool {
    return lhs.componentIds == rhs.componentIds && lhs.type == rhs.type
}

/// Matcher is used to identify if an entity has the desired components.
public struct Matcher : Hashable {
    
    public let componentIds : Set<ComponentId>
    public enum MatcherType{
        case all, any
    }
    
    public let type : MatcherType
    
    public static func all(_ componentIds : ComponentId...) -> Matcher {
        return Matcher(componentIds: componentIds, type: .all)
    }
    
    public static func any(_ componentIds : ComponentId...) -> Matcher {
        return Matcher(componentIds: componentIds, type: .any)
    }
    
    init(componentIds : [ComponentId], type : MatcherType) {
        self.componentIds = Set(componentIds)
        self.type = type
    }
    
    public func isMatching(_ entity : Entity) -> Bool {
        switch type {
        case .all : return isAllMatching(entity)
        case .any : return isAnyMatching(entity)
        }
    }
    
    func isAllMatching(_ entity : Entity) -> Bool {
        for cid in componentIds {
            if(!entity.hasComponent(cid)){
                return false
            }
        }
        return true
    }
    
    func isAnyMatching(_ entity : Entity) -> Bool {
        for cid in componentIds {
            if(entity.hasComponent(cid)){
                return true
            }
        }
        return false
    }
    
    public var hashValue: Int {
        get {
            return componentIds.hashValue
        }
    }
    
}
