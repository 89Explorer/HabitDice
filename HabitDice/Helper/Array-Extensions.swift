//
//  Array-Extensions.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/31/26.
//

import Foundation


extension Array {
    
    // 배열을 지정된 사이즈만큼씩 덩어리(Chunk)로 나눕니다.
    public func chunked(into size: Int) -> [[Element]] {
        
        // stride를 사용하여 0부터 배열 끝까지 size만큼 건너뛰며 인덱스 생성
        return stride(from: 0, to: count, by: size).map {
            
            // 안전하게 범위를 지정하여 ArraySlice를 생성 후 Array로 변환
            Array(self[$0 ..< Swift.min($0 + size, count)])
            
        }
        
    }
    
}
