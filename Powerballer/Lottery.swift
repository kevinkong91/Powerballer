//
//  Lottery.swift
//  Marina
//
//  Created by Kevin Kong on 1/12/15.
//  Copyright © 2015 Kevin Kong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct Drawing {
    let date: NSDate
    let numbers: String
}


// Lottery Lookup
class Lottery {
    
    
    // NYC Gov Data
    
    class func fetchPreviousWinners(completion: ((drawings: [Drawing]?) -> Void)) {
        
        
        // 1 - API Data Request
        
        Alamofire.request(.GET, "https://data.ny.gov/api/views/d6yy-54nr/rows.json?accessType=DOWNLOAD")
            .validate()
            .responseJSON { (_, _, result) in
                
                switch result {
                case .Success:
                    
                    // 2 - Get JSON object
                    if let jsonObject:AnyObject = result.value {
                        
                        
                        let json = JSON(jsonObject)
                        
                        
                        // 3 - Parse JSON
                        let drawings = Lottery.parseDrawingsFromJSON(json)
                        
                        // 4 - return Drawing obj
                        completion(drawings: drawings)
                        
                        
                    }
                    
                    
                case .Failure(_):
                    completion(drawings: nil)
                }
                
        }
        
        
    }
    
    
    // Parse JSON -
    
    class func parseDrawingsFromJSON(json: JSON) -> [Drawing] {
        
        var drawingsObjects = [Drawing]()
        let drawingsArray = json["data"].array!
        
        // Only the 25 most recent drawings
        for drawing in drawingsArray[0..<25] {
            let dateString = drawing[8].stringValue
            let numbers = drawing[9].stringValue
            
            
            // Formatted date
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            var dateToAdd = NSDate()
            
            if let date = formatter.dateFromString(dateString) {
                dateToAdd = date
            }

            
            let drawingToAdd = Drawing(date: dateToAdd, numbers: numbers)
            
            drawingsObjects.append(drawingToAdd)
        }
        
        return drawingsObjects
        
    }
    
    

    
    
    
    // Custom crafted API via Kimono, scraping http://www.powerball.com/pb_home.asp
    
    class func fetchJackpotWinnings(completion: ((jackpot: String?, cashValue: String?) -> Void)) {
        
        
        // 1 - API Data Request via Kimono
        
        Alamofire.request(.GET, "https://www.kimonolabs.com/api/5lh3spt2?apikey=koirKBAW9m8Myrg1xwSEao40UOWy22Lt")
            .validate()
            .responseJSON { (_, _, result) in
                
                switch result {
                case .Success:
                    
                    // 2
                    if let jsonObject:AnyObject = result.value {
                        let json = JSON(jsonObject)
                        
                        // 3
                        let jackpot = json["results"]["collection1"][0]["jackpot"].stringValue
                        let cashValue = json["results"]["collection1"][0]["cashValue"].stringValue

                        
                        
                        completion(jackpot: jackpot, cashValue: cashValue)
                        
                    }
                    
                    
                case .Failure(_):
                    completion(jackpot: nil, cashValue: nil)
                }
                
        }
        
        
    }
    
    
    
    
    
}