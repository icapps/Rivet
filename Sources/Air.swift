//
//  Air.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation

/** 
`Air` handles interactions with a model of a specific Type called `Rivet`. 

This class is intentionally stateless.

# Tasks

## Save
`Type` is converted to JSON and send as the body of a request
## Retrieve

You can fetch a single instance or an array of objects

## Handle response via `Response`
The response controllers does the actual parsing. In theory you can parse any kind of reponse, for now we only support JSON.

## Pass errors to the `Mitigator`
Any type can decide to handle error in a specific way that is suited for that `Type` by conforming to protocol `Mitigatable`.

You can inspect how error handling is expected to behave by looking at `MitigatorDefaultSpec` in the tests of the Example project.

# Mocking

You can also mock this class via its Type. Take a look at the `GameScoreTest` in example to know how.

*/
open class Air {

	//MARK: - Save
/**
 Save a single item of Type `Rivet`.  Closures are called on a background queue!
	
	- parameter entity: The `Rivet` is converted to JSON and send to the server.
	- parameter session : Default NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()
	- parameter responseController: default is  Response = Response(),
	- parameter succeed: Closure is called when service request successfully returns - !__Called on a background queue___!
	- parameter fail: Optional Closure called when something in the response fails. - !__Called on a background queue___!
	- throws : Errors related to the request construction.
*/
	open  class func post <Rivet: Rivetable>  (_ entity: Rivet,
	                         session: URLSession = URLSession(configuration:URLSessionConfiguration.default),
	                         responseController: Response = Response(),
	                         succeed:@escaping (_ response: Rivet)->(), fail:((ResponseError) ->())? = nil) throws {
		let environment = Rivet.environment()

		guard !environment.shouldMock() else {
			succeed(entity)
			return
		}

		let request = environment.request

		try Rivet.requestMitigator().mitigate {
			if let dict = try entity.toDictionary() {
				request.httpBody = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
			}
			request.httpMethod = "POST"
			performAsychonousRequest(request as URLRequest, session: session, responseController: responseController, succeed: succeed, fail: fail)
		}
	}


	//MARK: - Fetch
	/**
 Retreive all items of `Type`. Closures are called on a background queue!
	
	- parameter session : Default NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()
	- parameter responseController: default is  Response = Response(),
	- parameter succeed: Closure is called when service request successfully returns - !__Called on a background queue___!
	- parameter fail: Closure called when something in the response fails. - !__Called on a background queue___!
	- throws : Errors related to the request construction.
	*/
	open class func fetch<Rivet: Rivetable> (_ session: URLSession = URLSession(configuration:URLSessionConfiguration.default),
	                     responseController: Response = Response(),
	                     succeed:@escaping (_ response: [Rivet])->(), fail:((ResponseError)->())? = nil) throws{
		let environment = Rivet.environment()
		let mockUrl = "\(environment.request.httpMethod)_\(Rivet.contextPath())"
		environment.request.httpMethod = "GET"

		try mockOrPerform(mockUrl, request: environment.request as URLRequest,
		                  environment: environment, responseController: responseController, session: session,
		                  succeed: succeed, fail: fail)
	}
	
	/**
 Retreive a single item of `Rivet`. Closures are called on a background queue!
	
	- parameter uniqueId: Something that uniquely defines the object you are asking for of `Rivet`
	- parameter succeed: Closure is called when service request successfully returns. Closures are called on a background queue!
	- parameter fail: Closure called when something in the response fails.
	- throws : Errors related to the request construction.
	*/
	open class func fetchWithUniqueId <Rivet: Rivetable> (_ uniqueId:String, session: URLSession = URLSession(configuration:URLSessionConfiguration.default),
	                      responseController: Response = Response(),
	                      succeed:@escaping (_ response: Rivet)->(), fail:((ResponseError)->())? = nil) throws{
		let environment = Rivet.environment()
		let request = environment.request
		request.httpMethod = "GET"
		if let _ = request.url {
			request.url = request.url!.appendingPathComponent(uniqueId)
		}

		let mockUrl = "\(environment.request.httpMethod)_\(Rivet.contextPath())_\(uniqueId)"
		try mockOrPerform(mockUrl, request: request as URLRequest,
		                  environment: environment, responseController: responseController, session: session,
		                  succeed: succeed, fail: fail)
	}

	fileprivate class func mockOrPerform <Rivet: Rivetable> (_ mockUrl: String, request: URLRequest,
	                                  environment: Environment & Mockable,
	                                  responseController: Response, session: URLSession,
	                                  succeed:@escaping (_ response: [Rivet])->(), fail:((ResponseError)->())?) throws {
		guard !environment.shouldMock() else {
			try mockDataFromUrl(mockUrl, transformController: Rivet.transform(), responseController: responseController, succeed: succeed, fail: fail)
			return
		}

		performAsychonousRequest(request, session: session, responseController: responseController, succeed: succeed, fail: fail)
	}

	fileprivate class func mockOrPerform <Rivet: Rivetable> (_ mockUrl: String, request: URLRequest,
	                                  environment: Environment & Mockable,
	                                  responseController: Response, session: URLSession,
	                                  succeed:(_ response: Rivet)->(), fail: ((ResponseError)-> Void)?) throws {
		guard !environment.shouldMock() else {
//			try mockDataFromUrl(mockUrl, transformController: Rivet.transform(), responseController: responseController, succeed: succeed, fail: fail)
			return
		}

//		performAsychonousRequest(request, session: session, responseController: responseController, succeed: succeed, fail: fail)
	}

	fileprivate class func mockDataFromUrl <Rivet: Rivetable> (_ url: String, transformController: TransformJSON, responseController: Response,
	                                    succeed:@escaping (_ response: [Rivet])->(), fail:((ResponseError)->())? ) throws {
		try Rivet.requestMitigator().mitigate {
			let data = try dataAtUrl(url, transformController: transformController)
			responseController.respond(data, succeed: succeed, fail: fail)
		}
	}

	fileprivate class func mockDataFromUrl <Rivet: Rivetable> (_ url: String, transformController: TransformJSON, responseController: Response,
	                                    succeed:@escaping (_ response: Rivet)->(), fail:((ResponseError)->())?) throws {
		try Rivet.requestMitigator().mitigate {
			let data = try dataAtUrl(url, transformController: transformController)
			responseController.respond(data, succeed: succeed, fail: fail)
		}
	}
	
	fileprivate class func performAsychonousRequest<Rivet: Rivetable> (_ request: URLRequest,
	                                            session: URLSession, responseController: Response,
	                                            succeed:@escaping (_ response: Rivet)->(), fail:((ResponseError)->())? = nil ) {
		let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
			responseController.respond(data, urlResponse: response, error: error, succeed: succeed, fail: fail)
		})

		task.resume()
	}

	fileprivate class func performAsychonousRequest<Rivet: Rivetable> (_ request: URLRequest,
	                                            session: URLSession, responseController: Response,
	                                            succeed:@escaping (_ response: [Rivet])->(), fail:((ResponseError)->())? = nil ) {
		let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
			responseController.respond(data, urlResponse: response, error: error, succeed: succeed, fail: fail)
		})

		task.resume()
	}
}

func dataAtUrl(_ url: String, transformController: TransformJSON) throws -> Data?  {
	if let fileURL = Bundle.main.url(forResource: url, withExtension: transformController.type().rawValue) {
		return  (try? Data(contentsOf: fileURL))
	}else {
		throw ResponseError.invalidResponseData(data: nil)
	}
}