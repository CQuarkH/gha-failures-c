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
        
        "Configurar dependencias del package"
        spec package: 'GHFailures' with: [
            spec requires: #('NeoJSON') ].
        
        "Grupos de carga"
        spec  
            group: 'Core' with: #('GHFailures');
            group: 'default' with: #('Core').
    ]
]
