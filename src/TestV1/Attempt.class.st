Class {
	#name : 'Attempt',
	#superclass : 'Object',
	#instVars : [
		'attemptNumber',
		'startedAt',
		'updatedAt',
		'logs',
		'runId'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
Attempt class >> fromRuns: aRunId runAttempt: anAttemptNumber [
    "Construye el Attempt a partir del runId y el número de intento"
    ^ self new
        runId:         aRunId;
        attemptNumber: anAttemptNumber;
        yourself.
]

{ #category : 'accessing' }
Attempt >> attemptNumber: anInteger [
	attemptNumber := anInteger 
]

{ #category : 'accessing' }
Attempt >> logs: anArray [
	logs := anArray
]

{ #category : 'accessing' }
Attempt >> runId: anInteger [
	runId := anInteger
]

{ #category : 'accessing' }
Attempt >> startedAt: aDate [
	startedAt := aDate
]

{ #category : 'accessing' }
Attempt >> updatedAt: aDate [
	updatedAt := aDate
]
