Class {
	#name : 'BaselineOfGHFailures',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGHFailures',
	#package : 'BaselineOfGHFailures'
}

{ #category : 'spec protocol' }
BaselineOfGHFailures >> baseline: spec [
    <baseline>
    spec for: #'common' do: [ 
        "Package principal"
        spec package: 'GHFailures'.
        
        "Dependencias externas"
        spec baseline: 'NeoJSON' with: [ 
            spec repository: 'github://svenvc/NeoJSON/repository' ].
        
        spec baseline: 'Roassal3' with: [ 
            spec repository: 'github://ObjectProfile/Roassal3/src' ].
        
        "Configurar dependencias del package"
        spec package: 'GHFailures' with: [
            spec requires: #('NeoJSON' 'Roassal3') ].
        
        "Grupos de carga"
        spec  
            group: 'Core' with: #('GHFailures');
            group: 'default' with: #('Core').
    ]
]
