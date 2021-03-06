//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
//: # Multi Part Post
//: You can use `Faro` to send a `multipart/form-data` to a server. To use this, you add the multipart file as a parameter to the `Call`.=
//: *Example*
StubbedFaroURLSession.setup()

let image = UIImage(named: "Tom.jpg")!
let jpeg = UIImageJPEGRepresentation(image, 0.7)!

//: Create a multipart object and add it to the call
let multipart = MultipartFile(parameterName: "image",
                              data: jpeg, mimeType: .jpeg)
let call = Call(path: "queries",
                method: .POST,
                parameter: [.multipart(multipart)])

//: Again provide a fake response:

let service = StubService(call: call)

call.stub(statusCode: 200, data: nil)
service.perform(Service.NoResponseData.self){
    do {
        _ = try $0()
        print("Multipart post succes")
    } catch {
        print(error)
    }
}
//: > We do not have a service to send this request to. So in this case the mock is a bit to rough. We do not realy test if the multipart post is handeled correctly. But you get the idea.

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
