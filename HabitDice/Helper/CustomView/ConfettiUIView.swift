//
//  ConfettiUIView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/21/26.
//

import SwiftUI
import UIKit

// MARK: - 1. UIKit 기반의 파티클 뷰 (UIView)
class ConfettiUIView: UIView {
    
    // 파티클 생성기(Layer) 설정
    override class var layerClass: AnyClass {
        return CAEmitterLayer.self
    }
    
    private var emitterLayer: CAEmitterLayer {
        return layer as! CAEmitterLayer
    }
    
    // 뷰가 화면에 그려질 때 폭죽 시작
    override func layoutSubviews() {
        super.layoutSubviews()
        setupEmitter()
        createConfetti()
        
        // 5초 뒤에 스스로 멈추게 함 (메모리 관리)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.emitterLayer.birthRate = 0
        }
    }
    
    // 파티클 레이어의 기본 틀 설정 (방출 위치, 모양 등)
    private func setupEmitter() {
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: -20) // 화면 위에서 아래로
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: bounds.size.width, height: 1)
        emitterLayer.birthRate = 3.0 // 초기 생성 속도
    }
    
    // 실제 폭죽 알갱이(Cell) 생성 및 디자인
    private func createConfetti() {
        // 다양한 색상 설정
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemIndigo, .systemOrange]
        
        // 각 색상별로 파티클 셀 생성
        let cells = colors.map { color -> CAEmitterCell in
            let cell = CAEmitterCell()
            cell.birthRate = 20 // 초당 생성되는 알갱이 수
            cell.lifetime = 6.0 // 알갱이가 화면에 머무는 시간 (초)
            cell.lifetimeRange = 1.0 // lifetime의 변동폭
            cell.color = color.cgColor
            cell.velocity = 200 // 떨어지는 속도
            cell.velocityRange = 50 // 속도의 변동폭
            cell.emissionLongitude = .pi // 방출 방향 (아래쪽)
            cell.emissionRange = .pi / 4 // 방출 각도의 변동폭 (살짝 퍼지게)
            cell.spin = 2 // 회전 속도
            cell.spinRange = 1 // 회전 속도의 변동폭
            cell.scale = 0.1 // 알갱이 크기
            cell.scaleRange = 0.05 // 크기의 변동폭
            
            // 알갱이 이미지 생성 (흰색 사각형 이미지를 코드로 그리기)
            let imageSize = CGSize(width: 10, height: 10)
            let image = UIGraphicsImageRenderer(size: imageSize).image { ctx in
                color.setFill()
                ctx.fill(CGRect(origin: .zero, size: imageSize))
            }
            cell.contents = image.cgImage // UIKit의 cgImage 사용
            
            return cell
        }
        
        // 레이어에 셀들 주입
        emitterLayer.emitterCells = cells
    }
}

// MARK: - 2. SwiftUI에서 쓸 수 있게 해주는 Wrapper (UIViewRepresentable)
struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> ConfettiUIView {
        // 배경을 투명하게 설정해서 보드판 위에 보이게 함
        let view = ConfettiUIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: ConfettiUIView, context: Context) {
        // 업데이트 로직은 딱히 필요 없음
    }
}

#Preview {
    ConfettiUIView()
}

