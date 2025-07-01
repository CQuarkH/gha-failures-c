Class {
	#name : 'GHRunner',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'display_title',
		'nodeId',
		'runNumber',
		'event',
		'status',
		'conclusion',
		'workflowId',
		'checkSuiteId',
		'url',
		'htmlUrl',
		'createdAt',
		'updatedAt',
		'runStartedAt',
		'runAttempt',
		'actor',
		'triggeringActor',
		'headCommit',
		'repository',
		'workflow',
		'jobs',
		'logs',
		'attempts'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
GHRunner class >> fromDictionary: dict [
    "Construye un GHRunner a partir de un Dictionary JSON"
    ^ self new
        id:             (dict at: 'id' ifAbsent: [ dict at: #id ]);
        name:           (dict at: 'name' ifAbsent: [ dict at: #name ]);
		  display_title:  (dict at: 'display_title');
        nodeId:         (dict at: 'node_id' ifAbsent: [ dict at: #nodeId ]);
        runNumber:      (dict at: 'run_number' ifAbsent: [ dict at: #runNumber ]);
        event:          (dict at: 'event' ifAbsent: [ dict at: #event ]);
        status:         (dict at: 'status' ifAbsent: [ dict at: #status ]);
        conclusion:     (dict at: 'conclusion' ifAbsent: [ dict at: #conclusion ]);
        workflowId:     (dict at: 'workflow_id' ifAbsent: [ dict at: #workflowId ]);
        checkSuiteId:   (dict at: 'check_suite_id' ifAbsent: [ dict at: #checkSuiteId ]);
        url:            (dict at: 'url' ifAbsent: [ dict at: #url ]);
        htmlUrl:        (dict at: 'html_url' ifAbsent: [ dict at: #htmlUrl ]);
        createdAt:      ((dict at: 'created_at') asDateAndTime);
        updatedAt:      ((dict at: 'updated_at') asDateAndTime );
        runStartedAt:   ((dict at: 'run_started_at') asDateAndTime );
        runAttempt:     (dict at: 'run_attempt' ifAbsent: [ dict at: #runAttempt ]);
        actor:          (Actor fromDictionary: (dict at: 'actor'));
        triggeringActor:(Actor fromDictionary: (dict at: 'triggering_actor'));
        headCommit:     (Commit fromDictionary: (dict at: 'head_commit'));
        repository:     (Repository fromDictionary: (dict at: 'repository'));
        workflow:       (Workflow fromDictionary: (dict at: 'workflow'));
        jobs:           (GHJob fromDictArray: (dict at: 'jobs'));
        "attempts:       (Attempt fromRuns: self id runAttempt: self runAttempt"       
		  yourself.
]

{ #category : 'accessing' }
GHRunner >> actor [
    ^ actor.
]

{ #category : 'accessing' }
GHRunner >> actor: anActor [
    "Sólo asigna si es un Actor (o subclase)"
    (anActor isKindOf: Actor)
        ifTrue: [ actor := anActor ]
        ifFalse: [ self error: 'must be Actor, but received: ', anActor class name ].
]

{ #category : 'accessing' }
GHRunner >> attempts: aCollection [
	attempts := aCollection 
]

{ #category : 'accessing' }
GHRunner >> checkSuiteId: anInteger [
	checkSuiteId := anInteger 
]

{ #category : 'public' }
GHRunner >> conclusion [
    ^ conclusion.
]

{ #category : 'accessing' }
GHRunner >> conclusion: aString [
    conclusion := aString.
]

{ #category : 'public' }
GHRunner >> createdAt [
    ^ createdAt.
]

{ #category : 'accessing' }
GHRunner >> createdAt: aDate [
	createdAt := aDate
]

{ #category : 'public' }
GHRunner >> display_title [
    ^ display_title.
]

{ #category : 'accessing' }
GHRunner >> display_title: aString [
    display_title := aString.
]

{ #category : 'accessing' }
GHRunner >> event: aString [
	event := aString
]

{ #category : 'accessing' }
GHRunner >> headCommit: aCommit [
	headCommit := aCommit
]

{ #category : 'accessing' }
GHRunner >> htmlUrl: aString [
	htmlUrl := aString
]

{ #category : 'accessing' }
GHRunner >> id [
    ^ id.
]

{ #category : 'accessing' }
GHRunner >> id: anInteger [
    id := anInteger.
]

{ #category : 'accessing' }
GHRunner >> jobs [
	^ jobs.
]

{ #category : 'accessing' }
GHRunner >> jobs: aJobCol [
	jobs := aJobCol 
]

{ #category : 'public' }
GHRunner >> name [
    ^ name.
]

{ #category : 'accessing' }
GHRunner >> name: aString [
    name := aString.


]

{ #category : 'accessing' }
GHRunner >> nodeId: anInteger [
	nodeId := anInteger 
]

{ #category : 'accessing' }
GHRunner >> repository: aRepository [
	repository := aRepository 
]

{ #category : 'accessing' }
GHRunner >> runAttempt [
    ^ runAttempt .
]

{ #category : 'accessing' }
GHRunner >> runAttempt: anInteger [
	runAttempt := anInteger
]

{ #category : 'accessing' }
GHRunner >> runNumber: anInteger [
	runNumber := anInteger
]

{ #category : 'accessing' }
GHRunner >> runStartedAt [
	^ runStartedAt .
]

{ #category : 'accessing' }
GHRunner >> runStartedAt: aDate [
	runStartedAt := aDate
]

{ #category : 'public' }
GHRunner >> status [
    ^ status.
]

{ #category : 'accessing' }
GHRunner >> status: aString [
    status := aString.
]

{ #category : 'accessing' }
GHRunner >> triggeringActor: anActor [
    "Sólo asigna si es un Actor (o subclase)"
    (anActor isKindOf: Actor)
        ifTrue: [ triggeringActor := anActor ]
        ifFalse: [ self error: 'must be Actor, but received: ', anActor class name ].
]

{ #category : 'accessing' }
GHRunner >> updatedAt: aDate [
	updatedAt := aDate
]

{ #category : 'accessing' }
GHRunner >> url: aString [
	url := aString
]

{ #category : 'accessing' }
GHRunner >> workflow [
	^ workflow
]

{ #category : 'accessing' }
GHRunner >> workflow: aWorkflow [
	workflow := aWorkflow . 
	aWorkflow addRunner: self.
]

{ #category : 'accessing' }
GHRunner >> workflowId: anInteger [
	workflowId := anInteger 
]
