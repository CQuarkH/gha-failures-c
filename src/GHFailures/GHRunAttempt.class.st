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
GHRunAttempt >> conclusion: aString [
	conclusion := aString
]

{ #category : 'accessing' }
GHRunAttempt >> jobs: aCollection [
	jobs := aCollection
]

{ #category : 'accessing' }
GHRunAttempt >> runAttempt: anInteger [
	runAttempt := anInteger
]

{ #category : 'accessing' }
GHRunAttempt >> runStartedAt: aDate [
	runStartedAt := aDate
]

{ #category : 'accessing' }
GHRunAttempt >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GHRunAttempt >> updatedAt: aDate [
	updatedAt := aDate
]
