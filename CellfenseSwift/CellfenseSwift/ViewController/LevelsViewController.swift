//
//  LevelsViewController.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 23/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import Foundation
import UIKit

class  LevelsViewController: UIViewController {

    @IBOutlet weak var levelsCollectionView: UICollectionView!

    fileprivate let reuseIdentifier = "LevelCell"
    var levels = [Level]()
    //Parse xml aux vars
    var count = 0
    var currentEnemies = [Enemy]()
    var currentLevelName = ""
    var currentResource = ""
    var currentTowers: [TowerType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = Bundle.main.path(forResource: "levels", ofType: "xml"),
           let parser = XMLParser(contentsOf: NSURL(fileURLWithPath: path) as URL) {
                parser.delegate = self
                parser.parse()
        } else {
            print("Failed to find MyFile.xml")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameViewController"{
            if let toGameViewController = segue.destination as? GameViewController {
                if let selectedCell = sender as? LevelCollectionCell {
                    toGameViewController.levelToLoad = selectedCell.level
                }
            }
        }
    }
}

extension LevelsViewController: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {

        if elementName == "string-array" {
            if let levelName = attributeDict["name"],
                let levelResource = attributeDict["resource"],
                let levelTowers = attributeDict["towers"] {
                currentLevelName = levelName
                currentResource = levelResource
                for tower in levelTowers.split(separator: ",") {
                    switch tower {
                    case "tc":
                        currentTowers.append(.TURRET)
                    case "tt":
                        currentTowers.append(.TANK)
                    case "tb":
                        currentTowers.append(.BOMB)
                    default:
                        break
                    }
                }
            }
            count = 1
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let test = String(string.filter { !" \n\t\r".contains($0) })

        guard test != "" else { return }

        if currentLevelName == "Chip" {
            print("Enemy type: \(string)")
        }
        if count == 1 {
            count = 2
            if let type = EnemyType(rawValue: string) {
                switch type {
                case .SPIDER:
                    self.currentEnemies.append(Enemy(type: EnemyType.SPIDER)!)
                case .CATERPILLAR:
                    self.currentEnemies.append(Enemy(type: EnemyType.CATERPILLAR)!)
                case .CHIP:
                    self.currentEnemies.append(Enemy(type: EnemyType.CHIP)!)
                }
            }
        } else if count == 2 {
            let currentEnemy = currentEnemies.last!
            currentEnemy.col = Int(string)!
            count = 3
        } else if count == 3 {
            let currentEnemy = currentEnemies.last!
            currentEnemy.row = Int(string)!
            count = 4
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {

        if elementName == "string-array" {
            let newLevel = Level()
            newLevel.enemies = currentEnemies
            newLevel.name = currentLevelName
            newLevel.towers = currentTowers
            levels.append(newLevel)
            currentEnemies = [Enemy]()
            count = 0
        } else if elementName == "item" && self.count == 4 {
            count = 1
        }
    }
}

extension LevelsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)
        if let levelCell = cell as? LevelCollectionCell {
            levelCell.configureCell(level: levels[indexPath.row])
        }
        return cell
    }
}
