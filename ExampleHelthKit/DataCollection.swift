//
//  DataCollection.swift
//  ExampleHelthKit
//
//  Created by S-wayMock2 on 2021/07/29.
//

import SwiftUI
import HealthKit

struct DataCollection: View {
    @State var stepValue = "0歩"
    @State var readDate = 0
    
    let healthStore = HKHealthStore()
    // MARK: - メソッド群
    // 使用許可の確認
    private func requestAuth() {
        let types = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!)
        healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
            if let error = error {
                print(error)
            } else {
                print(success ? "OK" : "NG")
            }
        }
        
    }
    
    // データ取得メソッド
    private func readHeartRateData() {
        // クエリに必要なデータ
        let typeOfHeartRate = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -readDate, to: today)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: [])
        
        // クエリ
        let staticsQuery = HKStatisticsQuery(quantityType: typeOfHeartRate, quantitySamplePredicate: predicate, options: []) { (query, result, error) in
            if let error = error {
                print(error)
                stepValue = "\(readDate)日間: 0歩"
                return
            }
            
            guard let step = result?.sumQuantity() else { return }
            
            // 「100 count」を「100歩」にする
            let stepText = "\(step)".replacingOccurrences(of: " count", with: "歩")
            
            DispatchQueue.main.async {
                self.stepValue = "\(readDate)日間: \(stepText)"
            }
            
        }
        healthStore.execute(staticsQuery)
        
    }
    
    // MARK: - ビュー
    var body: some View {
        // 縦にViewを並べる
        VStack() {
            
            HStack {
                Spacer()
                Button("許可") {
                    requestAuth()
                }
                .frame(width: 100, height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding()
            }
            Spacer()
            
            VStack(spacing: 0) {
                HStack {
                    Text("何日分の歩数を出しますか")
                        .padding(.leading)
                    Spacer()
                }
                
                Picker("", selection: $readDate) {
                    ForEach(0..<32) { num in
                        Text("\(num)")
                    }
                }
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 60)
                .padding(.top, -50)
                
            }
            Button("取得") {
                readHeartRateData()
            }
            .frame(width: 150, height: 50)
            .background(Color.pink)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Text(stepValue)
                .font(.largeTitle)
                .padding([.bottom,.top])
            
            Spacer()
            // ボタンの作成(フラグを使って表示されるテキストを変える)
            
        }
    }
}

struct DataCollection_Previews: PreviewProvider {
    static var previews: some View {
        DataCollection()
    }
}
