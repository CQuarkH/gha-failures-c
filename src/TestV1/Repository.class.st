Class {
	#name : 'Repository',
	#superclass : 'Object',
	#instVars : [
		'id',
		'fullName',
		'description',
		'owner',
		'fork',
		'url'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
Repository class >> fromDictionary: dict [
	^ self new
		 id: ( dict at: 'id');
		 fullName: (dict at: 'full_name');
		 owner: (Actor fromDictionary: (dict at: 'owner'));
		 url: (dict at: 'url');
		 fork: (dict at: 'fork' ifAbsent: [ false ]);
		 yourself .
        
]

{ #category : 'accessing' }
Repository >> description: aString [
	description := aString
]

{ #category : 'accessing' }
Repository >> fork: aBoolean [
	fork := aBoolean
]

{ #category : 'accessing' }
Repository >> fullName: aString [
	fullName := aString
]

{ #category : 'accessing' }
Repository >> id: anInteger [
	id := anInteger 
]

{ #category : 'accessing' }
Repository >> owner: anActor [
	owner := anActor
]

{ #category : 'accessing' }
Repository >> url: aString [
	url := aString
]
