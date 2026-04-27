//
//  HabitReflectionView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/22/26.
//

import SwiftUI
import SwiftData


struct HabitReflectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(HabitRepository.self) var habitRepository
    
    let habit: Habit
    let targetDate: Date
    
    // 선택된 상태값 관리
    @State private var selectedMood: Mood = .happy
    @State private var selectedTagIds: Set<String> = []
    @State private var selectedMemo: String = ""
    
    
    init(habit: Habit, targetDate: Date) {
        self.habit = habit
        self.targetDate = targetDate
        
        // 오늘 날짜의 로그를 찾아 기준 회고 데이터 유무 파익
        let existingLog = habit.logs.first { Calendar.current.isDate($0.date, inSameDayAs: targetDate)}
        
        if let reflect = existingLog?.reflect {
            // 기존 데이터가 있으면 불러오기 (수정모드)
            _selectedMood = State(initialValue: reflect.mood)
            _selectedTagIds = State(initialValue: Set(reflect.tagIds))
            _selectedMemo = State(initialValue: reflect.memo ?? "")
        } else {
            // 없으면 기본값 (신규 작성 모드)
            _selectedMood = State(initialValue: .happy)
            _selectedTagIds = State(initialValue: [])
            _selectedMemo = State(initialValue: "")
        }
    }

    // 포커스 상태를 관리하기 위한 프로퍼티 (View 구조체 상단에 선언)
    @FocusState private var isMemoFocused: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment:.leading, spacing: 8) {
                                                   
                        reflectTitleView
                        reflectHeaderView
                        reflectMoodView
                        reflectTagView
                        reflectMemoView(proxy: proxy)
                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                      
                        VStack(spacing: 8) {
                            Button {
                                // 오늘 다시 지피기 -> 영구적으로 확인 완료 처리
                                // 저장
                                checkAndSave()
                            } label: {
                                Text("오늘, 습관을 기록!")
                                    .font(.system(size: 16))
                                    .fontWeight(.black)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                Color.blue
                                            )
                                            .shadow(color: .orange.opacity(0.30), radius: 8, x: 4, y: 4)
                                    )
                            }
                            
                            Button {
                                // 나중에 볼게요 -> 그냥 닫기만 함 (영구저장 안함)
                                dismiss()
                            } label: {
                                Text("나중에 쓸게요")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .padding(12)
                            }
                        }
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 32)
                }
                .scrollIndicators(.hidden)
            }
            .onTapGesture {
                isMemoFocused = false
            }
        }
    }
    
    private var reflectTitleView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘도 수고 많았어요.👏")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(.label))
            
            Text("잠시 마음을 들여다볼까요?")
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .hSpacing(.leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: 회고 헤더 뷰 (습관 이모지 + 습관 타이틀 + 습관 트리거)
    private var reflectHeaderView: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Color.white.opacity(0.5)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(habit.emoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.label))
                
                Text(habit.selectedTriggerAction ?? "아침에 일어날 때")
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .padding(8)
        .hSpacing(.leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.05))
            //                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            //                .shadow(color: .white.opacity(0.9), radius: 1, x: 0, y: -1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    
    // MARK: 어떻게 느꼈는지 확인하는 뷰
    private var reflectMoodView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘 이 습관, 어떻게 느껴졌어요?")
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(Color(.secondaryLabel))
            
            HStack(alignment: .center) {
                
                ForEach(Mood.allCases, id:\.self) { m in
                    
                    let isSelected = selectedMood == m
                    
                    Button {
                        withAnimation(.snappy) {
                            selectedMood = m
                        }
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Text(m.rawValue)
                                .font(.system(size: 24))
                            Text(m.description)
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                                .foregroundStyle(isSelected ? .blue : Color(.secondaryLabel))
                        }
                        .hSpacing(.center)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.blue : Color.black.opacity(0.1),
                                        lineWidth: isSelected ? 2 : 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    
    // MARK: 왜 그렇게 느꼈는지 확인하는 뷰
    private var reflectTagView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("어떤 점이 그랬나요?")
                    .fontWeight(.black)
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.system(size: 14))
                Text("(복수 선택)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .fontWeight(.light)
                    .font(.system(size: 12))
            }
            
            //let columns = [GridItem(.adaptive(minimum: 140))]
            //let columns = [GridItem(.flexible(minimum: 80, maximum: 160))]
            let item = GridItem(.adaptive(minimum: 100), spacing: 4)
            let columns = Array(repeating: item, count: 2)
            
            // LazyVGrid는 ScrollView에서 사용하지 말자
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(HabitTagData.allTags, id:\.self) { tag in
                    
                    // 선택 여부 확인 (ID 기반 비교가 가장 안전)
                    let isSelected = selectedTagIds.contains(tag.id)
                    
                    Button {
                        withAnimation(.snappy) {
                            if isSelected {
                                // 이미 선택되어 있다면 제거
                                selectedTagIds.remove(tag.id)
                            } else {
                                // 선택되지 않았다면 추가
                                selectedTagIds.insert(tag.id)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(tag.emoji)
                            Text(tag.title)
                                .lineLimit(1) // 텍스트가 길어질 경우 대비
                        }
                        .font(.system(size: 12))
                        .fontWeight(isSelected ? .bold : .medium)
                        .foregroundStyle(isSelected ? .blue : Color(.secondaryLabel))
                        .padding(.vertical, 8)
                        .hSpacing(.center) // 전체 너비 채우기
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.blue : Color.black.opacity(0.1),
                                        lineWidth: isSelected ? 1.5 : 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    
    // MARK: 회고 메모를 남기는 뷰
    private func reflectMemoView(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("한 줄 메모")
                    .fontWeight(.black)
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.system(size: 14))
                Text("(선택)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .fontWeight(.light)
                    .font(.system(size: 12))
            }
            
            // 테두리 색상 결정 로직
            let isActive = isMemoFocused || !selectedMemo.isEmpty
            
            TextEditor(text: $selectedMemo)
                .focused($isMemoFocused)    // 포커스 연결
                .onChange(of: isMemoFocused, { oldValue, newValue in
                    if newValue {
                        scrollToBottom(proxy: proxy)
                    }
                })
                .padding(8)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(.label))
                .font(.system(size: 12))
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .scrollContentBackground(.hidden)    // 배경색 보이게 하기 위함
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isActive ? Color.blue.opacity(0.03) : Color.gray.opacity(0.05))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.blue : Color.gray.opacity(0.3),
                                lineWidth: isActive ? 1.5 : 1.0)
                }
                .animation(.snappy, value: isActive) // 부드러운 전환
            
        }
        
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    
    // MARK: 저장 함수
    private func checkAndSave() {
        // 해당 날짜의 로그 찾기
        guard let todayLog = habit.logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate)}) else {
            print("⚠️ [HabitReflectionView] 해당 날짜의 로그를 찾을 수 없습니다.")
            return
        }
        
        if let existingReflect = todayLog.reflect {
            // [수정 모드] 기존 객체의 값만 변경
            existingReflect.mood = selectedMood
            existingReflect.tagIds = Array(selectedTagIds)
            existingReflect.memo = selectedMemo.isEmpty ? nil : selectedMemo
            print("[HabitReflectionView] 기존 회고 수정 완료")
        } else {
            // [신규 모드] 새 객체 생성 및 연결
            let newReflect = HabitReflect(
                mood: selectedMood,
                tagIds: Array(selectedTagIds),
                memo: selectedMemo.isEmpty ? nil : selectedMemo
            )
            todayLog.reflect = newReflect
            print("[HabitReflectionView] 새 회고 저장 완료")
        }
        // 명시적 저장
        do {
            try habitRepository.context.save()
            dismiss()
            print("[HabitReflectionView] 저장 완료")
        } catch {
            print("⚠️ [HabitReflectionView] 저장 실패: \(error)")
        }
    }

    // MARK: 키보드 위치를 변경
    private func scrollToBottom(proxy: ScrollViewProxy) {
        // 키보드가 올라오는 시간을 고려 약간의 지연을 통해 확실히 스크롤
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
            withAnimation {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
        }
    }
}


#Preview {
    HabitReflectionView(habit: Habit(
        title: "물 100ml 마시기",
        emoji: "💧",
        createdAt: .init(),
        isArchived: false,
        isRepeatOn: false,
        repeatDays: [1],
        isAlarmOn: false,
        logs: []),
                        targetDate: .init()
    )
    .sampleDataContainer()
}
