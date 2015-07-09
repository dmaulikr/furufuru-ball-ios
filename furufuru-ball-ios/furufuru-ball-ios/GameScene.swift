//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene ,SKPhysicsContactDelegate{
    let categoryA: UInt32 = 0x1 << 0
    var myMotionManager: CMMotionManager?
    var i:Int = 0
    var flag = true
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.contactTestBitMask = categoryA
        var radius = 40 as CGFloat
        /* Setup your scene here */
        let Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle.position = CGPointMake(self.frame.midX, self.frame.midY)
        Circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        Circle.physicsBody?.contactTestBitMask = categoryA
        //重力はfalseにしてあります。
        Circle.physicsBody?.affectedByGravity = false
        
        myMotionManager = CMMotionManager()
        let interval = 0.03
        //反発力
        let resilience = 0.9
        // 更新周期を設定.
        myMotionManager!.accelerometerUpdateInterval = interval
        var vp_x = 0.0
        var vp_y = 0.0
        
        // 加速度の取得を開始.
        myMotionManager!.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData!, error:NSError!) -> Void in
            //加速の計算
            var v_x = vp_x + accelerometerData.acceleration.x * 1000 * interval
            var v_y = vp_y + accelerometerData.acceleration.y * 1000 * interval
            vp_x = v_x
            vp_y = v_y
            //壁に当たったか判定
            if ((Circle.position.x + CGFloat(v_x*interval)) < self.frame.maxX-radius && (Circle.position.x + CGFloat(v_x*interval)) > self.frame.minX+radius || !self.flag) {
                Circle.position.x = Circle.position.x + CGFloat(v_x*interval)
            } else {
                //壁に当たった時の反発
                Circle.position.x = Circle.position.x + CGFloat(v_x*interval)
                vp_x = -vp_x * resilience
            }
            if ((Circle.position.y + CGFloat(v_y*interval)) < self.frame.maxY-radius && (Circle.position.y + CGFloat(v_y*interval)) > self.frame.minY+radius || !self.flag) {
                Circle.position.y = Circle.position.y + CGFloat(v_y*interval)
            } else {
                Circle.position.y = Circle.position.y + CGFloat(v_y*interval)
                vp_y = -vp_y * resilience
            }
        })
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle.fillColor = UIColor.greenColor()
        self.addChild(Circle)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func didBeginContact(contact: SKPhysicsContact) {
        println("didBeginContact\(i)")
        i++
        if (i>3) {
            self.physicsBody = nil
            flag = false
        }
    }
}
