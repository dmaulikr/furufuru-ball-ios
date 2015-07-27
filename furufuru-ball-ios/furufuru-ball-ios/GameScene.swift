//
//  GameScene.swift
//  furufuru-ball-ios
//
//  Created by 坂野健 on 2015/07/07.
//  Copyright (c) 2015年 坂野健. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SRWebSocketDelegate{
    var myMotionManager: CMMotionManager?
    var Circle: SKShapeNode?
    private var webSocketClient: SRWebSocket?
    var through_flag = true
    
    override func didMoveToView(view: SKView) {
        webSocketConnect()
        
        var radius = 40 as CGFloat
        /* Setup your scene here */
        Circle = SKShapeNode(circleOfRadius: radius)
        // ShapeNodeの座標を指定.
        Circle!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //重力はfalseにしてあります。
        Circle!.physicsBody?.affectedByGravity = false
        
        myMotionManager = CMMotionManager()
        let interval = 0.03
        //反発力
        let resilience = 0.9
        // 更新周期を設定.
        myMotionManager?.deviceMotionUpdateInterval = interval
        var vp_x = 0.0
        var vp_y = 0.0
        
        // 加速度の取得を開始.
        myMotionManager!.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(data: CMDeviceMotion!, error:NSError!) -> Void in
            //ユーザが動いた時の加速度が小さい為8倍する
            var twice = 10.0
            //加速の計算
            var v_x = vp_x + (data.userAcceleration.x * twice + data.gravity.x) * 1000 * interval
            var v_y = vp_y + (data.userAcceleration.y * twice + data.gravity.y) * 1000 * interval
            //速度
            let v = 2000.0
            if (v_x * v_x >= v * v || v_y * v_y >= v * v) {
                self.physicsBody = nil
                vp_x=0;
                vp_y=0;
                v_x=0;
                v_y=0;
                self.through_flag = false
                if (self.isOpen()) {
                let obj: [String:AnyObject] = [
                    "move" : "out"
                ]
                let json = JSON(obj).toString(pretty: true)
                self.webSocketClient?.send(json)
                }
            }
            vp_x = v_x
            vp_y = v_y
            //壁に当たったか判定
            if ((self.Circle!.position.x + CGFloat(v_x*interval)) <= self.frame.maxX-radius && (self.Circle!.position.x + CGFloat(v_x*interval)) >= self.frame.minX+radius || !self.through_flag) {
                self.Circle!.position.x = self.Circle!.position.x + CGFloat(v_x*interval)
            } else {
                //壁に当たった時の反発
                if ((self.Circle!.position.x + CGFloat(v_x * interval)) >= self.frame.minX + radius) {
                    self.Circle!.position.x = self.frame.maxX - radius
                } else {
                    self.Circle!.position.x = self.frame.minX + radius
                }
                vp_x = -vp_x * resilience
           }
            if ((self.Circle!.position.y + CGFloat(v_y*interval)) <= self.frame.maxY-radius && (self.Circle!.position.y + CGFloat(v_y*interval)) >= self.frame.minY+radius || !self.through_flag) {
                self.Circle!.position.y = self.Circle!.position.y + CGFloat(v_y*interval)
            } else {
                if ((self.Circle!.position.y + CGFloat(v_y * interval)) >= self.frame.minY + radius) {
                    self.Circle!.position.y = self.frame.maxY - radius
                } else {
                    self.Circle!.position.y = self.frame.minY + radius
                }
                vp_y = -vp_y * resilience
            }
        })
        
        // ShapeNodeの塗りつぶしの色を指定.
        Circle!.fillColor = UIColor.greenColor()
        self.addChild(Circle!)
        self.backgroundColor = UIColor.blackColor()
    }
    
    private func isOpen() -> Bool {
        if webSocketClient != nil {
            if webSocketClient!.readyState.value == SR_OPEN.value {
                return true
            }
        }
        return false
    }
    
    private func isClosed() -> Bool {
        return !isOpen()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func webSocketConnect() {
        if isClosed() {
        var url = NSURL(string: "ws://furufuru-ball.herokuapp.com")
        var request = NSMutableURLRequest(URL: url!)
        
        webSocketClient = SRWebSocket(URLRequest: request)
        webSocketClient?.delegate = self
        webSocketClient?.open()
        }

    }
    func webSocketDidOpen(webSocket:SRWebSocket){
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!){
       // through_flag = true
       // Circle.physicsBody?.affectedByGravity = false
       // self.myMotionManager?.startDeviceMotionUpdates()
        Circle!.position = CGPointMake(self.frame.midX, self.frame.midY)
        println(message)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.through_flag = true
    }
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError){
        println("error")
    }
}
