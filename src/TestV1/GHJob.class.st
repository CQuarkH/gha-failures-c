Class {
	#name : 'GHJob',
	#superclass : 'Object',
	#instVars : [
		'id',
		'nodeId',
		'name',
		'status',
		'conclusion',
		'createdAt',
		'startedAt',
		'completedAt',
		'url',
		'htmlUrl',
		'runnerName',
		'runnerGroupName',
		'runAttempt',
		'labels',
		'steps',
		'fullLog'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
GHJob class >> fromDictArray: dicts [
    "Dada una colección de diccionarios, devuelve una OrderedCollection de GHJob"
    | result |
    result := OrderedCollection new.
    dicts do: [ :dict |
        result add: (self fromDictionary: dict) ].
    ^ result.
]

{ #category : 'creation' }
GHJob class >> fromDictionary: dict [
    ^ self new
        id:               (dict at: 'id' ifAbsent: [ dict at: #id ]);
        nodeId:           (dict at: 'node_id' ifAbsent: [ dict at: #nodeId ]);
        name:             (dict at: 'name' ifAbsent: [ dict at: #name ]);
        status:           (dict at: 'status' ifAbsent: [ dict at: #status ]);
        conclusion:       (dict at: 'conclusion' ifAbsent: [ dict at: #conclusion ]);
        createdAt:        ((dict at: 'created_at') asDateAndTime);
        startedAt:        ((dict at: 'started_at') asDateAndTime);
        completedAt:      ((dict at: 'completed_at') asDateAndTime);
        url:              (dict at: 'url' ifAbsent: [ dict at: #url ]);
        htmlUrl:          (dict at: 'html_url' ifAbsent: [ dict at: #htmlUrl ]);
        runnerName:       (dict at: 'runner_name' ifAbsent: [ dict at: #runnerName ]);
        labels:           (dict at: 'labels');
		  steps: 				 (GHStep fromDictArray: (dict at: 'steps'));
		  fullLog:          (dict at: 'log' ifAbsent: '');
		  runAttempt:       (dict at: 'run_attempt');
        yourself.
]

{ #category : 'accessing' }
GHJob >> completedAt [
	^ completedAt 
]

{ #category : 'accessing' }
GHJob >> completedAt: aDate [
	completedAt := aDate
]

{ #category : 'accessing' }
GHJob >> conclusion [
	^ conclusion.
]

{ #category : 'accessing' }
GHJob >> conclusion: aString [
	conclusion := aString
]

{ #category : 'accessing' }
GHJob >> createdAt: aDate [
	createdAt := aDate
]

{ #category : 'public' }
GHJob >> executionTime [
	^ (self completedAt - self startedAt) / 1 second
]

{ #category : 'accessing' }
GHJob >> fullLog: aString [
	fullLog := aString
]

{ #category : 'accessing' }
GHJob >> htmlUrl: aString [
	htmlUrl := aString
]

{ #category : 'accessing' }
GHJob >> id: anInteger [
	id := anInteger 
]

{ #category : 'accessing' }
GHJob >> labels: aStringCol [
	labels := aStringCol
]

{ #category : 'accessing' }
GHJob >> name [
	^ name.
]

{ #category : 'accessing' }
GHJob >> name: aString [
	name := aString
]

{ #category : 'accessing' }
GHJob >> nodeId: anInteger [
	nodeId := anInteger 
]

{ #category : 'accessing' }
GHJob >> runAttempt [ 
	^ runAttempt .
]

{ #category : 'accessing' }
GHJob >> runAttempt: aInteger [
	runAttempt := aInteger 
]

{ #category : 'accessing' }
GHJob >> runnerName: aString [
	runnerName := aString
]

{ #category : 'accessing' }
GHJob >> startedAt [
	^ startedAt 
]

{ #category : 'accessing' }
GHJob >> startedAt: aDate [
	startedAt := aDate
]

{ #category : 'accessing' }
GHJob >> status [
	^ status
]

{ #category : 'accessing' }
GHJob >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GHJob >> steps [
	^ steps.
]

{ #category : 'accessing' }
GHJob >> steps: aCollection [
	steps := aCollection 
]

{ #category : 'accessing' }
GHJob >> url: aString [
	url := aString
]
