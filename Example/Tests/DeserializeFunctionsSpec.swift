import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

            it("should parse generic value from JSON") {
                let uuidKey = "uuid"
                let json = [uuidKey:"some id" as Any]
                let o1 = DeserializableObject(from: ["":""])!
                
                o1.uuid = try! parse(uuidKey, from: json)

                expect(o1.uuid) == json["uuid"] as? String
            }
            
            it("should parse Date from JSON with TimeInterval") {
                let dateKey = "date"
                let dateTimeInterval: TimeInterval = 12345.0
                let json = ["date": dateTimeInterval]
                let o1 = DeserializableObject(from: ["":""])!
                
                o1.date = try! parse(dateKey, from: json)

                let date = Date(timeIntervalSince1970: json["date"]!)
                expect(o1.date) == date
            }
            
            it("should parse Date from JSON with String") {
                let dateKey = "date"
                let dateString = "1994-08-20"
                let json = [dateKey: dateString as Any]
                let o1 = DeserializableObject(from: ["":""])!
                
                o1.date = try! parse(dateKey, from: json, format: "yyyy-MM-dd")

                expect(o1.date).toNot(beNil())
            }
            
            it("should parse generic object from JSON") {
                let json = ["uuid":"some id" as Any]
                var o1 = DeserializableObject(from: ["":""])!
                
                o1 = try! parse(from: json)!

                expect(o1.uuid) == json["uuid"] as! String?
            }
            
            it("should parse generic object arrays from JSON") {
                let json = [["uuid": "id1"],["uuid":"id2"]]
                let o1 = DeserializableObject(from: ["":""])!
                let o2 = DeserializableObject(from: ["":""])!
                var objectArray = [o1, o2]
                
                objectArray = try! parse(from: json)!

                expect(objectArray.count) == 2
                expect(objectArray.first?.uuid) == json.first?["uuid"]
                expect(objectArray.last?.uuid) == json.last?["uuid"]
            }
        }
    }
    
}
