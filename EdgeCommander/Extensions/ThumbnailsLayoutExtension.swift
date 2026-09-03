//
//  ThumbnailsLayoutExtension.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 9/3/26.
//

import Foundation

import EdgeCommonLib

// MARK: - ThumbnailsLayout Extension -
/// 썸네일 레이아웃 종류
public extension ThumbnailsLayout {
    
    /// `Commander.Axis` 셋 프로퍼티
    /// - Note: 커서 키를 포함한 단축키와의 충돌을 막기 위해, 현재 레이아웃에서 사용 가능한 커서 키 방향을 `Commander.Axis` 셋 형태로 반환하는 프로퍼티.
    var commanderAxis: Set<Commander.Axis>? {
        switch self {
        case .horizontal:
            return [.horizontal]
        case .vertical:
            return [.vertical]
        case .collections, .fileIcon:
            return [.horizontal, .vertical]
        default:
            return nil
        }
    }
}
