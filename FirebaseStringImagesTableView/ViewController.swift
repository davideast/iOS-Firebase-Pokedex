//
//  ViewController.swift
//  FirebaseStringImagesTableView
//
//  Created by deast on 12/22/15.
//  Copyright © 2015 firebase. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
  
  var rootRef: Firebase!
  var pokedexRef: Firebase!
  var pokemonSnaps = [FDataSnapshot]()
  var imageCache = [String: UIImage]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rootRef = Firebase(url: "https://pokedexbase.firebaseio.com/")
    pokedexRef = rootRef.childByAppendingPath("pokedex")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let query = pokedexRef.queryOrderedByKey().queryLimitedToFirst(151)
    query.observeEventType(.Value) { (snap: FDataSnapshot!) in
      
      var items = [FDataSnapshot]()
      for child in snap.children {
        let childSnap = child as! FDataSnapshot
        items.append(childSnap)
      }
      
      self.pokemonSnaps = items
      self.tableView.reloadData()
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PokeCell") as! PokeTableViewCell
    
    let pokeSnap = pokemonSnaps[indexPath.item]
    
    if let pokeImage = imageCache[pokeSnap.key] {
      cell.pokeImage.image = pokeImage
    } else {
      
      let imageRef = rootRef.childByAppendingPath("pokeImages").childByAppendingPath(pokeSnap.key)
      
      imageRef.observeSingleEventOfType(.Value) { (imageSnap: FDataSnapshot!) in
        let base64String = imageSnap.value as! String
        let replaced = base64String.stringByReplacingOccurrencesOfString("data:image/png;base64,", withString: "")
        let decodedData = NSData(base64EncodedString: replaced, options: NSDataBase64DecodingOptions(rawValue: 0))
        
        let image = UIImage(data: decodedData!)
        self.imageCache[imageSnap.key] = image
        
        cell.pokeImage.image = image
      }
    }
    
    return cell
    
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pokemonSnaps.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
}

