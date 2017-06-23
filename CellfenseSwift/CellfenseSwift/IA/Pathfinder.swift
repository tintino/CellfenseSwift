//
//  Pathfinder.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 18/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import UIKit

class Pathfinder {
    
    var rows = 0
    var columns = 0
    var walls : [PathfindNode] = []
    
    init?(rows: Int, columns:Int, walls:[PathfindNode]){
        self.rows = rows
        self.columns = columns
        self.walls = walls
    }
    
    func findPath(startPosY: Int, startPosx: Int, destinationPosX: Int, destionationPosY: Int) -> [PathfindNode]? {
    
        if (startPosx == destinationPosX && startPosY == destionationPosY){
            return nil
        }
        
        var xStep : Int?
        var yStep : Int?
        var xNewStep : Int?
        var yNewStep : Int?
        var xCurrent : Int?
        var yCurrent : Int?
        var openList : NSMutableArray = []
        var closedList : NSMutableArray = []
        var currentNode : PathfindNode?
        var aNode : PathfindNode?
        var startNode :PathfindNode?
        
        startNode = PathfindNode(cost: 0, x: startPosx, y: startPosY)
        openList.add(startNode!)
        
        while openList.count > 0 {
            
           // currentNode = self.lowCostIn(array: openList)
            
            if (currentNode?.x == destinationPosX && currentNode?.y == destionationPosY){
                //********** PATH FOUND ***********//
                var resultPath : [PathfindNode]?
                aNode = currentNode
                while (aNode != nil) {
                    resultPath?.append(aNode!)
                    aNode = aNode?.parentNode
                }
                return resultPath
            }
            else{
               // closedList.append(currentNode!)
               // openList.remove
            }
        }
        
        
        
        
        return []
        
    }
    
    
    
    func tileIsBlocked(x: Int, y: Int) -> Bool {
        
        let wallNode = self.nodeInArray(source: self.walls, x: x, y: x)
        
        if (wallNode != nil) {
            return true
        } else {
            return false
        }
    }
    
    func nodeInArray(source: [PathfindNode], x: Int, y: Int) -> PathfindNode? {
        
        //TODO: is faster to do it using iterator enumerator?
        
        for node in source {
            if(node.x == x && node.y == y){
                return node
            }
        }
        return nil
    }
    
    func lowCostIn(array: [PathfindNode]) -> PathfindNode {
        
        var lowest : PathfindNode?        
        var e = array.enumerated().makeIterator();
        
        while let n = e.next()?.element
        {
            if (lowest != nil) {
                lowest = n;
            } else {
                
                if(n.cost < lowest!.cost) {
                    lowest = n;
                }
            }
        }
        return lowest!;
        
    }
    
}
