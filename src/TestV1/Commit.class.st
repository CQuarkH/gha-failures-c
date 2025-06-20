Class {
	#name : 'Commit',
	#superclass : 'Object',
	#instVars : [
		'id',
		'treeId',
		'message',
		'timestamp',
		'authorName',
		'commiterName'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'creation' }
Commit class >> fromDictionary: dict [
	^ self new
		 id:       ( dict at: 'id');
		 treeId:   ( dict at: 'tree_id');
		 message:  ( dict at: 'message');
		 timestamp: ((dict at: 'timestamp') asDateAndTime);
		 authorName: ((dict at: 'author') at: 'name');
		 commiterName: ((dict at: 'committer') at: 'name');
		 yourself .
]

{ #category : 'accessing' }
Commit >> authorName: aString [
	authorName := aString
]

{ #category : 'accessing' }
Commit >> commiterName: aString [
	commiterName := aString
]

{ #category : 'accessing' }
Commit >> id: anInteger [
	id:= anInteger 
]

{ #category : 'accessing' }
Commit >> message: aString [
	message:= aString
]

{ #category : 'accessing' }
Commit >> timestamp: aString [
	timestamp:= aString
]

{ #category : 'accessing' }
Commit >> treeId: anInteger [
	treeId:= anInteger 
]
