Class {
	#name : 'Workflow',
	#superclass : 'Object',
	#instVars : [
		'id',
		'nodeId',
		'name',
		'path',
		'state',
		'htmlUrl',
		'createdAt',
		'updatedAt',
		'runners'
	],
	#category : 'GHFailures',
	#package : 'GHFailures'
}

{ #category : 'creation' }
Workflow class >> fromDictionary: dict [
	^ self new
		id: (dict at: 'id');
		nodeId: (dict at: 'node_id');
		name: (dict at: 'name');
		path: (dict at: 'path');
		createdAt: ((dict at: 'created_at') asDateAndTime);
		updatedAt: ((dict at: 'updated_at') asDateAndTime);
		htmlUrl: (dict at: 'html_url');
		state: (dict at: 'state');
		yourself.
	
]

{ #category : 'accessing' }
Workflow >> addRunner: aGHRunner [
	runners add: aGHRunner.
]

{ #category : 'accessing' }
Workflow >> createdAt: aString [
	createdAt := aString 
]

{ #category : 'accessing' }
Workflow >> htmlUrl: aString [
	htmlUrl := aString 
]

{ #category : 'accessing' }
Workflow >> id: anInteger [
	id := anInteger 
]

{ #category : 'initialization' }
Workflow >> initialize [
    super initialize.
    runners := OrderedCollection new.
]

{ #category : 'accessing' }
Workflow >> name [
	^ name
]

{ #category : 'accessing' }
Workflow >> name: aString [
	name := aString 
]

{ #category : 'accessing' }
Workflow >> nodeId: anInteger [
	nodeId := anInteger

]

{ #category : 'accessing' }
Workflow >> path: aString [
	path := aString
]

{ #category : 'accessing' }
Workflow >> runners [
    ^ runners
]

{ #category : 'accessing' }
Workflow >> state: aString [
	state := aString

]

{ #category : 'accessing' }
Workflow >> updatedAt: aString [
	updatedAt := aString 
]
