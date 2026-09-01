//
//  ScrollableExtension.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 9/1/26.
//

import Foundation

import EdgeCommonLib

/// Scrollable.Axis 의 확장
public extension Scrollable.Axis {
    
    /// Commander Axis로 변환
    var commanderAxis: Set<Commander.Axis>? {
        switch self {
        // 전방향
        case .all: return [.horizontal, .vertical]
        // 수평
        case .horizontal: return [.horizontal]
        // 수직
        case .vertical: return [.vertical]
        // 없음
        default: return nil
        }
    }
}
