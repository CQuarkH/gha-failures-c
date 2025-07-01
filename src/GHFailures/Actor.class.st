Class {
	#name : 'Actor',
	#superclass : 'Object',
	#instVars : [
		'id',
		'login',
		'url',
		'type'
	],
	#category : 'GHFailures',
	#package : 'GHFailures'
}

{ #category : 'creation' }
Actor class >> fromDictionary: dict [
	"comment stating purpose of class-side method"
	"scope: class-variables  &  class-instance-variables"
	^ self new
		 id: 			( dict at: 'id' ifAbsent: [dict at: #id]);
		 login:     ( dict at: 'login' ifAbsent: [dict at: #login]);
		 url:       ( dict at: 'url' ifAbsent: [dict at: #url]);
		 type:      ( dict at: 'type' ifAbsent: [dict at: #type]);
		 yourself.
		 
	
]

{ #category : 'accessing' }
Actor >> id: anInteger [
	id := anInteger
]

{ #category : 'accessing' }
Actor >> login [
	^ login.
]

{ #category : 'accessing' }
Actor >> login: aString [
	login := aString
]

{ #category : 'accessing' }
Actor >> type: aString [
	type := aString
]

{ #category : 'accessing' }
Actor >> url: aString [
	url := aString
]
