Class {
	#name : 'GHRunnerCollection',
	#superclass : 'Object',
	#instVars : [
		'runners'
	],
	#category : 'TestV1',
	#package : 'TestV1'
}

{ #category : 'adding' }
GHRunnerCollection >> addLegendTo: canvas at: position [
	| legendBox legendItems yOffset |
	
	yOffset := 0.
	
	canvas add: (RSLabel new
		text: 'Legend:';
		fontSize: 12;
		bold;
		color: Color black;
		translateTo: position).
	
	yOffset := yOffset + 20.
	
	legendBox := RSBox new
		size: 15;
		color: Color white;
		border: (RSBorder new color: Color black; width: 1);
		translateTo: position + (0 @ yOffset).
	canvas add: legendBox.
	
	canvas add: (RSLabel new
		text: 'Success';
		fontSize: 10;
		color: Color black;
		translateTo: position + (45 @ yOffset)).
	
	yOffset := yOffset + 25.
	
	"Elemento para failure"
	legendBox := RSBox new
		size: 15;
		color: Color red;
		border: (RSBorder new color: Color black; width: 1);
		translateTo: position + (0 @ yOffset).
	canvas add: legendBox.
	
	canvas add: (RSLabel new
		text: 'Failure';
		fontSize: 10;
		color: Color black;
		translateTo: position + (45 @ yOffset)).
	
	yOffset := yOffset + 25.
	
	"Información sobre tamaño"
	canvas add: (RSLabel new
		text: 'Size = # of attempts';
		fontSize: 10;
		color: Color black;
		translateTo: position + (45 @ yOffset)).
]

{ #category : 'public' }
GHRunnerCollection >> getElementInfo: element [
    "Retorna información detallada del elemento para tooltips"
    | info |
    info := OrderedCollection new.
    
    element class = GHRunner ifTrue: [
        info add: 'Workflow Run: ', element name.
        info add: 'Status: ', element status.
        info add: 'Conclusion: ', element conclusion.
        info add: 'Created: ', element runStartedAt asString.
        element jobs ifNotNil: [ 
            info add: 'Jobs: ', element jobs size asString ] ].
    
    element class = GHJob ifTrue: [
        info add: 'Job: ', element name.
        info add: 'Status: ', element status.
        info add: 'Conclusion: ', element conclusion.
        element steps ifNotNil: [ 
            info add: 'Steps: ', element steps size asString ] ].
    
    element class = GHStep ifTrue: [
        info add: 'Step: ', element name.
        info add: 'Status: ', element status.
        info add: 'Conclusion: ', element conclusion ].
    
    ^ String streamContents: [ :stream |
        info do: [ :line | stream nextPutAll: line; cr ] ]
]

{ #category : 'public' }
GHRunnerCollection >> loadRunnersFromDir: aDirPath [
	| dir worklist files |
	dir := aDirPath asFileReference .
	worklist := OrderedCollection with: dir.
	files := OrderedCollection new.
	
	[ worklist isEmpty ] whileFalse: [
    | current |
    current := worklist removeFirst.
    current isDirectory
        ifTrue: [
            "Si es carpeta, añadir sus hijos a la cola"
            worklist addAll: (current children)
        ]
        ifFalse: [
            "Si es fichero y acaba en .json, lo recojo"
            (current extension = 'json')
                ifTrue: [ files add: current ]
        ].
	].
	runners := files collect: [ :file |
		| json dict |
		json := file readStream contents.
		dict := NeoJSONReader fromString: json.
		GHRunner fromDictionary: dict	
	].
	Transcript show: 'Loaded ', runners size printString, ' runners'; cr.
]

{ #category : 'public' }
GHRunnerCollection >> polymetricView [

	| canvas sortedRunners gridWidth currentX currentY maxWidth rowHeight |
	canvas := RSCanvas new.

	sortedRunners := runners asSortedCollection: [ :a :b |
		                 a runAttempt <= b runAttempt ].

	gridWidth := 10. "10 por fila"
	currentX := 0.
	currentY := 0.
	maxWidth := 0.
	rowHeight := 0.

	sortedRunners withIndexDo: [ :runner :index |
			| square size color |
			size := (runner runAttempt max: 1) * 13. "factor de escala"

			color := runner conclusion = 'failure'
				         ifTrue: [ Color red ]
				         ifFalse: [ Color white ].

			square := RSBox new
				          size: size;
				          color: color;
				          border: (RSBorder new
						           color: Color black;
						           width: 1);
				          model: runner. 

			square translateTo: currentX + (size / 2) @ (currentY + (size / 2)).

			"popup con información básica al hover"
			square @ (RSPopup text: [ :r |
					 'Name: ' , r name asString , String cr , 'Run Attempt: '
					 , r runAttempt asString , String cr , 'Conclusion: '
					 , r conclusion asString , String cr , 'Status: '
					 , r status asString , String cr , 'Click for detailed info...' ]).

			"interacción de click"
			square @ RSHighlightable new.
			square
				when: RSMouseClick
				do: [ :evt | self showRunnerDetails: evt shape model ]
				for: self.


			canvas add: square.

			currentX := currentX + size + 5. "5 píxeles de separación"
			maxWidth := maxWidth max: currentX.
			rowHeight := rowHeight max: size.

			index \\ gridWidth = 0 ifTrue: [
					currentX := 0.
					currentY := currentY + rowHeight + 5. "5 píxeles de separación vertical"
					rowHeight := 0 ] ].

	canvas add: (RSLabel new
			 text: 'GH Runners - Polymetric View (', self runners size printString, ')';
			 fontSize: 16;
			 color: Color black;
			 translateTo: maxWidth / 2 @ -20).

	self addLegendTo: canvas at: maxWidth + 20 @ 0.

	"Configurar canvas"
	canvas @ RSCanvasController.

	^ canvas open
]

{ #category : 'accessing' }
GHRunnerCollection >> runners [
	^ runners.
	
]

{ #category : 'public' }
GHRunnerCollection >> runsByWorkflowId [
    "Retorna un Dictionary con workflow id como key"
    ^ runners groupedBy: [ :run | run workflow id ]
]

{ #category : 'public' }
GHRunnerCollection >> runsByWorkflowName [
    "Retorna un Dictionary con workflow id como key"
    ^ runners groupedBy: [ :run | run workflow name ]
]

{ #category : 'public' }
GHRunnerCollection >> runsByWorkflowName: aString [
    "Retorna un Dictionary con workflow id como key"
    ^ runners groupedBy: [ :run | run workflow name ]
]

{ #category : 'public' }
GHRunnerCollection >> showRunnerDetails: runner [
	"Abre el inspector nativo de Pharo para ver todos los detalles raw del runner"
	
	runner inspect
]

{ #category : 'public' }
GHRunnerCollection >> showRunnerDetailsWindow: runner [
	"Muestra detalles en una ventana SystemWindow personalizada"
	
	| window textMorph scrollPane |
	
	"Crear ventana"
	window := SystemWindow new.
	window setLabel: 'GH Runner Details: ', runner name asString.
	window model: runner.
	
	"Crear texto con detalles"
	textMorph := TextMorph new.
	textMorph contents: (self formatRunnerDetails: runner).
	textMorph
		lock;
		extent: 500@400;
		backgroundColor: Color white;
		borderWidth: 1;
		borderColor: Color gray.
	
	"Crear scroll pane"
	scrollPane := ScrollPane new.
	scrollPane scroller addMorph: textMorph.
	
	"Configurar ventana"
	window
		addMorph: scrollPane frame: (0@0 extent: 1@1);
		extent: 520@450;
		openInWorld.
	
	^ window
]

{ #category : 'public' }
GHRunnerCollection >> visualizeRunsByWorkflow [
    "Visualiza todos los runners agrupados por workflow con jobs y steps"
    | canvas runsByWorkflow yOffset |
    
    canvas := RSCanvas new.
    runsByWorkflow := self runsByWorkflowName.
    yOffset := 0.
    
    runsByWorkflow keysAndValuesDo: [ :workflowName :runners |
        | workflowGroup workflowBox workflowLabel xOffset |
        
        "Crear grupo para cada workflow"
        workflowGroup := RSGroup new.
        
        "Box principal del workflow"
        workflowBox := RSBox new
            size: 300@60;
            color: (Color r: 0.2 g: 0.4 b: 0.8);
            cornerRadius: 10;
            position: 0@yOffset;
            model: workflowName;  "Asignar modelo"
            yourself.
        workflowGroup add: workflowBox.
        
        "Label del workflow"
        workflowLabel := RSLabel new
            text: workflowName;
            color: Color white;
            fontSize: 14;
            bold;
            position: workflowBox position;
            model: workflowName;  "Asignar modelo"
            yourself.
        workflowGroup add: workflowLabel.
        
        "Posición inicial para los runs"
        xOffset := -150.
        
        "Crear visualización para cada runner"
        runners doWithIndex: [ :runner :runIndex |
            | runGroup runBox runLabel jobsYOffset |
            
            runGroup := RSGroup new.
            
            "Box del runner"
            runBox := RSBox new
                size: 200@40;
                color: (runner conclusion = 'success'
                     ifTrue: [ Color r: 0.2 g: 0.7 b: 0.2 ]
                     ifFalse: [ Color r: 0.8 g: 0.2 b: 0.2 ]);
                cornerRadius: 8;
                position: xOffset@(yOffset + 100);
                model: runner;  "Asignar modelo"
                yourself.
            runGroup add: runBox.
            
            "Label del runner"
            runLabel := RSLabel new
                text: 'Run #', runner id asString, ' (', runner conclusion, ')';
                color: Color white;
                fontSize: 11;
                position: runBox position;
                model: runner;  "Asignar modelo"
                yourself.
            runGroup add: runLabel.
            
            "Línea conectando workflow con runner - SIN MODELO"
            runGroup add: (RSLine new
                from: workflowBox position;
                to: runBox position;
                color: (Color gray: 0.6);
                width: 2;
                yourself).
            
            "Visualizar jobs del runner"
            jobsYOffset := 160.
            runner jobs ifNotNil: [
                runner jobs doWithIndex: [ :job :jobIndex |
                    | jobGroup jobBox jobLabel stepsXOffset |
                    
                    jobGroup := RSGroup new.
                    
                    "Box del job"
                    jobBox := RSBox new
                        size: 150@30;
                        color: (job conclusion = 'success'
                            ifTrue: [ Color r: 0.3 g: 0.6 b: 0.3 ]
                            ifFalse: [ job conclusion = 'failure'
                                ifTrue: [ Color r: 0.7 g: 0.3 b: 0.3 ]
                                ifFalse: [ Color r: 0.6 g: 0.6 b: 0.3 ] ]);
                        cornerRadius: 5;
                        position: (xOffset + ((jobIndex - 1) * 160))@(yOffset + jobsYOffset);
                        model: job;  "Asignar modelo"
                        yourself.
                    jobGroup add: jobBox.
                    
                    "Label del job"
                    jobLabel := RSLabel new
                        text: job name;
                        color: Color white;
                        fontSize: 9;
                        position: jobBox position;
                        model: job;  "Asignar modelo"
                        yourself.
                    jobGroup add: jobLabel.
                    
                    "Línea conectando runner con job - SIN MODELO"
                    jobGroup add: (RSLine new
                        from: runBox position;
                        to: jobBox position;
                        color: (Color gray: 0.5);
                        width: 1;
                        yourself).
                    
                    "Visualizar steps del job"
                    stepsXOffset := jobBox position x - 60.
                    job steps ifNotNil: [
                        job steps doWithIndex: [ :step :stepIndex |
                            | stepBox stepLabel |
                            
                            "Box del step"
                            stepBox := RSBox new
                                size: 120@20;
                                color: (step conclusion = 'success'
                                    ifTrue: [ Color r: 0.4 g: 0.8 b: 0.4 ]
                                    ifFalse: [ step conclusion = 'failure'
                                        ifTrue: [ Color r: 0.9 g: 0.4 b: 0.4 ]
                                        ifFalse: [ Color r: 0.8 g: 0.8 b: 0.4 ] ]);
                                cornerRadius: 3;
                                position: (stepsXOffset + ((stepIndex - 1) * 25))@(yOffset + jobsYOffset + 50);
                                model: step;  "Asignar modelo"
                                yourself.
                            jobGroup add: stepBox.
                            
                            "Label del step"
                            stepLabel := RSLabel new
                                text: (step name size > 15
                                     ifTrue: [ (step name first: 12), '...' ]
                                    ifFalse: [ step name ]);
                                color: Color black;
                                fontSize: 8;
                                position: stepBox position;
                                model: step;  "Asignar modelo"
                                yourself.
                            jobGroup add: stepLabel.
                            
                            "Línea conectando job con step - SIN MODELO"
                            jobGroup add: (RSLine new
                                from: jobBox position;
                                to: stepBox position;
                                color: (Color gray: 0.4);
                                width: 1;
                                yourself) ] ].
                    
                    canvas addAll: jobGroup ] ].
            
            canvas addAll: runGroup.
            xOffset := xOffset + 220 ].
        
        canvas addAll: workflowGroup.
        yOffset := yOffset + 300 ].
    
    "Agregar interactividad mejorada con manejo seguro de modelos"
    canvas shapes do: [ :shape |
        [ "Bloque con manejo de excepciones"
            "Verificar que el shape existe"
            shape ifNotNil: [
                "Intentar agregar popup de forma segura"
                shape @ (RSPopup text: [ :s |
                    [ "Manejo seguro del modelo dentro del popup"
                        (s respondsTo: #model)
                            ifTrue: [
                                s model
                                    ifNotNil: [ :model |
                                        model isString
                                            ifTrue: [ model ]
                                            ifFalse: [
                                                (model respondsTo: #name)
                                                    ifTrue: [ model class name, ': ', model name ]
                                                    ifFalse: [ model class name, ': ', model printString ] ] ]
                                    ifNil: [ 'Elemento sin modelo' ] ]
                            ifFalse: [ 'Elemento visual básico' ]
                    ] on: Error do: [ :ex | 'Error: ', ex messageText ] ]).
                
                "Highlighting solo si tiene modelo válido"
                [ ((shape respondsTo: #model) and: [ shape model notNil ])
                    ifTrue: [ shape @ RSHighlightable red ]
                ] on: Error do: [ :ex | "Ignorar errores de highlighting" ] ]
        ] on: Error do: [ :ex | 
            "Transcript show: 'Error en interactividad: ', ex messageText; cr" ] ].
    
    "Configurar canvas"
    canvas @ RSCanvasController.
    canvas color: (Color r: 0.95 g: 0.95 b: 0.95).
    
    "Centrar y abrir"
    canvas open.
    
    ^ canvas
]

{ #category : 'public' }
GHRunnerCollection >> visualizeRunsByWorkflowWithLayout [
    "Versión con layout automático para mejor organización"
    | canvas runsByWorkflow allElements |
    
    canvas := RSCanvas new.
    runsByWorkflow := self runsByWorkflowName.
    allElements := OrderedCollection new.
    
    runsByWorkflow keysAndValuesDo: [ :workflowName :runners |
        | workflowShape |
        
        "Crear shape para workflow"
        workflowShape := RSBox new
            size: 300@60;
            color: (Color r: 0.2 g: 0.4 b: 0.8);
            cornerRadius: 10;
            model: workflowName;
            yourself.
        
        "Label del workflow"
        workflowShape := RSComposite new
            shapes: { workflowShape . 
                RSLabel new
                    text: workflowName;
                    color: Color white;
                    fontSize: 14;
                    bold };
            yourself.
        
        allElements add: workflowShape.
        
        runners do: [ :runner |
            | runnerShape |
            
            "Shape para runner"
            runnerShape := RSComposite new
                shapes: { 
                    RSBox new
                        size: 200@40;
                        color: (runner conclusion = 'success' 
                            ifTrue: [ Color r: 0.2 g: 0.7 b: 0.2 ] 
                            ifFalse: [ Color r: 0.8 g: 0.2 b: 0.2 ]);
                        cornerRadius: 8.
                    RSLabel new
                        text: 'Run #', runner id asString;
                        color: Color white;
                        fontSize: 11 };
                model: runner;
                yourself.
            
            allElements add: runnerShape.
            
            "Conectar workflow con runner"
            allElements add: (RSLine new
                from: workflowShape;
                to: runnerShape;
                color: (Color gray: 0.6);
                width: 2).
            
            "Agregar jobs"
            runner jobs ifNotNil: [
                runner jobs do: [ :job |
                    | jobShape |
                    
                    jobShape := RSComposite new
                        shapes: { 
                            RSBox new
                                size: 150@30;
                                color: (job conclusion = 'success'
                                    ifTrue: [ Color r: 0.3 g: 0.6 b: 0.3 ]
                                    ifFalse: [ Color r: 0.7 g: 0.3 b: 0.3 ]);
                                cornerRadius: 5.
                            RSLabel new
                                text: job name;
                                color: Color white;
                                fontSize: 9 };
                        model: job;
                        yourself.
                    
                    allElements add: jobShape.
                    allElements add: (RSLine new
                        from: runnerShape;
                        to: jobShape;
                        color: (Color gray: 0.5);
                        width: 1).
                    
                    "Agregar steps"
                    job steps ifNotNil: [
                        job steps do: [ :step |
                            | stepShape |
                            
                            stepShape := RSComposite new
                                shapes: { 
                                    RSBox new
                                        size: 120@20;
                                        color: (step conclusion = 'success'
                                            ifTrue: [ Color r: 0.4 g: 0.8 b: 0.4 ]
                                            ifFalse: [ Color r: 0.9 g: 0.4 b: 0.4 ]);
                                        cornerRadius: 3.
                                    RSLabel new
                                        text: (step name size > 15 
                                            ifTrue: [ (step name first: 12), '...' ]
                                            ifFalse: [ step name ]);
                                        color: Color black;
                                        fontSize: 8 };
                                model: step;
                                yourself.
                            
                            allElements add: stepShape.
                            allElements add: (RSLine new
                                from: jobShape;
                                to: stepShape;
                                color: (Color gray: 0.4);
                                width: 1) ] ] ] ] ] ].
    
    canvas addAll: allElements.
    
    "Aplicar layout jerárquico mejorado"
    RSTreeLayout new
        verticalGap: 80;
        horizontalGap: 40;
        applyOn: canvas nodes.
    
    "Agregar interactividad"
    canvas @ RSCanvasController.
    canvas nodes @ RSHighlightable red.
    canvas nodes @ (RSPopup text: [ :shape | 
        shape model ifNotNil: [ :model | model asString ] ifNil: [ 'Connection' ] ]).
    
    canvas open.
    ^ canvas
]
