Class {
	#name : 'GHRunAttempt',
	#superclass : 'Object',
	#instVars : [
		'runAttempt',
		'status',
		'conclusion',
		'updatedAt',
		'runStartedAt',
		'jobs'
	],
	#category : 'GHFailures',
	#package : 'GHFailures'
}

{ #category : 'instance creation' }
GHRunAttempt class >> fromDictArray: dictArray [
    "Devuelve una OrderedCollection de GHRunAttempt instanciados
     a partir de un Array de diccionarios JSON."
    | attempts |
    attempts := OrderedCollection new.
    dictArray do: [:eachDict |
        attempts add: (self fromDictionary: eachDict)
    ].
    ^ attempts
]

{ #category : 'instance creation' }
GHRunAttempt class >> fromDictionary: dict [
    ^ self new
        runAttempt:     (dict at: 'run_attempt');
        status:         (dict at: 'status');
        conclusion:     (dict at: 'conclusion');
        updatedAt:      ((dict at: 'updated_at') asDateAndTime );
        runStartedAt:   ((dict at: 'run_started_at') asDateAndTime );
        jobs:           (GHJob fromDictArray: (dict at: 'jobs'));
        yourself.
	
]

{ #category : 'accessing' }
GHRunAttempt >> conclusion [
	^ conclusion.
]

{ #category : 'accessing' }
GHRunAttempt >> conclusion: aString [
	conclusion := aString
]

{ #category : 'public' }
GHRunAttempt >> getAttemptExecutionTime [
    | startTime endTime |
    
    startTime := self runStartedAt.
    endTime := self updatedAt.
    
    (startTime isNil or: [ endTime isNil ]) ifTrue: [ ^ 0 ].
    
    "Calcular diferencia en segundos"
    ^ (endTime asSeconds - startTime asSeconds) max: 0
]

{ #category : 'public' }
GHRunAttempt >> getExecutionTime [
    | startTime endTime |
    
    startTime := self runStartedAt.
    endTime := self updatedAt.
    
    (startTime isNil or: [ endTime isNil ]) ifTrue: [ ^ 0 ].
    
    "Calcular diferencia en segundos"
    ^ (endTime asSeconds - startTime asSeconds) max: 0
]

{ #category : 'accessing' }
GHRunAttempt >> jobs [
	^ jobs.
]

{ #category : 'accessing' }
GHRunAttempt >> jobs: aCollection [
	jobs := aCollection
]

{ #category : 'accessing' }
GHRunAttempt >> runAttempt [
	^ runAttempt .
]

{ #category : 'accessing' }
GHRunAttempt >> runAttempt: anInteger [
	runAttempt := anInteger
]

{ #category : 'accessing' }
GHRunAttempt >> runStartedAt [
	^ runStartedAt .
]

{ #category : 'accessing' }
GHRunAttempt >> runStartedAt: aDate [
	runStartedAt := aDate
]

{ #category : 'accessing' }
GHRunAttempt >> status [
	^ status .
]

{ #category : 'accessing' }
GHRunAttempt >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GHRunAttempt >> updatedAt [
	^ updatedAt .
]

{ #category : 'accessing' }
GHRunAttempt >> updatedAt: aDate [
	updatedAt := aDate
]
