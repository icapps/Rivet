
import Quick
import Nimble

import Faro
@testable import Faro_Example

class SerializableObject: Serializable {
    var uuid: String?
}

class SerializeOpereratorsSpec: QuickSpec {

    override func spec() {
        describe("SerializeOpereratorsSpec") {

            it("should serialize to JSON object") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"

                serializedDictionary <-> o1

                let dict = serializedDictionary as! [String: String]

                expect(dict["uuid"]) == o1.uuid
            }

            it("should serialize to JSON array") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"
                let o2 = SerializableObject()
                o2.uuid = "ID2"

                serializedDictionary <-> [o1, o2]

                let dictArray = serializedDictionary as! [[String: String]]

                expect(dictArray.count) == 2
                expect(dictArray.first!["uuid"]) == o1.uuid
                expect(dictArray.last!["uuid"]) == o2.uuid

            }
            
            it("should serialize strings") {
                var serializedType: Any?
                let randomString = "random"
                
                serializedType <-> randomString
                
                let serializedString = serializedType as! String
                
                expect(serializedString) == randomString
            }
            
            it("should serialize integers") {
                var serializedType: Any?
                let randomInt = 1
                
                serializedType <-> randomInt
                
                let serializedInt = serializedType as! Int
                
                expect(serializedInt) == randomInt
            }
            
            it("should serialize booleans") {
                var serializedType: Any?
                let randomBool = true
                
                serializedType <-> randomBool
                
                let serializedBool = serializedType as! Bool
                
                expect(serializedBool) == randomBool
            }
            
            it("should serialize doubles") {
                var serializedType: Any?
                let randomDouble = 2.0
                
                serializedType <-> randomDouble
                
                let serializedDouble = serializedType as! Double
                
                expect(serializedDouble) == randomDouble
            }
        }
    }
    
}
