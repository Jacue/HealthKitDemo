//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by Jacue on 2018/5/6.
//  Copyright © 2018年 Jacue. All rights reserved.
//

import UIKit
import HealthKit

class HKViewController: UIViewController {

    var healthStore: HKHealthStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.testMotiuonUsage()
        
        self.addstep(with: 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func testMotiuonUsage() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            print("\"健康\"功能可用")
        }
        
        // 向用户请求授权共享或读取健康数据
        let shareType1 = HKObjectType.quantityType(forIdentifier: .stepCount)
        let shareType2 = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)

        if let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let readType = Set([stepType, distanceType])
            healthStore?.requestAuthorization(toShare: Set.init(arrayLiteral: shareType1!, shareType2!), read: readType, completion: { (success, error) in
                if !success {
                    print("你不允许包来访问这些读/写数据类型。error === %@", error!)
                    return
                }
            })
        }
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        
        let startDate = Date.init(timeInterval: -24*3600, since: Date())
        let endDate = Date()
        let predice = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let calendar = NSCalendar.current
        let anchorComponents = calendar.dateComponents(Set([.year, .month, .day]), from: Date())
        let anchorDate = calendar.date(from: anchorComponents)
        
        var intervalComponent = DateComponents()
        intervalComponent.day = 1
        
        // 创建统计查询对象
        let query = HKStatisticsCollectionQuery.init(quantityType: quantityType!, quantitySamplePredicate: predice, options: HKStatisticsOptions([.cumulativeSum, .separateBySource]), anchorDate: anchorDate!, intervalComponents: intervalComponent)
        query.initialResultsHandler = { (query1, result, error) in
            
            if error != nil {
                print("error: %@",error ?? "")
            } else {
                for statistics in (result?.statistics())! {
                    print("statics: %@,\n sources: %@", statistics, statistics.sources!)
                    for source in statistics.sources! {
                        if source.name == UIDevice.current.name {
                            let step = statistics.sumQuantity(for: source)?.doubleValue(for: HKUnit.count())
                            print("步数为: %f", step!)
                        }
                    }
                }
            }
        }
        
        healthStore?.execute(query)
    }
    
    
    
    private func addstep(with stepNum: Double) {
        
        let stepCorrelationItem = self.stepCorrelation(with: stepNum)
        
        self.healthStore?.save(stepCorrelationItem, withCompletion: { (success, error) in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController.init(title: "提示", message: "添加成功", preferredStyle: .alert)
                    let alertAction = UIAlertAction.init(title: "确定", style: .destructive, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    self.testMotiuonUsage()
                } else {
                    print("error: %@",error!)
                    let alert = UIAlertController.init(title: "提示", message: "添加失败", preferredStyle: .alert)
                    let alertAction = UIAlertAction.init(title: "确定", style: .destructive, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

    // 获取HKQuantitySample数据模型
    private func stepCorrelation(with stepNum: Double) -> HKQuantitySample {
        let endDate = Date()
        let startDate = Date.init(timeInterval: -300, since: endDate)
        
        let stepQuantityConsumed = HKQuantity.init(unit: HKUnit.meter(), doubleValue: stepNum)
        let stepConsumedType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        
        return HKQuantitySample.init(type: stepConsumedType!, quantity: stepQuantityConsumed, start: startDate, end: endDate)
    }
    
    
}

