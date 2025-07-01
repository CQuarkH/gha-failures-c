Class {
	#name : 'GHStep',
	#superclass : 'Object',
	#instVars : [
		'name',
		'status',
		'number',
		'conclusion',
		'startedAt',
		'completedAt',
		'log',
		'workflowCode'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
GHStep class >> fromDictArray: dicts [
    "Dada una colección de diccionarios, devuelve una OrderedCollection de Steps"
    | result |
    result := OrderedCollection new.
    dicts do: [ :dict |
        result add: (self fromDictionary: dict) ].
    ^ result.
]

{ #category : 'creation' }
GHStep class >> fromDictionary: dict [
	^ self new
		name: (dict at: 'name');
		number: (dict at: 'number');
		status: (dict at: 'status');
		conclusion: (dict at: 'conclusion');
		startedAt: ((dict at: 'started_at') asDateAndTime);
		completedAt: ((dict at: 'completed_at') asDateAndTime);
		log: (dict at: 'log_content' ifAbsent: '');
		workflowCode: (dict at: 'workflow_code' ifAbsent: '');
		yourself.
]

{ #category : 'accessing' }
GHStep >> completedAt [
	^ completedAt.
]

{ #category : 'accessing' }
GHStep >> completedAt: aDate [
	completedAt := aDate
]

{ #category : 'accessing' }
GHStep >> conclusion [
	^ conclusion.
]

{ #category : 'accessing' }
GHStep >> conclusion: aString [
	conclusion := aString
]

{ #category : 'accessing' }
GHStep >> log [
	^ log.
]

{ #category : 'accessing' }
GHStep >> log: aString [
	log := aString
]

{ #category : 'accessing' }
GHStep >> name [
	^ name.
]

{ #category : 'accessing' }
GHStep >> name: aString [
	name := aString
]

{ #category : 'accessing' }
GHStep >> number [
	^ number.
]

{ #category : 'accessing' }
GHStep >> number: anInteger [
	number := anInteger
]

{ #category : 'accessing' }
GHStep >> startedAt [
	^ startedAt.
]

{ #category : 'accessing' }
GHStep >> startedAt: aDate [
	startedAt := aDate
]

{ #category : 'accessing' }
GHStep >> status [
	^ status .
]

{ #category : 'accessing' }
GHStep >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GHStep >> workflowCode [
	^ workflowCode .
]

{ #category : 'accessing' }
GHStep >> workflowCode: aString [
	workflowCode := aString
]
