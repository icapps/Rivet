//
//  CoreData.swift
//  Pods
//
//  Created by Stijn Willems on 20/05/16.
//
//

import Foundation
import CoreData

/**
Fetch a unique entity in core data or nil if no entity can be found. We look for an entity with a unique key where the value can be found in the JSON.

- parameter json: valid json containing a unique value for the `uniqueValueKey
- parameter managedObjectContext: context to fetch in. Be sure to provide a context that can be used on the current queue.
- parameter entityName: Name of the entity to fetch data for.
- parameter uniqueValueKey: key to use to validate uniqueness.
*/

public func fetchInCoreDataFromJSON<T: NSManagedObject>(_ json: [String: Any], managedObjectContext: NSManagedObjectContext, entityName: String, uniqueValueKey: String) throws -> T? {

	guard let value = json[uniqueValueKey] as? String else {
		throw MapError.jsonHasNoUniqueValue(json: json)
	}

	let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
	let predicate = NSPredicate(format: "uniqueValue == %@", value)
	fetchrequest.predicate = predicate

	if let entities = try managedObjectContext.fetch(fetchrequest) as? [T] {
		if !entities.isEmpty && entities.count == 1, let firstEntity = entities.first {
			return firstEntity
		}else if entities.count > 1  {
			throw MapError.enityShouldBeUniqueForJSON(json: json, typeName: "\(T.self)")
		}else {
			return nil
		}
	}

	return nil
}