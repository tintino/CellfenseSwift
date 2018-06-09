//
//  LevelsViewController.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 23/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import Foundation
import UIKit

class  LevelsViewController: UIViewController,
                             UICollectionViewDataSource,
                             UICollectionViewDelegate,
                             XMLParserDelegate {

    @IBOutlet weak var levelsCollectionView: UICollectionView!

    fileprivate let reuseIdentifier = "LevelCell"
    var levels = [Level]()
    //Parse xml aux vars
    var count = 0
    var currentEnemies = [Enemy]()
    var currentLevelName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        var parser: XMLParser?
        let path = Bundle.main.path(forResource: "levels", ofType: "xml")
        if path != nil {
            parser = XMLParser(contentsOf: NSURL(fileURLWithPath: path!) as URL)
        } else {
            NSLog("Failed to find MyFile.xml")
        }

        if parser != nil {
            // Do stuff with the parser here.
            parser?.delegate = self
            parser?.parse()

        }
        self.levelsCollectionView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameViewController"{
            //goGame
            if let toGameViewController = segue.destination as? GameViewController {
                if let selectedCell = sender as? LevelCollectionCell {
                    toGameViewController.levelToLoad = selectedCell.level
                }
            }
        }
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {

        if elementName == "string-array"{
            self.currentLevelName = attributeDict["name"]!
            self.count = 1
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //NSLog("foundCharacters %@", string)

        let test = String(string.characters.filter { !" \n\t\r".characters.contains($0) })

        if test == ""{
            return
        }
        if self.count == 1 {

            //if string == "spider" {
            self.currentEnemies.append(Enemy(type: EnemyType.SPIDER)!)
            //}

            self.count = 2
        } else if count == 2 {

            let currentEnemy = self.currentEnemies.last!
            currentEnemy.col = Int(string)!
            self.count = 3

        } else if count == 3 {
            let currentEnemy = self.currentEnemies.last!
            currentEnemy.row = Int(string)!
            self.count = 4
        }

    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //NSLog("didEndElement %@", elementName)

        if elementName == "string-array"{

            let newLevel = Level()
            newLevel.enemies = currentEnemies
            newLevel.name = self.currentLevelName

            self.levels.append(newLevel)
            self.currentEnemies = [Enemy]()
            self.count = 0
        } else if (elementName == "item" && self.count == 4) {
            self.count = 1
        }

    }

    // MARK: - XMLParserDelegateUICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.levels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                         for: indexPath)
        if let levelCell = cell as? LevelCollectionCell {
            levelCell.configureCell(level: self.levels[indexPath.row])
        }
        return cell

    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
