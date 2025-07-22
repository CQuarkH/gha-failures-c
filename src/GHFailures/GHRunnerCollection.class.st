Class {
	#name : 'GHRunnerCollection',
	#superclass : 'Object',
	#instVars : [
		'runners'
	],
	#category : 'GHFailures',
	#package : 'GHFailures'
}

{ #category : 'public' }
GHRunnerCollection >> addAtomicLegendTo: canvas at: position [
	"Agrega leyenda explicativa del modelo atómico"
	| legend |
	
	legend := RSGroup new.
	
	"Título de leyenda"
	legend add: (RSLabel new
		text: 'Atomic Model Legend';
		fontSize: 12;
		bold;
		color: Color black;
		translateTo: 0 @ 0).
	
	"Núcleo"
	legend add: (RSCircle new
		size: 15;
		color: Color blue;
		translateTo: -40 @ 25).
	legend add: (RSLabel new
		text: 'Nucleus = Runner';
		fontSize: 10;
		color: Color black;
		translateTo: 20 @ 25).
	
	"Órbitas vacías"
	legend add: (RSCircle new
		size: 20;
		color: Color transparent;
		border: (RSBorder new color: Color gray; width: 1);
		translateTo: -40 @ 50).
	legend add: (RSLabel new
		text: 'Empty Orbits (>10 jobs)';
		fontSize: 10;
		color: Color black;
		translateTo: 30 @ 50).
	
	"Electrones"
	legend add: (RSCircle new
		size: 4;
		color: Color red;
		translateTo: -40 @ 75).
	legend add: (RSLabel new
		text: 'Electrons = Failed Jobs';
		fontSize: 10;
		color: Color black;
		translateTo: 25 @ 75).
	
	"Jobs individuales"
	legend add: (RSCircle new
		size: 8;
		color: Color green;
		translateTo: -40 @ 100).
	legend add: (RSLabel new
		text: 'Individual Jobs (≤10)';
		fontSize: 10;
		color: Color black;
		translateTo: 25 @ 100).
	
	legend translateTo: position.
	canvas addAll: legend.
]

{ #category : 'public' }
GHRunnerCollection >> addAtomicOrbitNucleusInteractionsFor: runner withJobs: jobs inGroup: moleculeGroup [
    "Agrega interacciones para abrir inspector en áreas clickeables de órbitas atómicas"
    | clickableArea maxOrbitRadius numberOfOrbits baseRadius
      successCount failCount successRate |

    numberOfOrbits := (jobs size / 10) ceiling.
    baseRadius := runner runAttempt * 36 / 2 + 20.
    maxOrbitRadius := baseRadius.

    "success rate"
    successCount := jobs count: [ :job | job conclusion = #success ].
    failCount    := jobs count: [ :job | job conclusion = #failure ].
    successRate  := ( successCount / (jobs size max: 1) ) * 100. 

    clickableArea := RSCircle new
        size: maxOrbitRadius * 2;
        color: Color transparent;
        model: runner.

    "Agregar interacciones al área clickeable"
    clickableArea @ RSHighlightable new.
    clickableArea @ (RSPopup text: [ :r |
        'Runner: ',        r name asString,      String cr,
        'Conclusion: ',    r conclusion asString, String cr,
        'Run Attempts: ',  r runAttempt asString, String cr,
        'Total Jobs: ',    jobs size printString, String cr,
        'Failed Jobs: ',   failCount printString, String cr,
        'Succeeded Jobs: ', successCount printString, String cr,
        'Success Rate: ',  (successRate rounded asString), ' %', String cr,
        '(Click to inspect)']).

    "Inspector al hacer click"
    clickableArea
        when: RSMouseClick
        do: [ :evt |
            self showRunnerDetails: (evt shape model) ]
        for: self.

    "Agregar al final para que esté por encima visualmente pero sea clickeable"
    moleculeGroup add: clickableArea.

]

{ #category : 'public' }
GHRunnerCollection >> addAxesLabels: canvas [
	"Agrega etiquetas de los ejes"
	| xLabel yLabel |
	
	xLabel := RSLabel new
		text: 'Number of Jobs →';
		fontSize: 12;
		color: Color black;
		translateTo: 400 @ 35.
	canvas add: xLabel.
	
	yLabel := RSLabel new
		text: 'Execution Time →';
		fontSize: 12;
		color: Color black;
		rotateByDegrees: -90;
		translateTo: 5 @ 200.
	canvas add: yLabel
]

{ #category : 'public' }
GHRunnerCollection >> addExportControlsTo: canvas at: position [
    "Agregar controles de exportación PNG y PDF al canvas"
    | exportLabel pngButton pdfButton buttonWidth buttonHeight |
    
    buttonWidth := 100.
    buttonHeight := 30.
    
    "Etiqueta de exportación"
    exportLabel := RSLabel new
        text: 'Export:';
        fontSize: 12;
        color: Color black;
        translateTo: position.
    canvas add: exportLabel.
    
    "Botón PNG"
    pngButton := RSBox new
        width: buttonWidth;
        height: buttonHeight;
        color: Color lightBlue;
        translateTo: position + (0 @ 25).
    canvas add: pngButton.
    
    pngButton @ (RSPopup text: 'Export as PNG').
    pngButton @ RSHighlightable new.
    pngButton
        when: RSMouseClick
        do: [ :evt | self exportCanvasAsPNG: canvas ]
        for: self.
    
    "Etiqueta del botón PNG"
    canvas add: (RSLabel new
        text: 'PNG';
        fontSize: 10;
        color: Color black;
        translateTo: position + (0 @ 25)).
    
    "Botón PDF"
    pdfButton := RSBox new
        width: buttonWidth;
        height: buttonHeight;
        color: Color lightGreen;
        translateTo: position + (0 @ 65).
    canvas add: pdfButton.
    
    pdfButton @ (RSPopup text: 'Export as PDF').
    pdfButton @ RSHighlightable new.
    pdfButton
        when: RSMouseClick
        do: [ :evt | self exportCanvasAsPDF: canvas ]
        for: self.
    
    "Etiqueta del botón PDF"
    canvas add: (RSLabel new
        text: 'PDF';
        fontSize: 10;
        color: Color black;
        translateTo: position + (0 @ 65)).
]

{ #category : 'adding' }
GHRunnerCollection >> addHotspotLegend: canvas at: position [
	"Agrega leyenda explicativa"
	| legend colorMap |
	
	legend := RSComposite new.
	colorMap := Dictionary new
		at: 'Success' put: Color green;
		at: 'Failure' put: Color red;
		at: 'Cancelled' put: Color orange;
		at: 'Skipped' put: Color gray;
		yourself.
	
	"Título de leyenda"
	legend add: (RSLabel new
		text: 'Legend:';
		fontSize: 14;
		bold;
		color: Color black;
		translateTo: 0 @ 0).
	
	"Conclusiones"
	colorMap associations withIndexDo: [ :assoc :index |
		| colorBox label |
		colorBox := RSBox new
			size: 15;
			border: (RSBorder new color: Color black; width: 1);
			translateTo: 0 @ (index * 25).
		legend add: colorBox.
		
		label := RSLabel new
			text: assoc key;
			fontSize: 11;
			color: Color black;
			translateTo: 25 @ (index * 25).
		legend add: label ].
	
	"Información dimensional"
	legend add: (RSLabel new
		text: 'Width = Jobs, Height = Time';
		fontSize: 10;
		color: Color black;
		translateTo: 0 @ 120).
	
	legend translateTo: position.
	canvas add: legend
]

{ #category : 'public' }
GHRunnerCollection >> addIndividualNucleusInteractionsFor: runner withJobs: jobs inGroup: moleculeGroup [
    "Agrega interacciones para abrir inspector en áreas clickeables de órbitas atómicas"
    | clickableArea maxOrbitRadius numberOfOrbits baseRadius
      successCount failCount successRate |

    numberOfOrbits := (jobs size / 10) ceiling.
    baseRadius := runner runAttempt * 36 / 2 + 20.
    maxOrbitRadius := baseRadius.

    "success rate"
    successCount := jobs count: [ :job | job conclusion = #success ].
    failCount    := jobs count: [ :job | job conclusion = #failure ].
    successRate  := ( successCount / (jobs size max: 1) ) * 100. 

    clickableArea := RSCircle new
        size: maxOrbitRadius * 2;
        color: Color transparent;
        model: runner.

    "Agregar interacciones al área clickeable"
    clickableArea @ RSHighlightable new.
    clickableArea @ (RSPopup text: [ :r |
        'Runner: ',        r name asString,      String cr,
        'Conclusion: ',    r conclusion asString, String cr,
        'Run Attempts: ',  r runAttempt asString, String cr,
        'Total Jobs: ',    jobs size printString, String cr,
        'Failed Jobs: ',   failCount printString, String cr,
        'Succeeded Jobs: ', successCount printString, String cr,
        'Success Rate: ',  (successRate rounded asString), ' %', String cr,
        '(Click to inspect)']).

    "Inspector al hacer click"
    clickableArea
        when: RSMouseClick
        do: [ :evt |
            self showRunnerDetails: evt shape model ]
        for: self.

    "Agregar al final para que esté por encima visualmente pero sea clickeable"
    moleculeGroup add: clickableArea.

]

{ #category : 'public' }
GHRunnerCollection >> addJobInteractionsTo: orbit [
	"Agrega interacciones estándar a un job orbit"
	orbit @ RSHighlightable new.
	orbit @ (RSPopup text: [ :j |
		self getJobPopupTextFor: j ]).
	orbit
		when: RSMouseClick
		do: [ :evt | self showJobDetails: evt shape model ]
		for: self
]

{ #category : 'public' }
GHRunnerCollection >> addJobsSummaryPopupFor: runner withJobs: jobs inGroup: moleculeGroup [
	"Agrega información resumida de todos los jobs al popup del núcleo"
	| nucleus totalJobs successfulJobs failedJobs |
	
	nucleus := moleculeGroup detect: [ :shape | 
		shape model = runner ].
	
	totalJobs := jobs size.
	failedJobs := jobs count: [ :job | 
		job steps anySatisfy: [ :step | step conclusion = #failure ] ].
	successfulJobs := totalJobs - failedJobs.
	
	nucleus @ (RSPopup text: [ :r |
		'Runner: ', r name asString, String cr,
		'Run Attempt: ', r runAttempt printString, String cr,
		'Total Jobs: ', totalJobs printString, String cr,
		'Successful Jobs: ', successfulJobs printString, String cr,
		'Failed Jobs: ', failedJobs printString, String cr,
		'Success Rate: ', ((successfulJobs / totalJobs * 100) rounded printString), '%' ]).
]

{ #category : 'public' }
GHRunnerCollection >> addLayerBorder: canvas atX: x layerWidth: width layerNumber: layerNum [
    "Agregar borde rectangular negro para delimitar un layer"
    | border layerHeight topY |
    
    "Calcular la altura necesaria para el layer (estimación)"
    layerHeight := 600.  "Altura fija generosa para contener todos los elementos"
    topY := 70.          "Posición Y inicial"
    
    "Crear rectángulo de borde"
    border := RSBox new
        width: width;
        height: layerHeight;
        color: Color transparent;
        borderColor: Color black;
        borderWidth: 2;
        model: 'LayerBorder-', layerNum asString.  "Para poder identificarlo después"
    
    "Posicionar el borde"
    border translateTo: (x + (width / 2)) @ (topY + (layerHeight / 2)).
    
    "Agregar al canvas (enviar al fondo para que no tape las cajas)"
    canvas add: border.
    border pushBack.
]

{ #category : 'adding' }
GHRunnerCollection >> addLayerBorderForBoxes: canvas boxes: boxes atX: x layerName: layerName [
    "Crear un borde que contenga todas las cajas del layer con etiqueta"
    | minY maxY layerWidth layerHeight border label |
    
    boxes isEmpty ifTrue: [ ^ self ].
    
    "Calcular dimensiones basadas en las cajas existentes"
    minY := (boxes collect: [ :box | box position y - (box height / 2) ]) min - 30.
    maxY := (boxes collect: [ :box | box position y + (box height / 2) ]) max + 10.
    layerWidth := (boxes collect: [ :box | box width ]) max + 40.
    layerHeight := maxY - minY.
    
    "Crear el borde"
    border := RSBox new
        width: layerWidth;
        height: layerHeight;
        color: Color transparent;
        border: (RSBorder new color: Color black; width: 2);
        yourself.
    
    "Posicionar el borde"
    border translateTo: (x + (layerWidth / 2)) @ (minY + (layerHeight / 2)).
    
    "Crear etiqueta en la parte superior del borde"
    label := RSLabel new
        text: layerName;
        fontSize: 12;
        color: Color black;
        bold;
        yourself.
    
    "Posicionar etiqueta en la parte superior del borde"
    label translateTo: (x + (layerWidth / 2)) @ (minY + 16).
    
    "Agregar al canvas (primero el borde para que esté atrás)"
    canvas add: border.
	 border pushBack.
    canvas add: label.
]

{ #category : 'public' }
GHRunnerCollection >> addLayerBorderForBoxes: canvas boxes: boxes atX: x layerName: layerName layerNumber: layerNumber layerBorders: layerBorders [
    "Crear un borde que contenga todas las cajas del layer con etiqueta"
    | minY maxY layerWidth layerHeight border label borderElements |
    
    boxes isEmpty ifTrue: [ ^ self ].
    
    "Calcular dimensiones basadas en las cajas existentes"
    minY := (boxes collect: [ :box | box position y - (box height / 2) ]) min - 30.
    maxY := (boxes collect: [ :box | box position y + (box height / 2) ]) max + 10.
    layerWidth := (boxes collect: [ :box | box width ]) max + 40.
    layerHeight := maxY - minY.
    
    "Crear el borde"
    border := RSBox new
        width: layerWidth;
        height: layerHeight;
        color: Color transparent;
        border: (RSBorder new color: Color black; width: 2);
        yourself.
    
    "Posicionar el borde"
    border translateTo: (x + (layerWidth / 2)) @ (minY + (layerHeight / 2)).
    
    "Crear etiqueta en la parte superior del borde"
    label := RSLabel new
        text: layerName;
        fontSize: 12;
        color: Color black;
        bold;
        yourself.
    
    "Posicionar etiqueta en la parte superior del borde"
    label translateTo: (x + (layerWidth / 2)) @ (minY + 16).
    
    "Agregar al canvas (primero el borde para que esté atrás)"
    canvas add: border.
    border pushBack.
    canvas add: label.
    
    "Guardar los elementos del borde para posterior eliminación"
    borderElements := OrderedCollection with: border with: label.
    layerBorders at: layerNumber put: borderElements.
]

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
GHRunnerCollection >> addLogTextToBox: box logText: logText onCanvas: canvas [
    "Agregar el texto del log dentro de la caja"
    | label maxWidth lines wrappedText |
    
    maxWidth := box width - 10. "Dejar margen"
    
    "Dividir el texto en líneas que quepan en el ancho"
    lines := self wrapText: logText maxWidth: maxWidth.
    
    "Crear el texto completo"
    wrappedText := lines joinUsing: String cr.
    
    "Crear label con el texto"
    label := RSLabel new
        text: wrappedText;
        fontSize: 8;
        color: Color black;
        yourself.
    
    "Posicionar el texto en el centro de la caja"
    label translateTo: box position.
    
    canvas add: label.
]

{ #category : 'adding' }
GHRunnerCollection >> addMolecularLegendTo: canvas at: position [
	"Leyenda explicativa"
	| legend |
	legend := RSGroup new.
	
	"Núcleo - Ejemplos"
	legend add: (RSCircle new size: 20; color: Color red; translateTo: 0@0).
	legend add: (RSLabel new text: 'Failed Run'; translateTo: 30@0).
	
	legend add: (RSCircle new size: 20; color: Color green; translateTo: 0@25).
	legend add: (RSLabel new text: 'Successful Run'; translateTo: 30@25).
	
	"Órbitas - Ejemplos"
	legend add: (RSCircle new size: 8; color: Color lightRed; translateTo: 0@50).
	legend add: (RSLabel new text: 'Failed Job'; translateTo: 30@50).
	
	legend add: (RSCircle new size: 12; color: Color lightGreen; translateTo: 0@70).
	legend add: (RSLabel new text: 'Successful Job (more steps)'; translateTo: 30@70).
	
	"Información adicional"
	legend add: (RSLabel new 
		text: 'Nucleus size = Run attempts', String cr,
			  'Orbit distance = Job execution time', String cr,
			  'Orbit size = Number of steps';
		fontSize: 10;
		translateTo: 0@100).
	
	legend translateTo: position.
	canvas addAll: legend.
]

{ #category : 'adding' }
GHRunnerCollection >> addWorkflowSeparator: canvas at: y width: w color: color [
	"Agrega una línea separadora para el workflow"
	| line |
	line := RSLine new
		startPoint: 10 @ y;
		endPoint: w @ y;
		color: color;
		width: 2.
	canvas add: line
]

{ #category : 'public' }
GHRunnerCollection >> buildRunnerBoxesFrom: groupedRunners colors: colorArray [
	| runnerBoxes sectionPadding rectHeight innerSpacing borderWidth allAttemptsBoxes allJobsBoxes allStepsBoxes allEntries |
	
	runnerBoxes := Dictionary new.
	sectionPadding := 6. "Separación entre grupos de rectángulos"
	rectHeight := 4. "Altura fija para cada rectángulo interior"
	innerSpacing := 0. "Separación entre rectángulos del mismo grupo"
	borderWidth := 2. "Ancho del borde del Run"
	
	"Colecciones para normalizar después"
	allAttemptsBoxes := OrderedCollection new.
	allJobsBoxes := OrderedCollection new.
	allStepsBoxes := OrderedCollection new.
	
	groupedRunners withIndexDo: [ :pair :idx |
		| key entries |
		key := pair key.
		entries := pair value collect: [ :runner |
			| runW runH runCol runBox attempts totalExecutionTime attemptsBoxes jobsBoxes stepsBoxes attemptsCount jobsCount stepsCount |
			
			"1) Extraer información del runner"
			attempts := runner attempts.
			
			"2) Calcular tiempo total de ejecución (suma de todos los attempts)"
			totalExecutionTime := runner getTotalExecutionTime .
			
			"3) Contar elementos para cada sección"
			attemptsCount := attempts size.
			jobsCount := attempts 
				inject: 0 
				into: [ :sum :attempt | sum + attempt jobs size ].
			stepsCount := attempts 
				inject: 0 
				into: [ :sum :attempt | 
					sum + (attempt jobs 
						inject: 0 
						into: [ :jobSum :job | jobSum + job steps size ]) ].
			
			"4) Calcular ancho basado en tiempo de ejecución"
			runW := totalExecutionTime. "Será normalizado después"
			
			"5) Calcular altura total basada en contenido real"
			runH := (attemptsCount * rectHeight) + 
			        (jobsCount * rectHeight) + 
			        (stepsCount * rectHeight) + 
			        ((attemptsCount - 1 max: 0) * innerSpacing) + 
			        ((jobsCount - 1 max: 0) * innerSpacing) + 
			        ((stepsCount - 1 max: 0) * innerSpacing) + 
			        (2 * sectionPadding) "Separación entre secciones"
					  + (2 * borderWidth).
			
			"6) Color del borde según conclusión del runner"
			runCol := self 
				getColorForConclusion: runner conclusion 
				base: (colorArray at: idx - 1 \\ colorArray size + 1).
			
			"7) Crear rectángulos interiores para attempts (vertical)"
			attemptsBoxes := OrderedCollection new.
			attempts withIndexDo: [ :att :attIdx |
				| attW attCol attBox |
				attW := (runW - (borderWidth * 2)) . "Ancho completo del run - el borde"
				attCol := self 
					getColorForConclusion: att conclusion 
					base: runCol.
				attBox := RSBox new
					width: attW;
					height: rectHeight;
					color: attCol;
					border: nil;
					model: att.
				
				"Popup para attempt"
				attBox @ (RSPopup text: [ :attempt |
					| execTime jobsInAttempt |
					execTime := attempt getExecutionTime.
					jobsInAttempt := attempt jobs size.
					'Attempt #' , attempt runAttempt asString
					, String cr , 'Status: ' , attempt status asString
					, String cr , 'Conclusion: ' , attempt conclusion asString
					, String cr , 'Jobs: ' , jobsInAttempt asString
					, String cr , 'Exec Time: ' , execTime asString , 's'
					, String cr , 'Started: ' , attempt runStartedAt asString
					, String cr , 'Updated: ' , attempt updatedAt asString ]).
				
				attBox @ RSHighlightable new.
				attBox 
					when: RSMouseClick 
					do: [ :evt | evt shape model inspect ] 
					for: self.
				
				attemptsBoxes add: attBox.
				allAttemptsBoxes add: attBox.
			].
			
			"8) Crear rectángulos interiores para jobs (vertical)"
			jobsBoxes := OrderedCollection new.
			attempts do: [ :att |
				att jobs withIndexDo: [ :job :jobIdx |
					| jobW jobCol jobBox |
					jobW := (runW - (borderWidth * 2)) . "Ancho completo del run - el borde"
					jobCol := self 
						getColorForConclusion: job conclusion 
						base: runCol.
					jobBox := RSBox new
						width: jobW;
						height: rectHeight;
						color: jobCol;
						border: nil;
						model: job.
					
					"Popup para job"
					jobBox @ (RSPopup text: [ :j |
						| stepsInJob |
						stepsInJob := j steps size.
						'Job: ' , j name asString
						, String cr , 'Status: ' , j status asString
						, String cr , 'Conclusion: ' , j conclusion asString
						, String cr , 'Steps: ' , stepsInJob asString
						, String cr , 'Started: ' , j startedAt asString
						, String cr , 'Completed: ' , j completedAt asString ]).
					
					jobBox @ RSHighlightable new.
					jobBox 
						when: RSMouseClick 
						do: [ :evt | evt shape model inspect ] 
						for: self.
					
					jobsBoxes add: jobBox.
					allJobsBoxes add: jobBox.
				].
			].
			
			"9) Crear rectángulos interiores para steps (vertical)"
			stepsBoxes := OrderedCollection new.
			attempts do: [ :att |
				att jobs do: [ :job |
					job steps withIndexDo: [ :step :stepIdx |
						| stepW stepCol stepBox |
						stepW := (runW - (borderWidth * 2)) . "Ancho completo del run - el borde"
						stepCol := self 
							getColorForConclusion: step conclusion 
							base: runCol.
						stepBox := RSBox new
							width: stepW;
							height: rectHeight;
							color: stepCol;
							border: nil;
							model: step.
						
						"Popup para step"
						stepBox @ (RSPopup text: [ :s |
							'Step: ' , s name asString
							, String cr , 'Status: ' , s status asString
							, String cr , 'Conclusion: ' , s conclusion asString
							, String cr , 'Started: ' , s startedAt asString
							, String cr , 'Completed: ' , s completedAt asString ]).
						
						stepBox @ RSHighlightable new.
						stepBox 
							when: RSMouseClick 
							do: [ :evt | evt shape model inspect ] 
							for: self.
						
						stepsBoxes add: stepBox.
						allStepsBoxes add: stepBox.
					].
				].
			].
			
			"10) Crear caja principal del runner"
			runBox := RSBox new
				width: runW;
				height: runH;
				color: Color white;
				border: (RSBorder new
					color: runCol;
					width: borderWidth );
				model: runner.
			
			"11) Popup principal para el runner"
			runBox @ (RSPopup text: [ :r |
				'Workflow: ' , r workflow name
				, String cr , 'Run: ' , r name asString
				, String cr , 'Attempts: ' , attemptsCount asString
				, String cr , 'Jobs: ' , jobsCount asString
				, String cr , 'Steps: ' , stepsCount asString
				, String cr , 'Total Exec Time: ' , totalExecutionTime asString , 's'
				, String cr , 'Conclusion: ' , r conclusion asString
				, String cr , 'Click for details...' ]).
			
			runBox @ RSHighlightable new.
			runBox 
				when: RSMouseClick 
				do: [ :evt | self showRunnerDetails: evt shape model ] 
				for: self.
			
			"12) Devolver estructura"
			Dictionary new
				at: #runBox put: runBox;
				at: #attemptsBoxes put: attemptsBoxes;
				at: #jobsBoxes put: jobsBoxes;
				at: #stepsBoxes put: stepsBoxes;
				at: #innerSpacing put: innerSpacing;
				at: #totalExecutionTime put: totalExecutionTime;
				yourself ].
		
		runnerBoxes at: key put: entries ].
	
	allEntries := runnerBoxes values flatCollect: [ :entries | entries ].
	allEntries inspect.
	
	"13) Normalizar anchos de runners basado en tiempo de ejecución"
	RSNormalizer width
    shapes: (allEntries collect: [ :entry | entry at: #runBox ]);
    from: 50;
    to: 200;
    normalize: [ :runnerModel | 
        | matchingEntry time |
        matchingEntry := allEntries 
            detect: [ :entry | 
                | entryBox entryModel |
                entryBox := entry at: #runBox.
                entryModel := entryBox model.
                entryModel == runnerModel ]
            ifNone: [ nil ].
            
        time := matchingEntry 
            ifNotNil: [ matchingEntry at: #totalExecutionTime ]
            ifNil: [ 1 ].
        Transcript show: 'Normalizando con tiempo: ', time asString; cr.
        time ].

	"14) Ajustar anchos de rectángulos interiores después de normalizar runners"
	runnerBoxes values do: [ :entries |
		entries do: [ :entry |
			| runBox attemptsBoxes jobsBoxes stepsBoxes newWidth newHeight |
			runBox := entry at: #runBox.
			attemptsBoxes := entry at: #attemptsBoxes.
			jobsBoxes := entry at: #jobsBoxes.
			stepsBoxes := entry at: #stepsBoxes.
			newWidth := runBox width.
			
			"Recalcular altura basada en contenido real"
			newHeight := (attemptsBoxes size * rectHeight) + 
			             (jobsBoxes size * rectHeight) + 
			             (stepsBoxes size * rectHeight) + 
			             ((attemptsBoxes size - 1 max: 0) * innerSpacing) + 
			             ((jobsBoxes size - 1 max: 0) * innerSpacing) + 
			             ((stepsBoxes size - 1 max: 0) * innerSpacing) + 
			             (2 * sectionPadding)
							 + (2 * borderWidth).
			
			"Ajustar tamaño del runBox"
			runBox extent: newWidth @ newHeight.
			
			"Ajustar ancho de rectángulos de attempts"
			attemptsBoxes do: [ :attBox |
				attBox extent: (newWidth - (borderWidth * 2) ) @ rectHeight ].
			
			"Ajustar ancho de rectángulos de jobs"
			jobsBoxes do: [ :jobBox |
				jobBox extent: (newWidth - (borderWidth * 2) ) @ rectHeight ].
			
			"Ajustar ancho de rectángulos de steps"
			stepsBoxes do: [ :stepBox |
				stepBox extent: (newWidth - (borderWidth * 2) ) @ rectHeight ].
		].
	].
	
	^ runnerBoxes
]

{ #category : 'public' }
GHRunnerCollection >> calculateCanvasContentBounds: canvas [
    "Calcular el rectángulo que contiene todo el contenido del canvas"
    | allShapes minX maxX minY maxY bounds margin  |
    
    allShapes := canvas shapes.
    allShapes isEmpty ifTrue: [ ^ Rectangle origin: 0@0 corner: 100@100 ].
    
    "Inicializar con el primer shape"
    bounds := allShapes first encompassingRectangle.
    minX := bounds left.
    maxX := bounds right.
    minY := bounds top.
    maxY := bounds bottom.
    
    "Expandir bounds para incluir todos los shapes"
    allShapes do: [ :shape |
        | shapeBounds |
        shapeBounds := shape encompassingRectangle.
        minX := minX min: shapeBounds left.
        maxX := maxX max: shapeBounds right.
        minY := minY min: shapeBounds top.
        maxY := maxY max: shapeBounds bottom.
    ].
    
    "Agregar margen"
    margin := 50.
    ^ Rectangle 
        left: minX - margin
        right: maxX + margin
        top: minY - margin
        bottom: maxY + margin.
]

{ #category : 'public' }
GHRunnerCollection >> calculateMoleculeSize: runner withNucleusSize: nucleusSize [
	"Calcula el tamaño total de la molécula según la cantidad de jobs"
	| jobCount baseSize |
	
	jobCount := runner jobs size.
	baseSize := nucleusSize + 160.
	
	jobCount <= 10 
		ifTrue: [ ^ baseSize ]
		ifFalse: [ 
			| numberOfOrbits |
			numberOfOrbits := (jobCount / 10) ceiling.
			^ baseSize + (numberOfOrbits * 70) "Espacio para órbitas"
		]
]

{ #category : 'public' }
GHRunnerCollection >> calculateRootRect: totalWeight [
    "Calcula el rectángulo raíz con mejores proporciones"
    | side |
    side := totalWeight sqrt.
    ^ Rectangle origin: 10@10 extent: side @ side
]

{ #category : 'public' }
GHRunnerCollection >> calculateTreemapLayout: treemapData [
    "Implementación de treemap real usando algoritmo de partición recursiva,
    donde el índice 3 de cada entry es ya el peso absoluto (areaRequired)."

    | layouts totalWeight normalizedData rootRect rootSide |

    "1) Calcular el peso total sumando el campo 3 de cada dato"
    totalWeight := treemapData
        inject: 0
        into: [ :sum :data | sum + (data at: 3) ].

    "2) Normalizar datos: añadimos [ weight ratio ] al final de cada entry"
    normalizedData := treemapData collect: [ :data |
        | weight ratio |
        weight := data at: 3.
        ratio  := weight / totalWeight.
        data , { weight. ratio }
    ].

    "3) Ordenar por ratio (mayor primero) para mejor estabilidad del layout"
    normalizedData := normalizedData
        asSortedCollection: [ :a :b | (a at: 6) > (b at: 6) ].
     totalWeight := treemapData inject: 0 into: [ :s :d | s + (d at: 3) ].
     rootSide := totalWeight sqrt.           "lógica: rootSide² = totalWeight"
     rootRect := Rectangle origin: 10@10 
                      extent: rootSide @ rootSide.

     "4) Inicializar la colección de layouts"
    layouts := OrderedCollection new.

    "5) Ejecutar la partición recursiva en el rectángulo total"

    self 
        partitionTreemap: normalizedData asArray
        inRect: rootRect 
        layouts: layouts.

    ^ layouts
]

{ #category : 'public' }
GHRunnerCollection >> calculateWorstAspectRatio: row inRect: rect [
    "Calcula el peor aspect ratio de una fila de elementos"
    | totalWeight width height rectArea |
    
    totalWeight := row sum: [ :data | data at: 6 ].
    totalWeight = 0 ifTrue: [ ^ Float infinity ].
    
    rectArea := rect area.
    rectArea = 0 ifTrue: [ ^ Float infinity ].
    
    "Determinar si la fila va horizontal o vertical"
    rect width >= rect height
        ifTrue: [
            width := rectArea / rect height.
            height := rect height.
        ]
        ifFalse: [
            width := rect width.
            height := rectArea / rect width.
        ].
    
    "Calcular aspect ratios de cada elemento en la fila"
    ^ row inject: 0 into: [ :maxRatio :data |
        | elementWeight elementWidth elementHeight ratio minDim maxDim |
        elementWeight := data at: 6.
        elementWidth := width.
        elementHeight := totalWeight = 0 
            ifTrue: [ height ]
            ifFalse: [ height * elementWeight / totalWeight ].
        
        elementWidth = 0 ifTrue: [ elementWidth := 1 ].
        elementHeight = 0 ifTrue: [ elementHeight := 1 ].
        
        minDim := elementWidth min: elementHeight.
        maxDim := elementWidth max: elementHeight.
        
        ratio := minDim = 0 ifTrue: [ Float infinity ] ifFalse: [ maxDim / minDim ].
        maxRatio max: ratio
    ]
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> clearConnections: connections canvas: canvas [
    "Limpiar todas las conexiones"
    connections do: [ :connection |
        (canvas shapes includes: connection) ifTrue: [
            canvas removeShape: connection ]].
    connections removeAll.
]

{ #category : 'public' }
GHRunnerCollection >> clearConnectionsByType: connectionType connections: connections canvas: canvas [
    "Limpiar conexiones de un tipo específico"
    | connectionsToRemove |
    
    connectionsToRemove := OrderedCollection new.
    
    connections do: [ :connection |
        | connType |
        
        connType := connection propertyAt: #connectionType ifAbsent: [ nil ].
        
        connType = connectionType ifTrue: [
            (canvas shapes includes: connection) ifTrue: [
                canvas removeShape: connection ].
            connectionsToRemove add: connection ].
    ].
    
    connectionsToRemove do: [ :conn | connections remove: conn ].
]

{ #category : 'public' }
GHRunnerCollection >> clearConnectionsFrom: layerNumber connections: connections canvas: canvas [
    "Limpiar conexiones desde un layer específico en adelante"
    | connectionsToRemove |
    
    connectionsToRemove := OrderedCollection new.
    
    connections do: [ :connection |
        | shouldRemove |
        shouldRemove := false.
        
        "Determinar si la conexión debe ser removida basándose en las posiciones"
        (layerNumber = 3 and: [connection to position x > 300]) ifTrue: [ shouldRemove := true ].
        (layerNumber = 4 and: [connection to position x > 550]) ifTrue: [ shouldRemove := true ].
        
        shouldRemove ifTrue: [
            (canvas shapes includes: connection) ifTrue: [
                canvas removeShape: connection ].
            connectionsToRemove add: connection ]].
    
    connectionsToRemove do: [ :conn | connections remove: conn ].
]

{ #category : 'public' }
GHRunnerCollection >> clearConnectionsFromLayer: layerNumber connections: connections canvas: canvas [
    "Limpiar conexiones que SALEN desde un layer específico en adelante"
    | connectionsToRemove |
    
    connectionsToRemove := OrderedCollection new.
    
    connections do: [ :connection |
        | fromLayer toLayer |
        
        fromLayer := connection propertyAt: #fromLayer ifAbsent: [ nil ].
        toLayer := connection propertyAt: #toLayer ifAbsent: [ nil ].
        
        "Eliminar conexiones que salen desde este layer o layers superiores"
        (fromLayer notNil and: [ fromLayer >= layerNumber ]) ifTrue: [
            (canvas shapes includes: connection) ifTrue: [
                canvas removeShape: connection ].
            connectionsToRemove add: connection ].
    ].
    
    connectionsToRemove do: [ :conn | connections remove: conn ].
]

{ #category : 'public' }
GHRunnerCollection >> clearLayersFrom: layerNumber layerBoxes: layerBoxes canvas: canvas [
    "Limpiar layers desde el número especificado en adelante"
    | layersToRemove |
    
    layersToRemove := layerBoxes keys select: [ :key | key >= layerNumber ].
    
    layersToRemove do: [ :layerKey |
        | boxes |
        boxes := layerBoxes at: layerKey.
        boxes do: [ :box | canvas removeShape: box ].
        layerBoxes removeKey: layerKey.
    ].
]

{ #category : 'public' }
GHRunnerCollection >> clearLayersFrom: layerNumber layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders [
    "Limpiar layers desde el número especificado en adelante"
    | layersToRemove bordersToRemove |
    
    layersToRemove := layerBoxes keys select: [ :key | key >= layerNumber ].
    bordersToRemove := layerBorders keys select: [ :key | key >= layerNumber ].
    
    "Remover las cajas de los layers"
    layersToRemove do: [ :layerKey |
        | boxes |
        boxes := layerBoxes at: layerKey.
        boxes do: [ :box | canvas removeShape: box ].
        layerBoxes removeKey: layerKey.
    ].
    
    "Remover los bordes de los layers"
    bordersToRemove do: [ :layerKey |
        | borderElements |
        borderElements := layerBorders at: layerKey.
        borderElements do: [ :element | 
            (canvas shapes includes: element) ifTrue: [
                canvas removeShape: element ]].
        layerBorders removeKey: layerKey.
    ].
]

{ #category : 'public' }
GHRunnerCollection >> createAtomicOrbitsFor: runner withJobs: jobs inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Crea órbitas vacías + electrones para jobs con failure"
	| numberOfOrbits baseRadius failedJobs |
	
	"Calcular número de órbitas: jobs / 10"
	numberOfOrbits := (jobs size // 10) max: 1.
	baseRadius := nucleusSize / 2 + 20.
	
	"Crear órbitas vacías"
	self createEmptyOrbits: numberOfOrbits 
		 inGroup: moleculeGroup 
		 withBaseRadius: baseRadius.
	
	"Encontrar jobs con failures para mostrar como electrones"
	failedJobs := jobs select: [ :job | 
		job conclusion = #failure ].
	
	"Crear electrones para jobs con failures"
	self createElectronsFor: failedJobs 
		 inGroup: moleculeGroup 
		 withBaseRadius: baseRadius 
		 numberOfOrbits: numberOfOrbits.
	
	"Agregar información de jobs total en popup del núcleo"
	self addJobsSummaryPopupFor: runner withJobs: jobs inGroup: moleculeGroup.
	
   self addAtomicOrbitNucleusInteractionsFor: runner withJobs: jobs inGroup: moleculeGroup.
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> createAtomicVisualizationFor: runner inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Crea visualización atómica: jobs individuales si ≤10, órbitas + electrones si >10"
	| jobs jobCount |
	
	jobs := runner jobs asSortedCollection: [ :a :b | a startedAt <= b startedAt ].
	jobCount := jobs size.
	
	jobCount <= 10 
		ifTrue: [ 
			"≤10 jobs: mostrar jobs individuales como antes"
			self createIndividualJobsFor: runner 
				 withJobs: jobs 
				 inGroup: moleculeGroup 
				 withNucleusSize: nucleusSize ]
		ifFalse: [ 
			"≥10 jobs: mostrar órbitas vacías + electrones para failures"
			self createAtomicOrbitsFor: runner 
				 withJobs: jobs 
				 inGroup: moleculeGroup 
				 withNucleusSize: nucleusSize ]
]

{ #category : 'public' }
GHRunnerCollection >> createAttemptsLayer: attempts onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentRun: parentRun [
    "Crear el layer de attempts (segunda columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    attempts doWithIndex: [ :attempt :index |
        | jobs steps box color h w |
        
        "Métricas del attempt"
        jobs := attempt jobs size.
        steps := attempt jobs inject: 0 into: [ :sum :job | sum + job steps size ].
        
        "Dimensiones: altura basada en jobs"
        h := (jobs max: 1) * 4 + 8.
        w := 25.
        
        "Color basado en el estado del attempt o del parent run"
        color := (attempt conclusion ifNil: [ parentRun conclusion ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del attempt"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: attempt.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Popup con información"
        box @ (RSPopup text: [ :att |
            'Attempt #', index asString, String cr,
            'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "Interacción: mostrar jobs al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 3 layerBoxes: layerBoxes canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 2.
            self createJobsLayer: attempt jobs 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentAttempt: attempt.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 2 put: boxes.
]

{ #category : 'public' }
GHRunnerCollection >> createAttemptsLayer: attempts onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentRun: parentRun connections: connections parentBox: parentBox [
    "Crear el layer de attempts (segunda columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    attempts doWithIndex: [ :attempt :index |
        | jobs steps box color h w connection |
        
        "Métricas del attempt"
        jobs := attempt jobs size.
        steps := attempt jobs inject: 0 into: [ :sum :job | sum + job steps size ].
        
        "Dimensiones: altura basada en jobs"
        h := (jobs max: 1) * 4 + 8.
        w := 25.
        
        "Color basado en el estado del attempt o del parent run"
        color := (attempt conclusion ifNil: [ parentRun conclusion ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del attempt"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: attempt.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Crear conexión desde parent run"
        connection := self createConnection: parentBox to: box.
        canvas add: connection.
        connections add: connection.
        
        "Popup con información"
        box @ (RSPopup text: [ :att |
            'Attempt #', index asString, String cr,
            'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "Interacción: mostrar jobs al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 3 layerBoxes: layerBoxes canvas: canvas.
            self clearConnectionsFrom: 3 connections: connections canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 2.
            self createJobsLayer: attempt jobs 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentAttempt: attempt
                 connections: connections
                 parentBox: evt shape.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 2 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Attempts'.
]

{ #category : 'public' }
GHRunnerCollection >> createAttemptsLayer: attempts onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentRun: parentRun connections: connections parentBox: parentBox layerBorders: layerBorders [
    "Crear el layer de attempts (segunda columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    attempts doWithIndex: [ :attempt :index |
        | jobs steps box color h w time |
        
        "Métricas del attempt"
        jobs := attempt jobs size.
        time := attempt getExecutionTime.
        steps := attempt jobs inject: 0 into: [ :sum :job | sum + job steps size ].
        
        "Dimensiones: ancho basado en jobs"
        h := 10. "altura inicial - será normalizada después"
        w := (jobs max: 1) * 4 + 8.
        
        "Color basado en el estado del attempt o del parent run"
        color := (attempt conclusion ifNil: [ parentRun conclusion ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del attempt"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: attempt.
        
        "Popup con información"
        box @ (RSPopup text: [ :att |
            'Attempt #', index asString, String cr,
            'Conclusion: ', att conclusion asString, String cr,
            'Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "Interacción: mostrar jobs al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearConnectionsFromLayer: 3 connections: connections canvas: canvas.
            self clearLayersFrom: 3 layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 2.
            self createJobsLayer: attempt jobs 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentAttempt: attempt
                 connections: connections
                 parentBox: evt shape
                 layerBorders: layerBorders.
        ] for: self.
        
        boxes add: box.
    ].
    
    "APLICAR NORMALIZACIÓN ANTES DE POSICIONAR Y AGREGAR AL CANVAS"
    RSNormalizer height
        shapes: boxes;
        from: 10;
        to: 300;
        normalize: [ :attemptModel | attemptModel getExecutionTime ].
    
    "AHORA POSICIONAR, CREAR CONEXIONES Y AGREGAR AL CANVAS"
    boxes doWithIndex: [ :box :index |
        | connection |
        
        "Posicionar"
        box translateTo: (x + (box width / 2)) @ (currentY + (box height / 2)).
        
        "Crear conexión desde parent run - MARCADA"
        connection := self createConnection: parentBox to: box 
                          connectionType: #runToAttempt 
                          fromLayer: 1 
                          toLayer: 2.
        canvas add: connection.
        connections add: connection.
        
        canvas add: box.
        currentY := currentY + box height + spacing.
    ].
    
    layerBoxes at: 2 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Attempts' layerNumber: 2 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> createConnection: fromBox to: toBox [
    "Crear una línea con flecha desde fromBox hasta toBox"
    | line |
    
    line := RSLine new
        from: fromBox;
        to: toBox;
        color: Color gray;
        width: 1.
    
    "Agregar punta de flecha"
    
    ^ line
]

{ #category : 'public' }
GHRunnerCollection >> createConnection: fromBox to: toBox connectionType: connectionType fromLayer: fromLayer toLayer: toLayer [
    "Crear una conexión marcada entre dos cajas"
    | line |
    
    line := RSLine new
        from: fromBox;
        to: toBox;
        color: Color gray;
        yourself.
    
    "Marcar la conexión con metadatos"
    line propertyAt: #connectionType put: connectionType.
    line propertyAt: #fromLayer put: fromLayer.
    line propertyAt: #toLayer put: toLayer.
    
    ^ line
]

{ #category : 'public' }
GHRunnerCollection >> createDetailedIndividualJobsFor: runner withJobs: jobs inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Visualización normal para ≤10 jobs (como en el código original)"
	| maxJobTime baseRadius scale |
	
	scale := 20.
	
	maxJobTime := jobs 
		ifEmpty: [ 1 ] 
		ifNotEmpty: [ (jobs collect: #executionTime) max max: 1 ].
	baseRadius := nucleusSize / 2 + 15 // scale.
	
	self addIndividualNucleusInteractionsFor: runner withJobs: jobs inGroup: moleculeGroup .
	
	jobs withIndexDo: [ :job :jobIndex |
		| orbit orbitSize orbitColor distance angle orbitX orbitY connector |
		
		"Tamaño de órbita basado en número de steps"
		orbitSize := (job steps size max: 1) * 3 + 6.
		
		"Color según estado del job"
		orbitColor := self getJobColorFor: job.
		
		"Distancia del núcleo basada en tiempo de ejecución"
		distance := baseRadius + ((job executionTime / maxJobTime) * 30).
		
		"Ángulo para distribuir órbitas uniformemente"
		angle := Float pi - ((jobIndex - 1) * (2 * Float pi / jobs size)).
		orbitX := distance * angle cos.
		orbitY := distance * angle sin.
		
		orbit := RSCircle new
			size: orbitSize;
			color: orbitColor;
			border: (RSBorder new
				color: Color darkGray;
				width: 1);
			model: job;
			translateTo: orbitX @ orbitY.
		
		"Crear partículas de error si existen"
		self createErrorParticlesFor: job 
			 inGroup: moleculeGroup 
			 atPosition: orbitX @ orbitY 
			 withOrbitSize: orbitSize.
		
		"Interacciones para el job"
		self addJobInteractionsTo: orbit.
		
		"Línea conectora del núcleo a la órbita"
		connector := RSLine new
			startPoint: 0@0;
			endPoint: orbitX @ orbitY;
			color: Color gray;
			width: 1.
		
		moleculeGroup add: connector.
		moleculeGroup add: orbit.
	].
]

{ #category : 'public' }
GHRunnerCollection >> createElectronsFor: failedJobs inGroup: moleculeGroup withBaseRadius: baseRadius numberOfOrbits: numberOfOrbits [
	"Crea electrones pequeños para jobs con failures y partículas para sus steps fallidos"
	| electronSize particleSize |
	
	electronSize := 10. "Electrones muy pequeños"
	particleSize := 4. "Partículas aún más pequeñas para steps"
	
	failedJobs withIndexDo: [ :job :jobIndex |
		| electron orbitLevel orbitRadius angle electronX electronY failedSteps |
		
		"Determinar en qué órbita colocar este electrón (distribución uniforme)"
		orbitLevel := ((jobIndex - 1) \\ numberOfOrbits) + 1.
		orbitRadius := baseRadius + (orbitLevel * 35).
		
		"Ángulo aleatorio para posicionar el electrón en la órbita"
		angle := (jobIndex * 137.5) degreesToRadians. "Ángulo dorado para distribución uniforme"
		
		electronX := orbitRadius * angle cos.
		electronY := orbitRadius * angle sin.
		
		"Crear el electrón (job con failure)"
		electron := RSCircle new
			size: electronSize;
			color: Color red;
			border: (RSBorder new
				color: Color red;
				width: 1);
			model: job;
			translateTo: electronX @ electronY.
		
		"Interacciones para el electrón (job con failure)"
		electron @ RSHighlightable new.
		electron @ (RSPopup text: [ :j |
			'Failed Job: ', j name asString, String cr,
			'Execution Time: ', j executionTime printString, 's', String cr,
			'Steps: ', j steps size printString, String cr,
			'Failed Steps: ', (j steps count: [ :s | s conclusion = #failure ]) printString ]).
		
		electron
			when: RSMouseClick
			do: [ :evt | self showJobDetails: evt shape model ]
			for: self.
		
		moleculeGroup add: electron.
		
		"Obtener steps con failure de este job"
		failedSteps := job steps select: [ :step | step conclusion = #failure ].
		
		"Crear partículas para cada step fallido"
		failedSteps withIndexDo: [ :step :stepIndex |
			| particle particleAngle particleDistance particleX particleY color |
			
			"Posicionar las partículas alrededor del electrón"
			particleAngle := (stepIndex * 60) degreesToRadians. "Espaciado de 60 grados entre partículas"
			particleDistance := 15. "Distancia del electrón"
			
			particleX := electronX + (particleDistance * particleAngle cos).
			particleY := electronY + (particleDistance * particleAngle sin).
			color := Color r: 0.8 g: 0.2 b: 0.2.
			
			particle := RSCircle new
				size: particleSize;
				color: color;
				border: (RSBorder new
					color: color;
					width: 0.5);
				model: step;
				translateTo: particleX @ particleY.
			
			"Interacciones para la partícula (step con failure)"
			particle @ RSHighlightable new.
			particle @ (RSPopup text: [ :s |
				'Failed Step: ', s name asString, String cr,
				'Conclusion: ', s conclusion asString, String cr,
				'Duration: ', (s duration ifNil: ['N/A'] ifNotNil: [:d | d printString, 's']) ]).
			
			particle
				when: RSMouseClick
				do: [ :evt | self showStepDetails: evt shape model ]
				for: self.
			
			moleculeGroup add: particle.
		].
	]
]

{ #category : 'public' }
GHRunnerCollection >> createEllipticalOrbitGroup: jobs inGroup: moleculeGroup withAmplitude: amplitude startAngle: startAngle endAngle: endAngle groupIndex: groupIndex [
	"Crea una órbita elíptica para un grupo de jobs"
	| angleStep currentAngle ellipseRatio |
	
	ellipseRatio := 0.6 + (groupIndex * 0.1). "Elipses más pronunciadas en órbitas externas"
	angleStep := (endAngle - startAngle) / jobs size.
	currentAngle := startAngle.
	
	jobs do: [ :job |
		| orbit orbitSize orbitColor orbitX orbitY connector |
		
		"Tamaño de órbita basado en número de steps"
		orbitSize := (job steps size max: 1) * 2 + 4. "Más pequeño en órbitas múltiples"
		
		"Color según estado del job"
		orbitColor := self getJobColorFor: job.
		
		"Posición elíptica"
		orbitX := amplitude * currentAngle cos.
		orbitY := (amplitude * ellipseRatio) * currentAngle sin.
		
		orbit := RSCircle new
			size: orbitSize;
			color: orbitColor;
			border: (RSBorder new
				color: Color darkGray;
				width: 1);
			model: job;
			translateTo: orbitX @ orbitY.
		
		"Crear partículas de error si existen"
		self createErrorParticlesFor: job 
			 inGroup: moleculeGroup 
			 atPosition: orbitX @ orbitY 
			 withOrbitSize: orbitSize.
		
		"Interacciones para el job"
		self addJobInteractionsTo: orbit.
		
		"Línea conectora del núcleo a la órbita (más sutil para múltiples órbitas)"
		connector := RSLine new
			startPoint: 0@0;
			endPoint: orbitX @ orbitY;
			color: (Color gray alpha: 0.4);
			width: 0.5.
		
		moleculeGroup add: connector.
		moleculeGroup add: orbit.
		
		currentAngle := currentAngle + angleStep
	]

]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> createEllipticalOrbitsFor: runner withJobs: jobs inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Órbitas elípticas para > 10 jobs, agrupados de 10 en 10"
	| maxJobTime baseRadius jobGroups avgExecutionTime |
	
	maxJobTime := jobs 
		ifEmpty: [ 1 ] 
		ifNotEmpty: [ (jobs collect: #executionTime) max max: 1 ].
	baseRadius := nucleusSize / 2 + 15.
	
	"Calcular tiempo promedio para determinar amplitud elíptica"
	avgExecutionTime := jobs isEmpty 
		ifTrue: [ 1 ]
		ifFalse: [ (jobs collect: #executionTime) sum / jobs size ].
	
	"Agrupar jobs de 10 en 10"
	jobGroups := self groupJobs: jobs inGroupsOf: 10.
	
	jobGroups withIndexDo: [ :jobGroup :groupIndex |
		| ellipseAmplitude startAngle endAngle |
		
		"Amplitud elíptica basada en tiempo promedio del grupo"
		ellipseAmplitude := baseRadius + (groupIndex * 25) + 
			((avgExecutionTime / maxJobTime) * 20).
		
		"Definir sector angular para este grupo"
		startAngle := self getStartAngleForGroup: groupIndex.
		endAngle := self getEndAngleForGroup: groupIndex.
		
		self createEllipticalOrbitGroup: jobGroup
			 inGroup: moleculeGroup
			 withAmplitude: ellipseAmplitude
			 startAngle: startAngle
			 endAngle: endAngle
			 groupIndex: groupIndex
	]
]

{ #category : 'public' }
GHRunnerCollection >> createEmptyOrbits: numberOfOrbits inGroup: moleculeGroup withBaseRadius: baseRadius [
	"Crea las órbitas vacías (círculos outline)"
	1 to: numberOfOrbits do: [ :orbitIndex |
		| orbitRadius orbitCircle |
		
		orbitRadius := baseRadius + (orbitIndex * 35).
		
		orbitCircle := RSCircle new
			size: orbitRadius * 2;
			color: Color transparent;
			border: (RSBorder new
				color: (Color gray alpha: 0.3);
				width: 1);
			model: ('Orbit ', orbitIndex printString).
		
		moleculeGroup add: orbitCircle.
	]
]

{ #category : 'public' }
GHRunnerCollection >> createErrorParticlesFor: job inGroup: moleculeGroup atPosition: jobPosition withOrbitSize: orbitSize [
	"Crea partículas de error para steps fallidos (solo para modo ≤10 jobs)"
	job steps do: [ :step |
		step conclusion = #failure ifTrue: [
			| errorParticle errorDistance errorAngle errorX errorY errorConnector |
			
			"Partícula de error más pequeña"
			errorParticle := RSCircle new
				size: 3;
				color: Color red;
				border: (RSBorder new color: Color red; width: 1);
				model: step.
			
			"Orbita muy cerca del job"
			errorDistance := (orbitSize / 2) + 6.
			errorAngle := (0 to: 10) atRandom * 2 * Float pi.
			errorX := jobPosition x + (errorDistance * errorAngle cos).
			errorY := jobPosition y + (errorDistance * errorAngle sin).
			
			errorParticle translateTo: errorX @ errorY.
			
			"Línea muy sutil conectando step con job"
			errorConnector := RSLine new
				startPoint: jobPosition;
				endPoint: errorX @ errorY;
				color: (Color red alpha: 0.3);
				width: 0.5.
			
			moleculeGroup add: errorConnector.
			moleculeGroup add: errorParticle.
			
			"Interacciones para el step"
			errorParticle 
				when: RSMouseClick
				do: [ :evt | self showStepDetails: evt shape model ]
				for: self.
		]
	]
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> createIndividualJobsFor: runner withJobs: jobs inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Visualización normal para ≤10 jobs (como en el código original)"
	| maxJobTime baseRadius |
	
	maxJobTime := jobs 
		ifEmpty: [ 1 ] 
		ifNotEmpty: [ (jobs collect: #executionTime) max max: 1 ].
	baseRadius := nucleusSize / 2 + 15.
	
	self addIndividualNucleusInteractionsFor: runner withJobs: jobs inGroup: moleculeGroup .
	
	jobs withIndexDo: [ :job :jobIndex |
		| orbit orbitSize orbitColor distance angle orbitX orbitY connector |
		
		"Tamaño de órbita basado en número de steps"
		orbitSize := (job steps size max: 1) * 3 + 6.
		
		"Color según estado del job"
		orbitColor := self getJobColorFor: job.
		
		"Distancia del núcleo basada en tiempo de ejecución"
		distance := baseRadius + ((job executionTime / maxJobTime) * 30).
		
		"Ángulo para distribuir órbitas uniformemente"
		angle := Float pi - ((jobIndex - 1) * (2 * Float pi / jobs size)).
		orbitX := distance * angle cos.
		orbitY := distance * angle sin.
		
		orbit := RSCircle new
			size: orbitSize;
			color: orbitColor;
			border: (RSBorder new
				color: Color darkGray;
				width: 1);
			model: job;
			translateTo: orbitX @ orbitY.
		
		"Crear partículas de error si existen"
		self createErrorParticlesFor: job 
			 inGroup: moleculeGroup 
			 atPosition: orbitX @ orbitY 
			 withOrbitSize: orbitSize.
		
		"Interacciones para el job"
		self addJobInteractionsTo: orbit.
		
		"Línea conectora del núcleo a la órbita"
		connector := RSLine new
			startPoint: 0@0;
			endPoint: orbitX @ orbitY;
			color: Color gray;
			width: 1.
		
		moleculeGroup add: connector.
		moleculeGroup add: orbit.
	]
]

{ #category : 'public' }
GHRunnerCollection >> createJobsLayer: jobs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentAttempt: parentAttempt [
    "Crear el layer de jobs (tercera columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    jobs doWithIndex: [ :job :index |
        | steps box color h w |
        
        "Métricas del job"
        steps := job steps size.
        
        "Dimensiones: altura basada en steps"
        h := (steps max: 1) * 2 + 6.
        w := 20.
        
        "Color basado en el estado del job"
        color := (job conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del job"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: job.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Popup con información"
        box @ (RSPopup text: [ :j |
            'Job: ', (j name ifNil: ['Job #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Steps: ', steps asString, String cr,
            'Status: ', (j status ifNil: ['unknown'] ifNotNil: [:s | s asString]) ]).
        
        "Interacción: mostrar steps al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 4 layerBoxes: layerBoxes canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 3.
            self createStepsLayer: job steps 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 parentJob: job.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 3 put: boxes.
]

{ #category : 'public' }
GHRunnerCollection >> createJobsLayer: jobs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentAttempt: parentAttempt connections: connections parentBox: parentBox [
    "Crear el layer de jobs (tercera columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    jobs doWithIndex: [ :job :index |
        | steps box color h w connection |
        
        "Métricas del job"
        steps := job steps size.
        
        "Dimensiones: altura basada en steps"
        h := (steps max: 1) * 2 + 6.
        w := 20.
        
        "Color basado en el estado del job"
        color := (job conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del job"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: job.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Crear conexión desde parent attempt"
        connection := self createConnection: parentBox to: box.
        canvas add: connection.
        connections add: connection.
        
        "Popup con información"
        box @ (RSPopup text: [ :j |
            'Job: ', (j name ifNil: ['Job #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Steps: ', steps asString, String cr,
            'Status: ', (j status ifNil: ['unknown'] ifNotNil: [:s | s asString]) ]).
        
        "Interacción: mostrar steps al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 4 layerBoxes: layerBoxes canvas: canvas.
            self clearConnectionsFrom: 4 connections: connections canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 3.
            self createStepsLayer: job steps 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 parentJob: job
                 connections: connections
                 parentBox: evt shape.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 3 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: x layerName: 'Jobs'.
]

{ #category : 'public' }
GHRunnerCollection >> createJobsLayer: jobs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentAttempt: parentAttempt connections: connections parentBox: parentBox layerBorders: layerBorders [
    "Crear el layer de jobs (tercera columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    jobs doWithIndex: [ :job :index |
        | steps box color h w time |
        
        "Métricas del job"
        steps := job steps size.
        time := job executionTime.
        
        "Dimensiones: anchura basada en steps"
        h := 10. "altura inicial - será normalizada después"
        w := (steps max: 1) * 2 + 6.
        
        "Color basado en el estado del job"
        color := (job conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del job"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: job.
        
        "Popup con información"
        box @ (RSPopup text: [ :j |
            'Job: ', (j name ifNil: ['Job #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Steps: ', steps asString, String cr,
            'Time: ', time asString, 's', String cr,
            'Conclusion: ', (j conclusion ifNil: ['unknown'] ifNotNil: [:s | s asString]) ]).
        
        "Interacción: mostrar steps al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearConnectionsFromLayer: 4 connections: connections canvas: canvas.
            self clearConnectionsByType: #jobToStep connections: connections canvas: canvas.
            self clearLayersFrom: 4 layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 3.
            self createStepsLayer: job steps 
                 onCanvas: canvas 
                 atX: (x + layerSpacing)
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing 
                 parentJob: job
                 connections: connections
                 parentBox: evt shape
                 layerBorders: layerBorders.
        ] for: self.
        
        boxes add: box.
    ].
    
    "APLICAR NORMALIZACIÓN ANTES DE POSICIONAR Y AGREGAR AL CANVAS"
    RSNormalizer height
        shapes: boxes;
        from: 10;
        to: 200;
        normalize: [ :jobModel | jobModel executionTime ].
    
    "AHORA POSICIONAR, CREAR CONEXIONES Y AGREGAR AL CANVAS"
    boxes doWithIndex: [ :box :index |
        | connection |
        
        "Posicionar"
        box translateTo: (x + (box width / 2)) @ (currentY + (box height / 2)).
        
        "Crear conexión desde parent attempt - MARCADA"
        connection := self createConnection: parentBox to: box 
                          connectionType: #attemptToJob 
                          fromLayer: 2 
                          toLayer: 3.
        canvas add: connection.
        connections add: connection.
        
        canvas add: box.
        currentY := currentY + box height + spacing.
    ].
    
    layerBoxes at: 3 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Jobs' layerNumber: 3 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> createLogLayer: step onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements connections: connections parentBox: parentBox layerBorders: layerBorders [
    "Crear el layer de log (quinta columna) - solo para steps con failure"
    | logText truncatedLog wrappedLines textElements connection currentY boxes layerWidth margin |
    
    currentY := 80.
    boxes := OrderedCollection new.
    textElements := OrderedCollection new.
    layerWidth := 400.
    margin := 10.
    
    "Obtener el log del step"
    logText := step log ifNil: [ 'No log available' ].
    
    "Truncar a los primeros 200 caracteres"
    truncatedLog := logText size > 2000 
        ifTrue: [ (logText first: 2000), '...' ]
        ifFalse: [ logText ].
    
    "Hacer wrap del texto para que respete el ancho con margen"
    wrappedLines := self wrapTextToLines: truncatedLog maxWidth: (layerWidth - (margin * 2)).
    
    "Crear elementos de texto para cada línea"
    wrappedLines doWithIndex: [ :line :index |
        | textElement |
        
        textElement := RSLabel new
            text: line;
            fontSize: 9;
            color: Color black;
            yourself.
        
        "Posicionar cada línea centrada en el área del layer"
        "El borde se crea en (x - 10) con layerWidth, así que el centro es:"
        textElement translateTo: ((x - 10) + (layerWidth / 2)) @ (currentY + (index * 12)).
        
        "Popup con información completa en cada línea"
        textElement @ (RSPopup text: [
            'Step Log:', String cr,
            'Step: ', (step name ifNil: ['Unknown'] ifNotNil: [:n | n asString]), String cr,
            'Full log (first 500 chars):', String cr,
            (step log ifNil: ['No log available'] ifNotNil: [:log | 
                log size > 500 
                    ifTrue: [ (log first: 500), '...' ]
                    ifFalse: [ log ]]) ]).
        
        "Highlight al pasar mouse"
        textElement @ RSHighlightable new.
        textElement model: step.
        
        canvas add: textElement.
        textElements add: textElement.
        boxes add: textElement.
    ].
    
    "Crear conexión desde parent step - MARCADA"
    textElements ifNotEmpty: [
        connection := self createConnection: parentBox to: textElements first 
                          connectionType: #stepToLog 
                          fromLayer: 4 
                          toLayer: 5.
        canvas add: connection.
        connections add: connection.
    ].
    
    layerBoxes at: 5 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Log (Failure)' layerNumber: 5 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> createRunsLayer: runs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing [
    "Crear el layer de runs (columna izquierda)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    runs doWithIndex: [ :runner :index |
        | time jobs box color h w |
        
        "Métricas del run"
        time := runner getTotalExecutionTime.
        jobs := runner attempts inject: 0 into: [ :sum :att | sum + att jobs size ].
        
        "Dimensiones: altura basada en jobs, ancho fijo"
        h := (jobs max: 1) * 3 + 10.
        w := 30.
        
        "Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "Crear caja del run"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: runner.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Popup con información"
        box @ (RSPopup text: [ :r |
            'Run: ', r name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Attempts: ', r attempts size asString ]).
        
        "Interacción: mostrar attempts al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 2 layerBoxes: layerBoxes canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 1.
            self createAttemptsLayer: runner attempts 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentRun: runner.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 1 put: boxes.
]

{ #category : 'public' }
GHRunnerCollection >> createRunsLayer: runs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing connections: connections [
    "Crear el layer de runs (columna izquierda)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    runs doWithIndex: [ :runner :index |
        | time jobs box color h w |
        
        "Métricas del run"
        time := runner getTotalExecutionTime.
        jobs := runner attempts inject: 0 into: [ :sum :att | sum + att jobs size ].
        
        "Dimensiones: altura basada en jobs, ancho fijo"
        h := (jobs max: 1) * 3 + 10.
        w := 30.
        
        "Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "Crear caja del run"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: runner.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Popup con información"
        box @ (RSPopup text: [ :r |
            'Run: ', r name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Attempts: ', r attempts size asString ]).
        
        "Interacción: mostrar attempts al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearLayersFrom: 2 layerBoxes: layerBoxes canvas: canvas.
            self clearConnections: connections canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 1.
            self createAttemptsLayer: runner attempts 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentRun: runner
                 connections: connections
                 parentBox: evt shape.
        ] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 1 put: boxes.
    
    "Crear borde para Layer 1"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: 30 layerName: 'Runs'.
]

{ #category : 'public' }
GHRunnerCollection >> createRunsLayer: runs onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing connections: connections layerBorders: layerBorders [
    "Crear el layer de runs (columna izquierda)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    runs doWithIndex: [ :runner :index |
        | time jobs box color h w |
        
        "Métricas del run"
        time := runner getTotalExecutionTime.
        jobs := runner attempts inject: 0 into: [ :sum :att | sum + att jobs size ].
        
        h := 10 . "altura inicial - será normalizada después"
        w := (jobs max: 1) * 3 + 10.
        
        "Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "Crear caja del run"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: runner.
        
        "Popup con información"
        box @ (RSPopup text: [ :r |
            'Run: ', r name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Attempts: ', r attempts size asString ]).
        
        "Interacción: mostrar attempts al hacer click"
        box @ RSHighlightable new.
        box when: RSMouseClick do: [ :evt |
            self clearConnectionsFromLayer: 2 connections: connections canvas: canvas.
            self clearLayersFrom: 2 layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders.
            self clearConnectionsByType: #runToAttempt connections: connections canvas: canvas.
            self highlightSelected: evt shape selectedElements: selectedElements layer: 1.
            self createAttemptsLayer: runner attempts 
                 onCanvas: canvas 
                 atX: (x + layerSpacing) 
                 withBoxSpacing: spacing
                 layerBoxes: layerBoxes
                 selectedElements: selectedElements
                 layerSpacing: layerSpacing
                 parentRun: runner
                 connections: connections
                 parentBox: evt shape
                 layerBorders: layerBorders.
        ] for: self.
        
        boxes add: box.
    ].
    
    "APLICAR NORMALIZACIÓN ANTES DE POSICIONAR Y AGREGAR AL CANVAS"
    RSNormalizer height
        shapes: boxes;
        from: 10;
        to: 60;
        normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
    
    "AHORA POSICIONAR Y AGREGAR AL CANVAS"
    boxes do: [ :box |
        box translateTo: (x + (box width / 2)) @ (currentY + (box height / 2)).
        canvas add: box.
        currentY := currentY + box height + spacing.
    ].
    
    layerBoxes at: 1 put: boxes.
    
    "Crear borde para Layer 1"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: 30 layerName: 'Runs' layerNumber: 1 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> createScalableOrbitsFor: runner inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Crea órbitas escalables usando elípticas cuando hay muchos jobs"
	| jobs jobCount |
	
	jobs := runner jobs asSortedCollection: [ :a :b | a startedAt <= b startedAt ].
	jobCount := jobs size.
	
	jobCount <= 10 
		ifTrue: [ 
			"Pocos jobs: usar órbita circular simple"
			self createSimpleOrbitFor: runner 
				 withJobs: jobs 
				 inGroup: moleculeGroup 
				 withNucleusSize: nucleusSize ]
		ifFalse: [ 
			"Muchos jobs: usar órbitas elípticas"
			self createEllipticalOrbitsFor: runner 
				 withJobs: jobs 
				 inGroup: moleculeGroup 
				 withNucleusSize: nucleusSize ]
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> createSimpleOrbitFor: runner withJobs: jobs inGroup: moleculeGroup withNucleusSize: nucleusSize [
	"Órbita circular simple para <= 10 jobs"
	| maxJobTime baseRadius |
	
	maxJobTime := jobs 
		ifEmpty: [ 1 ] 
		ifNotEmpty: [ (jobs collect: #executionTime) max max: 1 ].
	baseRadius := nucleusSize / 2 + 15.
	
	jobs withIndexDo: [ :job :jobIndex |
		| orbit orbitSize orbitColor distance angle orbitX orbitY connector |
		
		"Tamaño de órbita basado en número de steps"
		orbitSize := (job steps size max: 1) * 3 + 6.
		
		"Color según estado del job"
		orbitColor := self getJobColorFor: job.
		
		"Distancia del núcleo basada en tiempo de ejecución"
		distance := baseRadius + ((job executionTime / maxJobTime) * 30).
		
		"Ángulo para distribuir órbitas uniformemente"
		angle := Float pi - ((jobIndex - 1) * (2 * Float pi / jobs size)).
		orbitX := distance * angle cos.
		orbitY := distance * angle sin.
		
		orbit := RSCircle new
			size: orbitSize;
			color: orbitColor;
			border: (RSBorder new
				color: Color darkGray;
				width: 1);
			model: job;
			translateTo: orbitX @ orbitY.
		
		"Crear partículas de error si existen"
		self createErrorParticlesFor: job 
			 inGroup: moleculeGroup 
			 atPosition: orbitX @ orbitY 
			 withOrbitSize: orbitSize.
		
		"Interacciones para el job"
		self addJobInteractionsTo: orbit.
		
		"Línea conectora del núcleo a la órbita"
		connector := RSLine new
			startPoint: 0@0;
			endPoint: orbitX @ orbitY;
			color: Color gray;
			width: 1.
		
		moleculeGroup add: connector.
		moleculeGroup add: orbit.
	]
]

{ #category : 'public' }
GHRunnerCollection >> createStepsLayer: steps onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements layerSpacing: layerSpacing parentJob: parentJob connections: connections parentBox: parentBox layerBorders: layerBorders [
    "Crear el layer de steps (cuarta columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    steps doWithIndex: [ :step :index |
        | box color h w time |
        
        time := step executionTime.
        "Tiempo como altura, ancho fijo"
        h := 10. "altura inicial - será normalizada después"
        w := 15.
        
        "Color basado en el estado del step"
        color := (step conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del step"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: step.
        
        "Popup con información"
        box @ (RSPopup text: [ :s |
            'Step: ', (s name ifNil: ['Step #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Time: ', time asString, 's', String cr,
            'Conclusion: ', (s conclusion ifNil: ['unknown'] ifNotNil: [:st | st asString]) ]).
        
        "Highlight al pasar mouse"
        box @ RSHighlightable new.
        
        "Interacción: mostrar log si es failure"
        box when: RSMouseClick do: [ :evt |
            | stepConclusion |
            stepConclusion := step conclusion ifNil: [ 'unknown' ].
            
            "Solo mostrar log si el step tiene conclusion 'failure'"
            stepConclusion = 'failure' ifTrue: [
                self clearConnectionsFromLayer: 5 connections: connections canvas: canvas.
                self clearLayersFrom: 5 layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders.
                self highlightSelected: evt shape selectedElements: selectedElements layer: 4.
					 self clearConnectionsByType: #stepToLog connections: connections canvas: canvas.
                self createLogLayer: step 
                     onCanvas: canvas 
                     atX: (x + layerSpacing) 
                     withBoxSpacing: spacing
                     layerBoxes: layerBoxes
                     selectedElements: selectedElements
                     connections: connections
                     parentBox: evt shape
                     layerBorders: layerBorders.
            ] ifFalse: [
                "Si no es failure, solo limpiar layers superiores"
                self clearConnectionsFromLayer: 5 connections: connections canvas: canvas.
                self clearLayersFrom: 5 layerBoxes: layerBoxes canvas: canvas layerBorders: layerBorders.
                self highlightSelected: evt shape selectedElements: selectedElements layer: 4.
            ].
        ] for: self.
        
        boxes add: box.
    ].
    
    "APLICAR NORMALIZACIÓN ANTES DE POSICIONAR Y AGREGAR AL CANVAS"
    RSNormalizer height
        shapes: boxes;
        from: 10;
        to: 100;
        normalize: [ :stepModel | stepModel executionTime ].
    
    "AHORA POSICIONAR, CREAR CONEXIONES Y AGREGAR AL CANVAS"
    boxes doWithIndex: [ :box :index |
        | connection |
        
        "Posicionar"
        box translateTo: (x + (box width / 2)) @ (currentY + (box height / 2)).
        
        "Crear conexión desde parent job - MARCADA"
        connection := self createConnection: parentBox to: box 
                          connectionType: #jobToStep 
                          fromLayer: 3 
                          toLayer: 4.
        canvas add: connection.
        connections add: connection.
        
        canvas add: box.
        currentY := currentY + box height + spacing.
    ].
    
    layerBoxes at: 4 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Steps' layerNumber: 4 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> createStepsLayer: steps onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements parentJob: parentJob [
    "Crear el layer de steps (cuarta columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    steps doWithIndex: [ :step :index |
        | box color h w |
        
        "Dimensiones fijas para steps"
        h := 15.
        w := 15.
        
        "Color basado en el estado del step"
        color := (step conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del step"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: step.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Popup con información"
        box @ (RSPopup text: [ :s |
            'Step: ', (s name ifNil: ['Step #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Status: ', (s status ifNil: ['unknown'] ifNotNil: [:st | st asString]) ]).
        
        "Highlight al pasar mouse"
        box @ RSHighlightable new.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 4 put: boxes.
]

{ #category : 'public' }
GHRunnerCollection >> createStepsLayer: steps onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements parentJob: parentJob connections: connections parentBox: parentBox [
    "Crear el layer de steps (cuarta columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    steps doWithIndex: [ :step :index |
        | box color h w connection |
        
        "Dimensiones fijas para steps"
        h := 15.
        w := 15.
        
        "Color basado en el estado del step"
        color := (step conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del step"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: step.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Crear conexión desde parent job"
        connection := self createConnection: parentBox to: box.
        canvas add: connection.
        connections add: connection.
        
        "Popup con información"
        box @ (RSPopup text: [ :s |
            'Step: ', (s name ifNil: ['Step #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Status: ', (s status ifNil: ['unknown'] ifNotNil: [:st | st asString]) ]).
        
        "Highlight al pasar mouse"
        box @ RSHighlightable new.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 4 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: x layerName: 'Steps'.
]

{ #category : 'public' }
GHRunnerCollection >> createStepsLayer: steps onCanvas: canvas atX: x withBoxSpacing: spacing layerBoxes: layerBoxes selectedElements: selectedElements parentJob: parentJob connections: connections parentBox: parentBox layerBorders: layerBorders [
    "Crear el layer de steps (cuarta columna)"
    | currentY boxes |
    
    currentY := 80.
    boxes := OrderedCollection new.
    
    steps doWithIndex: [ :step :index |
        | box color h w connection |
        
        "Dimensiones fijas para steps"
        h := 15.
        w := 15.
        
        "Color basado en el estado del step"
        color := (step conclusion ifNil: [ 'unknown' ])
            ifNotNil: [ :conclusion | self getColorForConclusion: conclusion base: Color white ]
            ifNil: [ Color lightGray ].
        
        "Crear caja del step"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: step.
        
        "Posicionar"
        box translateTo: (x + (w / 2)) @ (currentY + (h / 2)).
        
        "Crear conexión desde parent job - MARCADA"
        connection := self createConnection: parentBox to: box 
                          connectionType: #jobToStep 
                          fromLayer: 3 
                          toLayer: 4.
        canvas add: connection.
        connections add: connection.
        
        "Popup con información"
        box @ (RSPopup text: [ :s |
            'Step: ', (s name ifNil: ['Step #', index asString] ifNotNil: [:n | n asString]), String cr,
            'Conclusion: ', (s conclusion ifNil: ['unknown'] ifNotNil: [:st | st asString]) ]).
        
        "Highlight al pasar mouse"
        box @ RSHighlightable new.
		  box when: RSMouseClick do: [ :evt | 
				evt shape model inspect .
			] for: self.
        
        canvas add: box.
        boxes add: box.
        currentY := currentY + h + spacing.
    ].
    
    layerBoxes at: 4 put: boxes.
    
    "Crear borde para este layer"
    self addLayerBorderForBoxes: canvas boxes: boxes atX: (x - 10) layerName: 'Steps' layerNumber: 4 layerBorders: layerBorders.
]

{ #category : 'public' }
GHRunnerCollection >> estimateRequiredGridSizeFor: runnerRects maxRowWidth: maxWidth spacing: spacing [

    | currentX currentY maxHeightInRow totalWidth totalHeight |

    currentX := 0.
    currentY := 0.
    maxHeightInRow := 0.
    totalWidth := 0.
    totalHeight := 0.

    runnerRects do: [ :rect |
        | box width height newX |

        "■ Si rect viene siendo un Dictionary, tomo su runBox automáticamente"
        box := (rect isKindOf: Dictionary)
            ifTrue:  [ rect at: #runBox ]
            ifFalse: [ rect ].

        width := box width.
        height := box height.
        newX := currentX + width.

        "salto de línea si excede el ancho máximo"
        (newX > maxWidth) ifTrue: [
            currentX := 0.
            currentY := currentY + maxHeightInRow + spacing.
            maxHeightInRow := 0.
            newX := currentX + width.
        ].

        "actualizar medidas"
        totalWidth := totalWidth max: newX.
        totalHeight := currentY + height.

        currentX := currentX + width + spacing.
        maxHeightInRow := maxHeightInRow max: height.
    ].

    "añadir espacio extra inferior"
    totalHeight := totalHeight + spacing.

    ^ totalWidth @ totalHeight

]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> exportCanvasAsPDF: canvas [
    "Exportar canvas completo como archivo PDF - Versión simple"
    | fileName exporter |
    
    fileName := 'polymetric_view', DateAndTime now asString copyReplaceAll: ':' with: '-', '.pdf'.
    
    "Ajustar cámara para mostrar todo el contenido"
    canvas zoomToFit.
    
    "Pequeña pausa para que se redibuje"
    (Delay forMilliseconds: 50) wait.
    
    "Exportar"
    exporter := RSPDFCairoExporter new.
    exporter canvas: canvas.
    exporter fileName: fileName.
    exporter export.
    
    self inform: 'PDF exported as: ', fileName.
]

{ #category : 'public' }
GHRunnerCollection >> exportCanvasAsPNG: canvas [
    "Exportar canvas completo como archivo PNG - Versión simple basada en PDF"
    | fileName exporter |

    fileName := 'polymetric_view', DateAndTime now asString copyReplaceAll: ':' with: '-', '.png'.

    "Ajustar cámara para mostrar todo el contenido"
    canvas zoomToFit.

    "Pequeña pausa para que se redibuje"
    (Delay forMilliseconds: 50) wait.

    "Exportar"
    exporter := RSPNGExporter new.
    exporter canvas: canvas.
    exporter fileName: fileName.
    exporter export.

    self inform: 'PNG exported as: ', fileName.
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> findBestRow: dataArray forRect: rect [
    "Encuentra la mejor fila que minimiza el peor aspect ratio"
    | bestRow bestRatio currentRow currentRatio |
    
    bestRow := { dataArray first }.
    bestRatio := self calculateWorstAspectRatio: bestRow inRect: rect.
    
    2 to: dataArray size do: [ :i |
        currentRow := dataArray first: i.
        currentRatio := self calculateWorstAspectRatio: currentRow inRect: rect.
        
        currentRatio < bestRatio
            ifTrue: [
                bestRow := currentRow.
                bestRatio := currentRatio.
            ]
            ifFalse: [ ^ bestRow ]. "Stop when ratio starts getting worse"
    ].
    
    ^ bestRow
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> findOptimalSplit: dataArray totalWeight: totalWeight [
	"Encuentra el punto óptimo de división para minimizar aspect ratio"
	| bestRatio bestSplit currentWeight |
	
	bestRatio := Float infinity.
	bestSplit := 0.5.
	currentWeight := 0.
	
	1 to: (dataArray size - 1) do: [ :i |
		| data ratio |
		data := dataArray at: i.
		currentWeight := currentWeight + (data at: 6).
		ratio := currentWeight / totalWeight.
		
		"evitar divisiones muy desbalanceadas"
		(ratio > 0.1 and: [ ratio < 0.9 ]) ifTrue: [
			| aspectRatio |
			aspectRatio := (ratio / (1 - ratio)) abs.
			aspectRatio < bestRatio ifTrue: [
				bestRatio := aspectRatio.
				bestSplit := ratio
			]
		]
	].
	
	^ bestSplit
]

{ #category : 'public' }
GHRunnerCollection >> fitCameraToShowAllContent: canvas bounds: bounds [
    "Ajustar la cámara para mostrar todo el contenido"
    | camera canvasExtent contentExtent scaleX scaleY finalScale centerPoint |
    
    camera := canvas camera.
    canvasExtent := canvas extent.
    contentExtent := bounds extent.
    
    "Calcular escalas necesarias para ajustar todo el contenido"
    scaleX := canvasExtent x / contentExtent x.
    scaleY := canvasExtent y / contentExtent y.
    
    "Usar la escala menor para que todo quepa"
    finalScale := (scaleX min: scaleY) * 0.9. "Factor 0.9 para dejar un poco de margen"
    
    "Calcular punto central del contenido"
    centerPoint := bounds center.
    
    "Aplicar transformaciones a la cámara"
    camera scale: finalScale.
    camera position: centerPoint.
    
    "Actualizar canvas"
    canvas signalUpdate.
]

{ #category : 'public' }
GHRunnerCollection >> getColorForConclusion: conclusion base: baseColor [
    conclusion = 'success'
        ifTrue: [^ Color green alpha: 0.7].
    conclusion = 'failure'
        ifTrue: [^ Color red alpha: 0.7].
    conclusion = 'cancelled'
        ifTrue: [^ Color orange alpha: 0.7].
    conclusion = 'skipped'
        ifTrue: [^ Color gray alpha: 0.7].
    conclusion = 'neutral'
        ifTrue: [^ Color blue alpha: 0.7].     "casi completado"
    conclusion = 'stale'
        ifTrue: [^ Color magenta alpha: 0.7]. "desactualizado"
    conclusion = 'timed_out'
        ifTrue: [^ Color purple alpha: 0.7].  "se agotó"

    "Fallback: baseColor semitransparente"
    ^ baseColor alpha: 0.7.

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

{ #category : 'as yet unclassified' }
GHRunnerCollection >> getEndAngleForGroup: groupIndex [  
	"Calcula el ángulo final para cada grupo orbital"
	^ self getStartAngleForGroup: groupIndex + (Float pi) "180 grados de arco"
]

{ #category : 'public' }
GHRunnerCollection >> getJobColorFor: aJob [
	"Color de órbita según estado del job"
	^ aJob status = 'completed'
		ifTrue: [ 
			aJob conclusion = 'success'
				ifTrue: [ Color lightGreen ]
				ifFalse: [ Color lightRed ] ]
		ifFalse: [
			aJob status = 'in_progress'
				ifTrue: [ Color lightBlue ]
				ifFalse: [ Color lightGray ] ]
]

{ #category : 'public' }
GHRunnerCollection >> getJobPopupTextFor: aJob [
    "Texto informativo para el popup del job"
    ^ 'Job: ', aJob name asString, String cr,
      'Conclusion: ', aJob conclusion asString, String cr,
      'Execution Time: ', aJob executionTime asString, ' s', String cr,
      'Steps: ', aJob steps size asString, String cr,
      '(Click for more info)'
]

{ #category : 'public' }
GHRunnerCollection >> getLastAttemptExecutionTime: runner [
    "Calcula el tiempo de ejecución máximo entre todos los attempts del runner"
    | maxTime |
    
    maxTime := runner attempts 
        ifEmpty: [ 1 ]
        ifNotEmpty: [ 
            runner attempts 
                inject: 0 
                into: [ :max :attempt | 
                    max max: attempt getExecutionTime ]
        ].
    
    "Garantizar al menos 1 segundo para evitar cajas de altura cero"
    ^ maxTime max: 1
]

{ #category : 'public' }
GHRunnerCollection >> getMaxAttemptExecutionTime: runner [
    "Calcula el tiempo de ejecución máximo entre todos los attempts del runner"
    | maxTime |
    
    maxTime := runner attempts 
        ifEmpty: [ 1 ]
        ifNotEmpty: [ 
            runner attempts 
                inject: 0 
                into: [ :max :attempt | 
                    max max: attempt getExecutionTime ]
        ].
    
    "Garantizar al menos 1 segundo para evitar cajas de altura cero"
    ^ maxTime max: 1
]

{ #category : 'public' }
GHRunnerCollection >> getMolecularPopupTextFor: aRunner [
	"Texto informativo para el popup"
	| jobsInfo |
	jobsInfo := aRunner jobs 
		inject: ''
		into: [ :acc :job | 
			acc, 'Job: ', job name, ' (', job status, ')', String cr ].
	
	^ 'Runner: ', aRunner name asString, String cr,
	  'Attempts: ', aRunner runAttempt asString, String cr,
	  'Status: ', aRunner conclusion asString, String cr,
	  'Jobs (', aRunner jobs size asString, '):', String cr,
	  jobsInfo,
	  'Click for details...'
]

{ #category : 'public' }
GHRunnerCollection >> getNucleusColorFor: aRunner [
	"Color del núcleo según conclusión"
	^ aRunner conclusion = 'failure'
		ifTrue: [ Color red ]
		ifFalse: [ 
			aRunner conclusion = 'success'
				ifTrue: [ Color green ]
				ifFalse: [ Color yellow ] ]
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> getStartAngleForGroup: groupIndex [
	"Calcula el ángulo inicial para cada grupo orbital"
	^ (groupIndex - 1) * (Float pi / 3) "60 grados por grupo"
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> groupAndSortRunners: aCollection [
    | copy dict result |

    "1) Copiar aCollection a un OrderedCollection puro"
    copy := OrderedCollection new.
    aCollection do: [ :r | copy add: r ].

    "2) Agrupar por nombre de workflow"
    dict := copy groupedBy: [ :r | r workflow name ].

    "3) Ordenar cada lista de runs por runStartedAt descendente"
    dict keysAndValuesDo: [ :key :vals |
        dict at: key put: (vals asSortedCollection: [ :a :b | a runStartedAt > b runStartedAt ])
    ].

    "4) Convertir associations a OrderedCollection y ordenarlas por clave"
    result := OrderedCollection new.
    (dict associations
         asSortedCollection: [ :a :b | a key < b key ])
        do: [ :assoc | result add: assoc ].

    ^ result

]

{ #category : 'public' }
GHRunnerCollection >> groupJobs: jobs inGroupsOf: size [
	"Agrupa los jobs en grupos del tamaño especificado"
	| groups currentGroup |
	groups := OrderedCollection new.
	currentGroup := OrderedCollection new.
	
	jobs do: [ :job |
		currentGroup add: job.
		currentGroup size = size ifTrue: [
			groups add: currentGroup copy.
			currentGroup := OrderedCollection new
		]
	].
	
	"Agregar el último grupo si no está vacío"
	currentGroup isEmpty ifFalse: [ groups add: currentGroup ].
	
	^ groups
]

{ #category : 'public' }
GHRunnerCollection >> highlightSelected: selectedShape selectedElements: selectedElements layer: layerNumber [
    "Destacar el elemento seleccionado y quitar highlight de otros"
    | previousSelected |
    
    "Quitar highlight anterior del mismo layer"
    previousSelected := selectedElements at: layerNumber ifAbsent: [ nil ].
    previousSelected ifNotNil: [ 
        previousSelected borderColor: Color transparent.
        previousSelected borderWidth: 0.
    ].
    
    "Aplicar highlight al nuevo elemento seleccionado"
    selectedShape borderColor: Color red.
    selectedShape borderWidth: 2.
    
    "Guardar la nueva selección"
    selectedElements at: layerNumber put: selectedShape.
]

{ #category : 'public' }
GHRunnerCollection >> hotspotViewByActor [
	| visualizationCanvas runnersByActor verticalPosition canvasMaxWidth availableColors allJobRectangles |
	
	visualizationCanvas := RSCanvas new.
	
	"agrupar runners por actor y ordenar por fecha (más recientes primero)"
	runnersByActor := (runners groupedBy: [ :runner | runner actor login ]) 
		associations collect: [ :actorAssociation |
			actorAssociation key -> (actorAssociation value asSortedCollection: [ :runnerA :runnerB | 
				runnerA runStartedAt > runnerB runStartedAt ]) ].
	
	runnersByActor := runnersByActor asSortedCollection: [ :actorA :actorB | actorA key < actorB key ].
	
	availableColors := { 
		Color blue muchLighter. Color red muchLighter. Color green muchLighter. 
		Color orange muchLighter. Color purple muchLighter. Color brown muchLighter.
		Color cyan muchLighter. Color magenta muchLighter. Color yellow muchLighter. Color gray muchLighter 
	}.
	
	verticalPosition := 50.
	canvasMaxWidth := 0.
	allJobRectangles := OrderedCollection new.
	
	runnersByActor withIndexDo: [ :actorGroup :actorIndex |
		| actorRunners actorColor actorNameLabel horizontalPosition maxRowHeight |
		
		actorRunners := actorGroup value.
		actorColor := availableColors at: ((actorIndex - 1) \\ availableColors size + 1).
		
		actorNameLabel := RSLabel new
			text: actorGroup key;
			fontSize: 65;
			color: Color black;
			bold;
			translateTo: 10 @ (verticalPosition - 75).
		visualizationCanvas add: actorNameLabel.
		
		horizontalPosition := 20.
		maxRowHeight := 0.
		
		actorRunners withIndexDo: [ :currentRunner :runnerPosition |
			| jobRectangle rectangleWidth rectangleHeight statusColor executionTimeInSeconds totalJobs |
			
			totalJobs := currentRunner jobs size.
			executionTimeInSeconds := self getLastAttemptExecutionTime: currentRunner.
			
			"dimensiones del rectángulo"
			rectangleWidth := (totalJobs max: 1) * 25.  "ancho = número de jobs"
			rectangleHeight := 50.  "altura temporal que se normalizará después"
			
			"color basado en el estado de conclusión"
			statusColor := self getColorForConclusion: currentRunner conclusion base: actorColor.
			
			jobRectangle := RSBox new
				width: rectangleWidth;
				height: rectangleHeight;
				color: statusColor;
				border: (RSBorder new 
					color: actorColor darker; 
					width: 1);
				model: currentRunner.
			
			jobRectangle translateTo: horizontalPosition + (rectangleWidth / 2) @ (verticalPosition + (rectangleHeight / 2)).
			
			"tooltip con información detallada del runner"
			jobRectangle @ (RSPopup text: [ :runner |
				| executionTime |
				executionTime := self getLastAttemptExecutionTime: runner.
				'Workflow: ' , runner workflow name , String cr ,
				'Run: ' , runner name asString , String cr ,
				'Jobs: ' , runner jobs size asString , String cr ,
				'Execution Time: ' , executionTime asString , 's' , String cr ,
				'Attempt: ' , runner runAttempt asString , String cr ,
				'Conclusion: ' , runner conclusion asString , String cr ,
				'Status: ' , runner status asString , String cr ,
				'Started: ' , runner runStartedAt asString , String cr ,
				'Click for detailed info...' ]).
			
			"efectos de interacción"
			jobRectangle @ RSHighlightable new.
			jobRectangle when: RSMouseClick do: [ :mouseEvent | 
				self showRunnerDetails: mouseEvent shape model ] for: self.
			
			visualizationCanvas add: jobRectangle.
			allJobRectangles add: jobRectangle.
			
			horizontalPosition := horizontalPosition + rectangleWidth + 50.
			maxRowHeight := maxRowHeight max: rectangleHeight.
			canvasMaxWidth := canvasMaxWidth max: horizontalPosition.
			
			"nueva fila cada 10 runners"
			runnerPosition \\ 10 = 0 ifTrue: [
				horizontalPosition := 20.
				verticalPosition := verticalPosition + maxRowHeight + 200.
				maxRowHeight := 0 ]
		].
		
		"espacio entre diferentes actores"
		verticalPosition := verticalPosition + 300
	].
	
	"normalizar alturas basadas en tiempo de ejecución"
	RSNormalizer height
		shapes: allJobRectangles;
		from: 10;
		to: 150;
		normalize: [ :runner | self getLastAttemptExecutionTime: runner ].
	
	"reposicionar rectángulos después de la normalización"
	allJobRectangles do: [ :rectangle |
		| currentRectanglePosition |
		currentRectanglePosition := rectangle position.
		rectangle translateTo: currentRectanglePosition x @ (currentRectanglePosition y + (rectangle height / 2) - 25)
	].
	
	visualizationCanvas @ RSCanvasController.
	^ visualizationCanvas open
]

{ #category : 'public' }
GHRunnerCollection >> layerDesignView: workflowName [
    "Diseño por layers: Runs -> Attempts -> Jobs -> Steps"
    | canvas filteredRunners currentLayer layerBoxes layerPositions 
      layerWidth layerSpacing boxSpacing selectedElements connections layerBorders |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    currentLayer := 1.
    layerBoxes := Dictionary new.
    layerPositions := Dictionary new.
    layerWidth := 200.
    layerSpacing := 100.
    boxSpacing := 5.
    selectedElements := Dictionary new.
    connections := OrderedCollection new.
    layerBorders := Dictionary new.
    
    "3) Ordenar runs cronológicamente (más reciente primero)"
    filteredRunners := filteredRunners asSortedCollection: [ :a :b |
        (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ].
    
    "4) Crear Layer 1: Runs"
    self createRunsLayer: filteredRunners 
         onCanvas: canvas 
         atX: 50 
         withBoxSpacing: boxSpacing
         layerBoxes: layerBoxes
         selectedElements: selectedElements
         layerSpacing: layerSpacing
         connections: connections
         layerBorders: layerBorders.
    
    "5) Título principal"
    canvas add: (RSLabel new
        text: 'Layer Design: ', workflowName, ' (', filteredRunners size printString, ' runs)';
        fontSize: 16;
        color: Color black;
        translateTo: 300 @ 20).

    "7) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> layoutRow: row inRect: rect layouts: layouts [
    "Distribuye una fila de elementos en el rectángulo"
    | totalWeight isHorizontal currentPos |
    
    totalWeight := row sum: [ :data | data at: 6 ].
    isHorizontal := rect width >= rect height.
    currentPos := rect origin.
    
    row do: [ :data |
        | elementWeight elementRect workflowName workflowRunners totalTime runCount |
        
        elementWeight := data at: 6.
        
        elementRect := isHorizontal
            ifTrue: [
                | width height |
                width := rect width * elementWeight / totalWeight.
                height := rect height.
                Rectangle origin: currentPos extent: width @ height.
            ]
            ifFalse: [
                | width height |
                width := rect width.
                height := rect height * elementWeight / totalWeight.
                Rectangle origin: currentPos extent: width @ height.
            ].
        
        "Extraer datos del workflow"
        workflowName := data at: 1.
        workflowRunners := data at: 2.
        totalTime := data at: 3.
        runCount := data at: 4.
        
        "Agregar al layout"
        layouts add: {
            workflowName. workflowRunners. totalTime. runCount.
            elementWeight. elementRect origin x. elementRect origin y.
            elementRect width. elementRect height
        }.
        
        "Actualizar posición"
        currentPos := isHorizontal
            ifTrue: [ currentPos + (elementRect width @ 0) ]
            ifFalse: [ currentPos + (0 @ elementRect height) ].
    ]
]

{ #category : 'public' }
GHRunnerCollection >> loadRunnersFromDir: aDirPath [
    | dir worklist files validRunners discardedCount |
    dir := aDirPath asFileReference.
    worklist := OrderedCollection with: dir.
    files := OrderedCollection new.
    
    [ worklist isEmpty ] whileFalse: [
        | current |
        current := worklist removeFirst.
        current isDirectory
            ifTrue: [
                "Si es carpeta, añadir sus hijos a la cola"
                | children |
                children := current children.
                children ifNotEmpty: [ worklist addAll: children ]
            ]
            ifFalse: [
                "Si es fichero y acaba en .json, lo recojo"
                (current extension = 'json')
                    ifTrue: [ files add: current ]
            ].
    ].
    
    "Cargar runners validando que tengan conclusion"
    validRunners := OrderedCollection new.
    discardedCount := 0.
    
    files doWithIndex: [ :file :index |
        [
            | json dict conclusion |
            json := file readStream contents.
            dict := NeoJSONReader fromString: json.
            
            "Verificar que el dict tenga conclusion y no sea nil"
            conclusion := dict at: 'conclusion' ifAbsent: [ nil ].
            conclusion ifNotNil: [
                "Solo crear el GHRunner si tiene conclusion válida"
                validRunners add: (GHRunner fromDictionary: dict).
            ] ifNil: [
                "Contar los descartados"
                discardedCount := discardedCount + 1.
            ].
            
            "Log cada 1000 archivos procesados"
            (index rem: 1000) = 0 ifTrue: [
                Transcript show: 'Progress: ', index printString, '/', files size printString, ' files processed, ', validRunners size printString, ' runners loaded, ', discardedCount printString, ' discarded'; cr.
            ]
        ] on: Error do: [ :ex |
            "Solo log errores de parsing"
            Transcript show: 'Error loading file ', index printString, ': ', file basename, ' - ', ex messageText; cr.
        ]
    ].
    
    runners := validRunners.
    
    "Mostrar resumen completo"
    Transcript show: 'SUMMARY:'; cr.
    Transcript show: 'Total files processed: ', files size printString; cr.
    Transcript show: 'Runners loaded: ', runners size printString; cr.
    Transcript show: 'Runs discarded (no conclusion): ', discardedCount printString; cr.
]

{ #category : 'public' }
GHRunnerCollection >> partitionTreemap: dataArray inRect: rect layouts: layouts [
	"Particiona recursivamente el rectángulo para crear un treemap proporcional al peso real de cada grupo."

	| isWide leftData rightData leftWeight rightWeight splitRatio splitPoint leftRect rightRect cumulativeWeight totalWeight halfWeight |

	dataArray isEmpty ifTrue: [ ^ self ].

	"caso base: un solo elemento"
	dataArray size = 1 ifTrue: [
		| data workflowName workflowRunners totalTime runCount weight |
		data := dataArray first.
		workflowName := data at: 1.
		workflowRunners := data at: 2.
		totalTime := data at: 3.
		runCount := data at: 4.
		weight := data at: 5.

		layouts add: {
			workflowName. workflowRunners. totalTime. runCount.
			weight. rect origin x. rect origin y. rect width. rect height
		}.
		^ self
	].

	"1) Determinar si se divide horizontal o verticalmente"
	isWide := rect width > rect height.

	"2) Dividir el arreglo de datos en dos grupos equilibrados"
	leftData := OrderedCollection new.
	rightData := OrderedCollection new.

	totalWeight := dataArray sum: [:d | d at: 6 ].
	halfWeight := totalWeight / 2.
	cumulativeWeight := 0.

	dataArray do: [:data |
		(cumulativeWeight < halfWeight)
			ifTrue: [
				leftData add: data.
				cumulativeWeight := cumulativeWeight + (data at: 6).
			]
			ifFalse: [ rightData add: data ].
	].

	"3) Asegurar que ambos grupos tengan al menos un elemento"
	leftData isEmpty ifTrue: [ leftData add: rightData removeFirst ].
	rightData isEmpty ifTrue: [ rightData add: leftData removeLast ].

	"4) Calcular pesos reales de ambos grupos"
	leftWeight := leftData sum: [:d | d at: 6 ].
	rightWeight := rightData sum: [:d | d at: 6 ].
	totalWeight := leftWeight + rightWeight.
	splitRatio := leftWeight / totalWeight.

	"5) Calcular punto de corte y subdividir el rectángulo"
	splitPoint := isWide
		ifTrue: [ rect origin x + (rect width * splitRatio) ]
		ifFalse: [ rect origin y + (rect height * splitRatio) ].

	isWide
		ifTrue: [
			leftRect := Rectangle origin: rect origin corner: splitPoint @ rect corner y.
			rightRect := Rectangle origin: splitPoint @ rect origin y corner: rect corner.
		]
		ifFalse: [
			leftRect := Rectangle origin: rect origin corner: rect corner x @ splitPoint.
			rightRect := Rectangle origin: rect origin x @ splitPoint corner: rect corner.
		].

	"6) Llamada recursiva"
	self partitionTreemap: leftData asArray inRect: leftRect layouts: layouts.
	self partitionTreemap: rightData asArray inRect: rightRect layouts: layouts.

]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByConclusionJobsHeight [
    "Visualización poliométrica agrupada por conclusión: Jobs como altura, Tiempo como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por conclusión"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 5.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "5) Normalización: recolectar tiempos y jobs de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Tiempo como ancho, Jobs como altura"
            "Ancho = tiempo de ejecución (se normalizará después)"
            w := (time max: 1).
            "Alto = número de jobs"
            h := (jobs max: 1) * 8.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ANCHO de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer width
            shapes: conclusionBoxes;
            from: 10;
            to: 400;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Conclusion – Polymetric View (', runners size printString, ' total runs. Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByConclusionJobsHeight: workflowName [
    "Visualización poliométrica agrupada por conclusión: Jobs como altura, Tiempo como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing filteredRunners |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    
    "3) Agrupar runners filtrados por conclusión"
    groupedRunners := Dictionary new.
    filteredRunners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "4) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "5) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 10.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "6) Normalización: recolectar tiempos y jobs de los runners filtrados"
    runnerTimes := filteredRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Tiempo como ancho, Jobs como altura"
            "Ancho = tiempo de ejecución (se normalizará después)"
            w := (time max: 1).
            "Alto = número de jobs"
            h := (jobs max: 1) * 8.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ANCHO de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer width
            shapes: conclusionBoxes;
            from: 10;
            to: 400;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión con salto de línea"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa 6000px"
            (conclusionCurrentX + w) > 6000 ifTrue: [
                conclusionCurrentX := 0.
                currentY := currentY + conclusionRowHeight + 20.
                conclusionRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Conclusion – Polymetric View (', runners size printString, ' total runs. Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByConclusionJobsXTimeY: workflowName [
    "Visualización poliométrica agrupada por conclusión: Tiempo como altura, Jobs como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing filteredRunners |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    
    "3) Agrupar runners filtrados por conclusión"
    groupedRunners := Dictionary new.
    filteredRunners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "4) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "5) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 10.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "6) Normalización: recolectar tiempos y jobs de los runners filtrados"
    runnerTimes := filteredRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Jobs como ancho, Tiempo como altura"
            "Ancho = número de jobs"
            w := (jobs max: 1) * 8.
            "Alto = tiempo de ejecución (se normalizará después)"
            h := (time max: 1).
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ALTURA de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer height
            shapes: conclusionBoxes;
            from: 10;
            to: 200;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión con salto de línea"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa 6000px"
            (conclusionCurrentX + w) > 6000 ifTrue: [
                conclusionCurrentX := 0.
                currentY := currentY + conclusionRowHeight + 20.
                conclusionRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'Workflow: ', workflowName, ' by Conclusion (', filteredRunners size printString, ' runs. Jobs on X, Time on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
	 self addExportControlsTo: canvas at: maxWidth + 20 @ 100.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByConclusionJobsYTimeX: workflowName [
    "Visualización poliométrica agrupada por conclusión: Jobs como altura, Tiempo como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing filteredRunners |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    
    "3) Agrupar runners filtrados por conclusión"
    groupedRunners := Dictionary new.
    filteredRunners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "4) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "5) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 10.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "6) Normalización: recolectar tiempos y jobs de los runners filtrados"
    runnerTimes := filteredRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Tiempo como ancho, Jobs como altura"
            "Ancho = tiempo de ejecución (se normalizará después)"
            w := (time max: 1).
            "Alto = número de jobs"
            h := (jobs max: 1) * 8.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ANCHO de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer width
            shapes: conclusionBoxes;
            from: 10;
            to: 400;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión con salto de línea"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa 6000px"
            (conclusionCurrentX + w) > 6000 ifTrue: [
                conclusionCurrentX := 0.
                currentY := currentY + conclusionRowHeight + 20.
                conclusionRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Conclusion – Polymetric View (', runners size printString, ' total runs. Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    self addExportControlsTo: canvas at: maxWidth + 20 @ 100.
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> polymetricViewByConclusionTimeHeight [
    "Visualización poliométrica agrupada por conclusión: Tiempo como altura, Jobs como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por conclusión"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 5.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "5) Normalización: recolectar tiempos y jobs de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Jobs como ancho, Tiempo como altura"
            "Ancho = número de jobs"
            w := (jobs max: 1) * 8.
            "Alto = tiempo de ejecución (se normalizará después)"
            h := (time max: 1).
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ALTURA de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer height
            shapes: conclusionBoxes;
            from: 10;
            to: 200;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión con salto de línea"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa 6000px"
            (conclusionCurrentX + w) > 6000 ifTrue: [
                conclusionCurrentX := 0.
                currentY := currentY + conclusionRowHeight + 20.
                conclusionRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Conclusion – Polymetric View (', runners size printString, ' total runs. Jobs on X, Time on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> polymetricViewByConclusionTimeHeight: workflowName [
    "Visualización poliométrica agrupada por conclusión: Tiempo como altura, Jobs como ancho"
    | canvas groupedRunners minTime maxTime minJobs maxJobs 
      spacing currentX currentY maxWidth rowHeight runnerTimes allBoxes
      conclusionSpacing titleSpacing filteredRunners |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    
    "3) Agrupar runners filtrados por conclusión"
    groupedRunners := Dictionary new.
    filteredRunners do: [ :runner |
        | conclusion conclusionCollection |
        conclusion := runner conclusion.
        conclusionCollection := groupedRunners
            at: conclusion
            ifAbsentPut: [ OrderedCollection new ].
        conclusionCollection add: runner.
    ].
    
    "4) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :conclusion :runnerList |
        groupedRunners
            at: conclusion
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "5) Parámetros de escala"
    minJobs := 1.
    maxJobs := 50.
    spacing := 10.
    conclusionSpacing := 100.
    titleSpacing := 40.
    
    "6) Normalización: recolectar tiempos y jobs de los runners filtrados"
    runnerTimes := filteredRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por conclusiones"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar conclusiones: success, failure, cancelled, etc."
    (groupedRunners keys asSortedCollection) do: [ :conclusion |
        | conclusionRunners conclusionBoxes conclusionCurrentX conclusionRowHeight
          conclusionTitle separator totalTimeLost |
        
        conclusionRunners := groupedRunners at: conclusion.
        conclusionBoxes := OrderedCollection new.
        
        "a) Calcular tiempo perdido para esta conclusión (si es failure)"
        totalTimeLost := 0.
        (conclusion = 'failure') ifTrue: [
            totalTimeLost := conclusionRunners inject: 0 into: [ :sum :runner |
                sum + runner getTotalExecutionTime ].
        ].
        
        "b) Crear título de la conclusión"
        conclusionTitle := RSLabel new
            text: conclusion, ' (', conclusionRunners size printString, ' runs', 
                  (totalTimeLost > 0 ifTrue: [' - Lost: ', (totalTimeLost / 60.0) rounded printString, ' min'] ifFalse: ['']), ')';
            fontSize: 14;
            color: (self getColorForConclusion: conclusion base: Color black);
            translateTo: 10 @ (currentY + 10).
        canvas add: conclusionTitle.
        
        "c) Ajustar Y para las cajas de la conclusión"
        currentY := currentY + titleSpacing.
        conclusionCurrentX := 0.
        conclusionRowHeight := 0.
        
        "d) Crear cajas para esta conclusión"
        conclusionRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones: Jobs como ancho, Tiempo como altura"
            "Ancho = número de jobs"
            w := (jobs max: 1) * 8.
            "Alto = tiempo de ejecución (se normalizará después)"
            h := (time max: 1).
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            conclusionBoxes add: box.
            allBoxes add: box.
        ].
        
        "e) Normalizar ALTURA de las cajas de esta conclusión (tiempo de ejecución)"
        RSNormalizer height
            shapes: conclusionBoxes;
            from: 10;
            to: 200;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "f) Posicionar cajas de la conclusión con salto de línea"
        conclusionBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa 6000px"
            (conclusionCurrentX + w) > 6000 ifTrue: [
                conclusionCurrentX := 0.
                currentY := currentY + conclusionRowHeight + 20.
                conclusionRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (conclusionCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            conclusionCurrentX := conclusionCurrentX + w + spacing.
            maxWidth := maxWidth max: conclusionCurrentX.
            conclusionRowHeight := conclusionRowHeight max: h.
        ].
        
        "g) Ajustar Y para la siguiente conclusión"
        currentY := currentY + conclusionRowHeight + conclusionSpacing.
        
        "h) Agregar línea separadora entre conclusiones"
        separator := RSLine new
            startPoint: 0 @ (currentY - (conclusionSpacing / 2));
            endPoint: maxWidth @ (currentY - (conclusionSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'Workflow: ', workflowName, ' by Conclusion (', filteredRunners size printString, ' runs. Jobs on X, Time on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByWorkflowJobsX: workflowName [
    | canvas filteredRunners minTime maxTime minJobs maxJobs spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes oneHourWidth totalTimeLost |
    
    "1) Filtrar runners por workflow específico"
    filteredRunners := runners select: [ :runner |
        runner workflow name = workflowName ].
    
    "Validar que existan runners para este workflow"
    filteredRunners isEmpty ifTrue: [
        ^ self inform: 'No runs found for workflow: ', workflowName ].
    
    "2) Inicialización"
    canvas := RSCanvas new.
    
    "3) Ordenar por fecha de inicio"
    filteredRunners := filteredRunners asSortedCollection: [ :a :b |
        (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ].
    
    "4) Parámetros de escala"
    minJobs         := 1.
    maxJobs         := 50.
    oneHourWidth    := 3600.  "1 hora = 3600 segundos = ancho máximo antes de wrap"
    lineMaxWidth    := oneHourWidth. "Anchura máxima antes de wrap (1 hora)"
    spacing         := 0.     "Sin espacios horizontales entre runs"
    
    "5) Normalización: recolectar tiempos de los runners filtrados"
    runnerTimes := filteredRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Calcular tiempo perdido total (attempts con conclusion failure)"
    totalTimeLost := filteredRunners inject: 0 into: [ :sum :runner |
        sum + (runner attempts inject: 0 into: [ :attemptSum :attempt |
            (attempt conclusion = 'failure') 
                ifTrue: [ attemptSum + attempt getTotalExecutionTime ]
                ifFalse: [ attemptSum ]
        ])
    ].
    
    "7) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "8) Posicionar las runs"
    currentX := 0.
    currentY := 80.  "Más espacio para el título y estadísticas"
    maxWidth := 0.
    rowHeight := 0.
    
    "9) Crear cajas para las runs del workflow"
    filteredRunners do: [ :runner |
        | jobs time steps w h color box |
        
        "Métricas"
        time := runner getTotalExecutionTime.
        jobs := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs size) ].
        steps := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
        
        "Calcular dimensiones - EJES INVERTIDOS"
        "Ancho = tiempo de ejecución (proporcional)"
        w := (time max: 1).  "Se normalizará después"
        "Alto = número de jobs"
        h := (jobs max: 1) * 10.
        
        "Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "Crear caja"
        box := RSBox new
            width: w;
            height: h;
            color: color;
            model: runner.
        
        "Popup con info"
        box @ (RSPopup text: [ :r |
            'Name: ', r name asString, String cr,
            'Workflow: ', r workflow name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Status: ', r status asString, String cr,
            'Execution Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "Click para detalles"
        box @ RSHighlightable new.
        box
            when: RSMouseClick
            do: [ :evt | self showRunnerDetails: evt shape model ]
            for: self.
        
        allBoxes add: box.
    ].
    
    "10) Normalizar ANCHO de las cajas (tiempo de ejecución)"
    RSNormalizer width
        shapes: allBoxes;
        from: 10;  "Ancho mínimo"
        to: 600;   "Ancho máximo"
        normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
    
    "11) Posicionar cajas"
    allBoxes do: [ :box |
        | w h |
        w := box width.
        h := box height.
        
        "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth (1 hora)"
        (currentX + w) > lineMaxWidth ifTrue: [
            currentX := 0.
            currentY := currentY + rowHeight + 20.  "Espacio vertical entre filas"
            rowHeight := 0.
        ].
        
        "Posicionar caja"
        box translateTo: (currentX + (w / 2)) @ (currentY + (h / 2)).
        
        "Agregar al canvas"
        canvas add: box.
        
        "Actualizar coordenadas - SIN SPACING horizontal"
        currentX := currentX + w + spacing.
        maxWidth := maxWidth max: currentX.
        rowHeight := rowHeight max: h.
    ].
    
    "12) Título principal"
    canvas add: (RSLabel new
        text: 'Workflow: ', workflowName, ' (', filteredRunners size printString, ' runs - Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ 10).
    
    "13) Mostrar tiempo perdido total"
    canvas add: (RSLabel new
        text: 'Total Time Lost (failures): ', (totalTimeLost / 60.0) rounded printString, ' minutes (', totalTimeLost printString, ' seconds)';
        fontSize: 14;
        color: Color red;
        translateTo: (maxWidth / 2) @ 30).
    
    "14) Mostrar estadísticas adicionales"
    canvas add: (RSLabel new
        text: 'Total Execution Time: ', (runnerTimes sum / 60.0) rounded printString, ' minutes | Loss Rate: ', ((totalTimeLost / runnerTimes sum) * 100.0) rounded printString, '%';
        fontSize: 12;
        color: Color darkGray;
        translateTo: (maxWidth / 2) @ 50).
    
    "15) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 80.
    
    "16) Agregar indicador de escala de tiempo"
    canvas add: (RSLabel new
        text: 'Max width = 1 hour';
        fontSize: 12;
        color: Color gray;
        translateTo: (maxWidth / 2) @ 65).
    
    "17) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByWorkflowsJobsX [
    | canvas groupedRunners minTime maxTime minJobs maxJobs spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes workflowSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por workflow"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | workflowName workflowCollection |
        workflowName := runner workflow name.
        workflowCollection := groupedRunners
            at: workflowName
            ifAbsentPut: [ OrderedCollection new ].
        workflowCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :workflowName :runnerList |
        groupedRunners
            at: workflowName
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minJobs         := 1.
    maxJobs         := 50.
    lineMaxWidth    := 6000.  "Ancho máximo fijo de 6000px"
    spacing         := 10.    "Espacios horizontales entre runs"
    workflowSpacing := 100.   "Espacio extra entre workflows"
    titleSpacing    := 40.    "Espacio para títulos de workflow"
    
    "5) Normalización: recolectar tiempos de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por workflows"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar workflows por nombre para consistencia"
    (groupedRunners keys asSortedCollection) do: [ :workflowName |
        | workflowRunners workflowBoxes workflowCurrentX workflowRowHeight workflowTitle separator |
        
        workflowRunners := groupedRunners at: workflowName.
        workflowBoxes := OrderedCollection new.
        
        "a) Crear título del workflow"
        workflowTitle := RSLabel new
            text: workflowName, ' (', workflowRunners size printString, ' runs)';
            fontSize: 14;
            color: Color blue;
            translateTo: 10 @ (currentY + 10).
        canvas add: workflowTitle.
        
        "b) Ajustar Y para las cajas del workflow"
        currentY := currentY + titleSpacing.
        workflowCurrentX := 0.
        workflowRowHeight := 0.
        
        "c) Crear cajas para este workflow"
        workflowRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones - EJES INVERTIDOS"
            "Ancho = tiempo de ejecución (proporcional)"
            w := (time max: 1).  "Se normalizará después"
            "Alto = número de jobs"
            h := (jobs max: 1) * 10.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            workflowBoxes add: box.
            allBoxes add: box.
        ].
        
        "d) Normalizar ANCHO de las cajas de este workflow (tiempo de ejecución)"
        RSNormalizer width
            shapes: workflowBoxes;
            from: 10;  "Ancho mínimo"
            to: 600;   "Ancho máximo"
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "e) Posicionar cajas del workflow"
        workflowBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth (6000px)"
            (workflowCurrentX + w) > lineMaxWidth ifTrue: [
                workflowCurrentX := 0.
                currentY := currentY + workflowRowHeight + 20.  "Espacio vertical entre filas"
                workflowRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (workflowCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas con spacing horizontal"
            workflowCurrentX := workflowCurrentX + w + spacing.
            maxWidth := maxWidth max: workflowCurrentX.
            workflowRowHeight := workflowRowHeight max: h.
        ].
        
        "f) Ajustar Y para el siguiente workflow"
        currentY := currentY + workflowRowHeight + workflowSpacing.
        
        "g) Agregar línea separadora entre workflows (opcional)"
        separator := RSLine new
            startPoint: 0 @ (currentY - (workflowSpacing / 2));
            endPoint: maxWidth @ (currentY - (workflowSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Workflow – Polymetric View (', runners size printString, ' total runs. Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda actualizada"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Agregar indicador de escala"
    canvas add: (RSLabel new
        text: 'Max width = 6000px';
        fontSize: 12;
        color: Color gray;
        translateTo: (maxWidth / 2) @ -10).
    
    "11) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByWorkflowsJobsXTimeY [
    | canvas groupedRunners minTime maxTime minJobs maxJobs spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes workflowSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por workflow"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | workflowName workflowCollection |
        workflowName := runner workflow name.
        workflowCollection := groupedRunners
            at: workflowName
            ifAbsentPut: [ OrderedCollection new ].
        workflowCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :workflowName :runnerList |
        groupedRunners
            at: workflowName
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minJobs         := 1.
    maxJobs         := 50.
    lineMaxWidth    := 6000.  "Ancho máximo fijo de 6000px"
    spacing         := 10.    "Espacios horizontales entre runs"
    workflowSpacing := 100.   "Espacio extra entre workflows"
    titleSpacing    := 40.    "Espacio para títulos de workflow"
    
    "5) Normalización: recolectar tiempos de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por workflows"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar workflows por nombre para consistencia"
    (groupedRunners keys asSortedCollection) do: [ :workflowName |
        | workflowRunners workflowBoxes workflowCurrentX workflowRowHeight workflowTitle separator |
        
        workflowRunners := groupedRunners at: workflowName.
        workflowBoxes := OrderedCollection new.
        
        "a) Crear título del workflow"
        workflowTitle := RSLabel new
            text: workflowName, ' (', workflowRunners size printString, ' runs)';
            fontSize: 14;
            color: Color blue;
            translateTo: 10 @ (currentY + 10).
        canvas add: workflowTitle.
        
        "b) Ajustar Y para las cajas del workflow"
        currentY := currentY + titleSpacing.
        workflowCurrentX := 0.
        workflowRowHeight := 0.
        
        "c) Crear cajas para este workflow"
        workflowRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones - EJES INTERCAMBIADOS"
            "Ancho = número de jobs"
            w := (jobs max: 1) * 10.
            "Alto = tiempo de ejecución (proporcional)"
            h := (time max: 1).  "Se normalizará después"
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            workflowBoxes add: box.
            allBoxes add: box.
        ].
        
        "d) Normalizar ALTO de las cajas de este workflow (tiempo de ejecución)"
        RSNormalizer height
            shapes: workflowBoxes;
            from: 10;  "Alto mínimo"
            to: 600;   "Alto máximo"
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "e) Posicionar cajas del workflow"
        workflowBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth (6000px)"
            (workflowCurrentX + w) > lineMaxWidth ifTrue: [
                workflowCurrentX := 0.
                currentY := currentY + workflowRowHeight + 20.  "Espacio vertical entre filas"
                workflowRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (workflowCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas con spacing horizontal"
            workflowCurrentX := workflowCurrentX + w + spacing.
            maxWidth := maxWidth max: workflowCurrentX.
            workflowRowHeight := workflowRowHeight max: h.
        ].
        
        "f) Ajustar Y para el siguiente workflow"
        currentY := currentY + workflowRowHeight + workflowSpacing.
        
        "g) Agregar línea separadora entre workflows (opcional)"
        separator := RSLine new
            startPoint: 0 @ (currentY - (workflowSpacing / 2));
            endPoint: maxWidth @ (currentY - (workflowSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Workflow – Polymetric View (', runners size printString, ' total runs. Jobs on X, Time on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda actualizada"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Agregar indicador de escala"
    canvas add: (RSLabel new
        text: 'Max width = 6000px';
        fontSize: 12;
        color: Color gray;
        translateTo: (maxWidth / 2) @ -10).

	 self addExportControlsTo: canvas at: maxWidth + 20 @ 100.
    
    "11) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> polymetricViewByWorkflowsJobsYTimeX [
    | canvas groupedRunners minTime maxTime minJobs maxJobs spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes workflowSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por workflow"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | workflowName workflowCollection |
        workflowName := runner workflow name.
        workflowCollection := groupedRunners
            at: workflowName
            ifAbsentPut: [ OrderedCollection new ].
        workflowCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :workflowName :runnerList |
        groupedRunners
            at: workflowName
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) >= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minJobs         := 1.
    maxJobs         := 50.
    lineMaxWidth    := 6000.  "Ancho máximo fijo de 6000px"
    spacing         := 10.    "Espacios horizontales entre runs"
    workflowSpacing := 100.   "Espacio extra entre workflows"
    titleSpacing    := 40.    "Espacio para títulos de workflow"
    
    "5) Normalización: recolectar tiempos de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por workflows"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar workflows por nombre para consistencia"
    (groupedRunners keys asSortedCollection) do: [ :workflowName |
        | workflowRunners workflowBoxes workflowCurrentX workflowRowHeight workflowTitle separator |
        
        workflowRunners := groupedRunners at: workflowName.
        workflowBoxes := OrderedCollection new.
        
        "a) Crear título del workflow"
        workflowTitle := RSLabel new
            text: workflowName, ' (', workflowRunners size printString, ' runs)';
            fontSize: 14;
            color: Color blue;
            translateTo: 10 @ (currentY + 10).
        canvas add: workflowTitle.
        
        "b) Ajustar Y para las cajas del workflow"
        currentY := currentY + titleSpacing.
        workflowCurrentX := 0.
        workflowRowHeight := 0.
        
        "c) Crear cajas para este workflow"
        workflowRunners do: [ :runner |
            | jobs time steps w h color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular dimensiones - EJES INVERTIDOS"
            "Ancho = tiempo de ejecución (proporcional)"
            w := (time max: 1).  "Se normalizará después"
            "Alto = número de jobs"
            h := (jobs max: 1) * 10.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: h;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            workflowBoxes add: box.
            allBoxes add: box.
        ].
        
        "d) Normalizar ANCHO de las cajas de este workflow (tiempo de ejecución)"
        RSNormalizer width
            shapes: workflowBoxes;
            from: 10;  "Ancho mínimo"
            to: 600;   "Ancho máximo"
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "e) Posicionar cajas del workflow"
        workflowBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth (6000px)"
            (workflowCurrentX + w) > lineMaxWidth ifTrue: [
                workflowCurrentX := 0.
                currentY := currentY + workflowRowHeight + 20.  "Espacio vertical entre filas"
                workflowRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (workflowCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas con spacing horizontal"
            workflowCurrentX := workflowCurrentX + w + spacing.
            maxWidth := maxWidth max: workflowCurrentX.
            workflowRowHeight := workflowRowHeight max: h.
        ].
        
        "f) Ajustar Y para el siguiente workflow"
        currentY := currentY + workflowRowHeight + workflowSpacing.
        
        "g) Agregar línea separadora entre workflows (opcional)"
        separator := RSLine new
            startPoint: 0 @ (currentY - (workflowSpacing / 2));
            endPoint: maxWidth @ (currentY - (workflowSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Workflow – Polymetric View (', runners size printString, ' total runs. Time on X, Jobs on Y)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda actualizada"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Agregar indicador de escala"
    canvas add: (RSLabel new
        text: 'Max width = 6000px';
        fontSize: 12;
        color: Color gray;
        translateTo: (maxWidth / 2) @ -10).

    self addExportControlsTo: canvas at: maxWidth + 20 @ 100.
    "11) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewByWorkflowsStepsX [
    | canvas groupedRunners
      minTime maxTime minHeight maxHeight
      spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes
      workflowSpacing titleSpacing |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    
    "2) Agrupar runners por workflow"
    groupedRunners := Dictionary new.
    runners do: [ :runner |
        | workflowName workflowCollection |
        workflowName := runner workflow name.
        workflowCollection := groupedRunners
            at: workflowName
            ifAbsentPut: [ OrderedCollection new ].
        workflowCollection add: runner.
    ].
    
    "3) Ordenar cada grupo por fecha de inicio"
    groupedRunners keysAndValuesDo: [ :workflowName :runnerList |
        groupedRunners
            at: workflowName
            put: (runnerList asSortedCollection: [ :a :b |
                (a getMostRecentStartedAt) <= (b getMostRecentStartedAt) ]).
    ].
    
    "4) Parámetros de escala"
    minHeight       := 50.
    maxHeight       := 200.
    lineMaxWidth    := 6000. "Anchura máxima antes de wrap"
    spacing         := 30.
    workflowSpacing := 80.   "Espacio extra entre workflows"
    titleSpacing    := 40.   "Espacio para títulos de workflow"
    
    "5) Normalización: recolectar tiempos de TODOS los runners"
    runnerTimes := runners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "6) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    
    "7) Posicionar por workflows"
    currentX := 0.
    currentY := 0.
    maxWidth := 0.
    
    "Ordenar workflows por nombre para consistencia"
    (groupedRunners keys asSortedCollection) do: [ :workflowName |
        | workflowRunners workflowBoxes workflowCurrentX workflowRowHeight workflowTitle separator |
        
        workflowRunners := groupedRunners at: workflowName.
        workflowBoxes := OrderedCollection new.
        
        "a) Crear título del workflow"
        workflowTitle := RSLabel new
            text: workflowName, ' (', workflowRunners size printString, ' runs)';
            fontSize: 14;
            color: Color blue;
            translateTo: 10 @ (currentY + 10).
        canvas add: workflowTitle.
        
        "b) Ajustar Y para las cajas del workflow"
        currentY := currentY + titleSpacing.
        workflowCurrentX := 0.
        workflowRowHeight := 0.
        
        "c) Crear cajas para este workflow"
        workflowRunners do: [ :runner |
            | jobs time steps w color box |
            
            "Métricas"
            time := runner getTotalExecutionTime.
            jobs := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs size) ].
            steps := runner attempts
                inject: 0 into: [ :sum :att |
                    sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
            
            "Calcular ancho"
            w := (steps max: 1) * 10.
            
            "Color según conclusión"
            color := self getColorForConclusion: runner conclusion base: Color white.
            
            "Crear caja"
            box := RSBox new
                width: w;
                height: minHeight;
                color: color;
                model: runner.
            
            "Popup con info"
            box @ (RSPopup text: [ :r |
                'Name: ', r name asString, String cr,
                'Workflow: ', r workflow name asString, String cr,
                'Conclusion: ', r conclusion asString, String cr,
                'Status: ', r status asString, String cr,
                'Execution Time: ', time asString, 's', String cr,
                'Jobs: ', jobs asString, String cr,
                'Steps: ', steps asString ]).
            
            "Click para detalles"
            box @ RSHighlightable new.
            box
                when: RSMouseClick
                do: [ :evt | self showRunnerDetails: evt shape model ]
                for: self.
            
            workflowBoxes add: box.
            allBoxes add: box.
        ].
        
        "d) Normalizar altura de las cajas de este workflow"
        RSNormalizer height
            shapes: workflowBoxes;
            from: minHeight;
            to: maxHeight;
            normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
        
        "e) Posicionar cajas del workflow"
        workflowBoxes do: [ :box |
            | w h |
            w := box width.
            h := box height.
            
            "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth"
            (workflowCurrentX + w) > lineMaxWidth ifTrue: [
                workflowCurrentX := 0.
                currentY := currentY + workflowRowHeight + spacing.
                workflowRowHeight := 0.
            ].
            
            "Posicionar caja"
            box translateTo: (workflowCurrentX + (w / 2)) @ (currentY + (h / 2)).
            
            "Agregar al canvas"
            canvas add: box.
            
            "Actualizar coordenadas"
            workflowCurrentX := workflowCurrentX + w + spacing.
            maxWidth := maxWidth max: workflowCurrentX.
            workflowRowHeight := workflowRowHeight max: h.
        ].
        
        "f) Ajustar Y para el siguiente workflow"
        currentY := currentY + workflowRowHeight + workflowSpacing.
        
        "g) Agregar línea separadora entre workflows (opcional)"
        separator := RSLine new
            startPoint: 0 @ (currentY - (workflowSpacing / 2));
            endPoint: maxWidth @ (currentY - (workflowSpacing / 2));
            color: Color lightGray.
        canvas add: separator.
    ].
    
    "8) Título principal"
    canvas add: (RSLabel new
        text: 'GH Runs by Workflow – Polymetric View (', runners size printString, ' total runs. Steps on X)';
        fontSize: 18;
        color: Color black;
        translateTo: (maxWidth / 2) @ -30).
    
    "9) Leyenda"
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "10) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'as yet unclassified' }
GHRunnerCollection >> polymetricViewJobsX [
    | canvas sortedRunners
      minTime maxTime minHeight maxHeight
      spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    sortedRunners := runners
        asSortedCollection: [ :a :b |
            (a getMostRecentStartedAt) <= (b getMostRecentStartedAt) ].
    
    "2) Parámetros de escala"
    minHeight    := 50.
    maxHeight    := 200.
    lineMaxWidth := 3000. "Anchura máxima antes de wrap"
    spacing      := 30.
    
    "3) Normalización: recolectar tiempos"
    runnerTimes := sortedRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "4) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    sortedRunners do: [ :runner |
        | steps time jobs w color box |
        
        "a) Métricas"
        time  := runner getTotalExecutionTime.
		  jobs := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs size) ].

        steps := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
        
        "b) Calcular ancho (altura será normalizada después)"
        w := (jobs max: 1) * 10.  "10 px por jobs"
        
        "c) Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "d) Crear caja con altura temporal"
        box := RSBox new
            width: w;
            height: minHeight;  "Altura temporal, será normalizada"
            color: color;
            model: runner.
        
        "e) Popup con info"
        box @ (RSPopup text: [ :r |
            'Name: ', r name asString, String cr,
            'Workflow: ', r workflow name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Status: ', r status asString, String cr,
            'Execution Time: ', time asString, 's', String cr,
            'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "f) Click para detalles"
        box @ RSHighlightable new.
        box
            when: RSMouseClick
            do: [ :evt | self showRunnerDetails: evt shape model ]
            for: self.
        
        allBoxes add: box.
    ].
    
    "5) ÚNICA normalización de altura"
    RSNormalizer height
        shapes: allBoxes;
        from: minHeight;
        to: maxHeight;
        normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
    
    "6) Posicionar cajas DESPUÉS de la normalización"
    currentX  := 0.
    currentY  := 0.
    maxWidth  := 0.
    rowHeight := 0.
    
    allBoxes do: [ :box |
        | w h |
        w := box width.
        h := box height.  "Ahora h tiene el valor correcto post-normalización"
        
        "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth"
        (currentX + w) > lineMaxWidth ifTrue: [
            currentX := 0.
            currentY := currentY + rowHeight + spacing.
            rowHeight := 0.  "Resetear rowHeight para la nueva fila"
        ].
        
        "Posicionar caja usando translateTo (centro de la caja)"
        box translateTo: (currentX + (w / 2)) @ (currentY + (h / 2)).
        
        "Agregar al canvas"
        canvas add: box.
        
        "Actualizar coordenadas para la siguiente caja"
        currentX := currentX + w + spacing.
        maxWidth := maxWidth max: currentX.
        rowHeight := rowHeight max: h.
    ].
    
    "7) Título y leyenda"
    canvas add: (RSLabel new
        text: 'GH Runs – Polymetric View (', runners size printString, ') (Jobs on X axis)';
        fontSize: 24;
        color: Color black;
        translateTo: (maxWidth / 2) @ -22).
    
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "8) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewMolecular [
	| canvas sortedRunners gridWidth currentX currentY maxWidth rowHeight |
	canvas := RSCanvas new.
	sortedRunners := runners asSortedCollection: [ :a :b |
		                 a runStartedAt >= b runStartedAt ].
	gridWidth := 8. "8 por fila para dar más espacio"
	currentX := 0.
	currentY := 0.
	maxWidth := 0.
	rowHeight := 0.
	
	sortedRunners withIndexDo: [ :runner :index |
		| moleculeGroup nucleusSize nucleusColor totalSize nucleus |
		
		"Calcular tamaño del núcleo basado en runAttempt"
		nucleusSize := (runner runAttempt) * 36. "Escala para visualizacion"
		
		"Color del núcleo según conclusión general"
		nucleusColor := self getNucleusColorFor: runner.
		
		"Crear grupo para la molécula completa"
		moleculeGroup := RSGroup new.
		
		"Núcleo central"
		nucleus := RSCircle new
			size: nucleusSize;
			color: nucleusColor;
			border: (RSBorder new
				color: Color black;
				width: 2);
			model: runner.
		moleculeGroup add: nucleus.
		
		"Crear visualización según cantidad de jobs"
		self createAtomicVisualizationFor: runner 
			 inGroup: moleculeGroup 
			 withNucleusSize: nucleusSize.
		
		"Posicionar la molécula completa en el grid"
		totalSize := self calculateMoleculeSize: runner withNucleusSize: nucleusSize.
		moleculeGroup translateTo: 
			(currentX + (totalSize / 2)) @ (currentY + (totalSize / 2)).
		
		"Agregar interacciones generales"
		"moleculeGroup @ (RSPopup text: [ :r |
			self getMolecularPopupTextFor: runner ])."
		
		"nucleus @ RSHighlightable new.
		nucleus
			when: RSMouseClick
			do: [ :evt | self showRunnerDetails: evt shape model ]
			for: self."
		
		canvas addAll: moleculeGroup.
		
		"Actualizar posición para siguiente molécula"
		currentX := currentX + totalSize + 10.
		maxWidth := maxWidth max: currentX.
		rowHeight := rowHeight max: totalSize.
		
		index \\ gridWidth = 0 ifTrue: [
			currentX := 0.
			currentY := currentY + rowHeight + 10.
			rowHeight := 0 ]
	].
	
	"Título y leyenda"
	canvas add: (RSLabel new
		text: 'GH Runners - Atomic View (', self runners size printString, ')';
		fontSize: 16;
		color: Color black;
		translateTo: maxWidth / 2 @ -30).
	
	self addAtomicLegendTo: canvas at: maxWidth + 20 @ 0.
	canvas @ RSCanvasController.
	^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> polymetricViewStepsX [
    | canvas sortedRunners
      minTime maxTime minHeight maxHeight
      spacing currentX currentY maxWidth rowHeight lineMaxWidth runnerTimes allBoxes |
    
    "1) Inicialización"
    canvas := RSCanvas new.
    sortedRunners := runners
        asSortedCollection: [ :a :b |
            (a getMostRecentStartedAt) <= (b getMostRecentStartedAt) ].
    
    "2) Parámetros de escala"
    minHeight    := 50.
    maxHeight    := 200.
    lineMaxWidth := 3000. "Anchura máxima antes de wrap"
    spacing      := 30.
    
    "3) Normalización: recolectar tiempos"
    runnerTimes := sortedRunners collect: [ :r | r getTotalExecutionTime ].
    minTime := runnerTimes min.
    maxTime := runnerTimes max.
    
    "4) Crear todas las cajas primero (sin agregar al canvas)"
    allBoxes := OrderedCollection new.
    sortedRunners do: [ :runner |
        | jobs time steps w color box |
        
        "a) Métricas"
        time  := runner getTotalExecutionTime.
		  jobs := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs size) ].
        steps := runner attempts
            inject: 0 into: [ :sum :att |
                sum + (att jobs inject: 0 into: [ :s :j | s + j steps size ]) ].
        
        "b) Calcular ancho (altura será normalizada después)"
        w := (steps max: 1) * 10.  "10 px por step"
        
        "c) Color según conclusión"
        color := self getColorForConclusion: runner conclusion base: Color white.
        
        "d) Crear caja con altura temporal"
        box := RSBox new
            width: w;
            height: minHeight;  "Altura temporal, será normalizada"
            color: color;
            model: runner.
        
        "e) Popup con info"
        box @ (RSPopup text: [ :r |
            'Name: ', r name asString, String cr,
            'Workflow: ', r workflow name asString, String cr,
            'Conclusion: ', r conclusion asString, String cr,
            'Status: ', r status asString, String cr,
            'Execution Time: ', time asString, 's', String cr,
			   'Jobs: ', jobs asString, String cr,
            'Steps: ', steps asString ]).
        
        "f) Click para detalles"
        box @ RSHighlightable new.
        box
            when: RSMouseClick
            do: [ :evt | self showRunnerDetails: evt shape model ]
            for: self.
        
        allBoxes add: box.
    ].
    
    "5) ÚNICA normalización de altura"
    RSNormalizer height
        shapes: allBoxes;
        from: minHeight;
        to: maxHeight;
        normalize: [ :runnerModel | runnerModel getTotalExecutionTime ].
    
    "6) Posicionar cajas DESPUÉS de la normalización"
    currentX  := 0.
    currentY  := 0.
    maxWidth  := 0.
    rowHeight := 0.
    
    allBoxes do: [ :box |
        | w h |
        w := box width.
        h := box height.  "Ahora h tiene el valor correcto post-normalización"
        
        "Wrap de línea si la siguiente caja sobrepasa lineMaxWidth"
        (currentX + w) > lineMaxWidth ifTrue: [
            currentX := 0.
            currentY := currentY + rowHeight + spacing.
            rowHeight := 0.  "Resetear rowHeight para la nueva fila"
        ].
        
        "Posicionar caja usando translateTo (centro de la caja)"
        box translateTo: (currentX + (w / 2)) @ (currentY + (h / 2)).
        
        "Agregar al canvas"
        canvas add: box.
        
        "Actualizar coordenadas para la siguiente caja"
        currentX := currentX + w + spacing.
        maxWidth := maxWidth max: currentX.
        rowHeight := rowHeight max: h.
    ].
    
    "7) Título y leyenda"
    canvas add: (RSLabel new
        text: 'GH Runs – Polymetric View (', runners size printString, ') (Steps on X axis)';
        fontSize: 24;
        color: Color black;
        translateTo: (maxWidth / 2) @ -22).
    
    self addLegendTo: canvas at: maxWidth + 20 @ 0.
    
    "8) Mostrar"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> positionAttemptBoxes: attemptBoxes withinRunBox: runBox spacing: spacing on: canvas [
    "Posiciona los attemptBoxes dentro del runBox, uno tras otro en filas"
    | runBoxBounds margin currentX currentY maxRowHeight availableWidth |
    margin := 5.
    runBoxBounds := runBox encompassingRectangle.
    
    "Inicializar posiciones"
    currentX := runBoxBounds left + margin.
    currentY := runBoxBounds top + margin.
    maxRowHeight := 0.
    availableWidth := runBoxBounds width - (2 * margin).
    
    attemptBoxes do: [ :attemptBox |
        | attemptWidth attemptHeight |
        attemptWidth := attemptBox width.
        attemptHeight := attemptBox height.
        
        "Verificar si cabe en la fila actual"
        ((currentX - runBoxBounds left - margin + attemptWidth) > availableWidth) ifTrue: [
            "Pasar a la siguiente fila"
            currentX := runBoxBounds left + margin.
            currentY := currentY + maxRowHeight + spacing.
            maxRowHeight := 0.
        ].
        
        "Posicionar el attemptBox"
        attemptBox translateTo: currentX + (attemptWidth / 2) @ (currentY + (attemptHeight / 2)).
        canvas add: attemptBox.
        
        "Actualizar posición para el siguiente attemptBox"
        currentX := currentX + attemptWidth + spacing.
        maxRowHeight := maxRowHeight max: attemptHeight.
    ].
]

{ #category : 'public' }
GHRunnerCollection >> positionInnerRectangles: attemptsBoxes 
                 jobsBoxes: jobsBoxes 
                 stepsBoxes: stepsBoxes
                 withinRunBox: runBox 
                 on: canvas [
    | runBoxPos runBoxWidth sectionPadding rectHeight innerSpacing currentY startY borderWidth |
    
    runBoxPos := runBox position.
    runBoxWidth := runBox width.
    sectionPadding := 6.
    rectHeight := 4. "Mismo valor que en buildRunnerBoxesFrom"
    innerSpacing := 0. "Separación entre rectángulos del mismo grupo"
	 borderWidth := 2.
    
    "Comenzar desde la parte superior del runBox"
    startY := (runBoxPos y - (runBox height / 2) + (rectHeight / 2)) + borderWidth .
    currentY := startY.
    
    "─── 1) Posicionar rectángulos de attempts (vertical stack) ───"
    attemptsBoxes withIndexDo: [ :attBox :index |
        attBox translateTo: runBoxPos x @ currentY.
        canvas add: attBox.
        currentY := currentY + rectHeight.
        
        "Agregar separación interna entre attempts (excepto el último)"
        (index < attemptsBoxes size) ifTrue: [ 
            currentY := currentY + innerSpacing ].
    ].
    
    "Agregar separación entre secciones si hay attempts"
    attemptsBoxes ifNotEmpty: [ currentY := currentY + sectionPadding ].
    
    "─── 2) Posicionar rectángulos de jobs (vertical stack) ───"
    jobsBoxes withIndexDo: [ :jobBox :index |
        jobBox translateTo: runBoxPos x @ currentY.
        canvas add: jobBox.
        currentY := currentY + rectHeight.
        
        "Agregar separación interna entre jobs (excepto el último)"
        (index < jobsBoxes size) ifTrue: [ 
            currentY := currentY + innerSpacing ].
    ].
    
    "Agregar separación entre secciones si hay jobs"
    jobsBoxes ifNotEmpty: [ currentY := currentY + sectionPadding ].
    
    "─── 3) Posicionar rectángulos de steps (vertical stack) ───"
    stepsBoxes withIndexDo: [ :stepBox :index |
        stepBox translateTo: runBoxPos x @ currentY.
        canvas add: stepBox.
        currentY := currentY + rectHeight.
        
        "Agregar separación interna entre steps (excepto el último)"
        (index < stepsBoxes size) ifTrue: [ 
            currentY := currentY + innerSpacing ].
    ].
]

{ #category : 'rendering' }
GHRunnerCollection >> renderTreemap: layoutData
         on: canvas
withRunnerBoxes: runnerBoxes
         colors: aColorArray [
    | margin spacing |
    margin := 20.
    spacing := 10.
    layoutData withIndexDo: [ :entry :widx |
        | key runnerData x y w h color currentX currentY rowMaxH container label
          layoutSize neededW neededH runBoxes |
        key   := entry at: 1.
        runnerData := runnerBoxes at: key.
        
        "Extraer runBoxes - runnerData es una colección de diccionarios"
        runBoxes := runnerData collect: [ :dict | dict at: #runBox ].
        
        x     := entry at: 6.
        y     := entry at: 7.
        w     := entry at: 8.
        h     := entry at: 9.
        color := aColorArray at: ((widx-1) \\ aColorArray size) + 1.
        
        "─── 1) Calcular si necesitamos más altura ───"
        neededW := w - (2 * margin).
        layoutSize := self
            estimateRequiredGridSizeFor: runBoxes
            maxRowWidth: neededW
            spacing: spacing.
        neededH := layoutSize y + (2 * margin).
        
        "Si la altura real que necesitamos (neededH) supera la del layout, la estiramos"
        h := neededH max: h.
        
        "─── 2) Dibujo el contenedor con la altura posiblemente ajustada ───"
        container := RSBox new
            width: w; height: h;
            color: Color transparent;
            border: (RSBorder new color: color darker; width: 3);
            model: entry.
        container translateTo: x + (w / 2) @ (y + (h / 2)).
        canvas add: container.
        
        "─── 3) Etiqueta ───"
        label := RSLabel new
            text: key; fontSize: 12; bold.
        label translateTo: x + (w / 2) @ (y + margin).
        canvas add: label.
        
        "─── 4) Posicionar runBoxes en grid ───"
        currentX := x + margin.
        currentY := y + (margin * 2).
        rowMaxH  := 0.
        
        runnerData withIndexDo: [ :runDict :index |
            | runBox attemptsBoxes jobsBoxes stepsBoxes bx by |
            runBox := runDict at: #runBox.
            attemptsBoxes := runDict at: #attemptsBoxes.
            jobsBoxes := runDict at: #jobsBoxes.
            stepsBoxes := runDict at: #stepsBoxes.
            
            bx := runBox width.
            by := runBox height.
            
            "Verificar si cabe en la fila actual"
            ((currentX + bx) > (x + w - margin)) ifTrue: [
                currentX := x + margin.
                currentY := currentY + rowMaxH + spacing.
                rowMaxH := 0.
            ].
            
            "Posicionar el runBox"
            runBox translateTo: currentX + (bx / 2) @ (currentY + (by / 2)).
            canvas add: runBox.
            
            "Posicionar los rectángulos interiores dentro del runBox"
            self positionInnerRectangles: attemptsBoxes 
                 jobsBoxes: jobsBoxes 
                 stepsBoxes: stepsBoxes
                 withinRunBox: runBox 
                 on: canvas.
            
            "Actualizar posición para el siguiente runBox"
            currentX := currentX + bx + spacing.
            rowMaxH := rowMaxH max: by.
        ].
    ].
    "Vuelve a inyectar el controller antes de abrir"
    canvas @ RSCanvasController.
    ^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> repositionRectanglesAfterNormalization: rectangles groupedBy: groupedRunners [
	"Reposiciona todos los rectángulos tras normalizar alturas, sin solapamientos"
	| rectanglesByWorkflow currentY marginX marginY spacingBetweenWorkflows |

	marginX := 20.
	marginY := 250.
	spacingBetweenWorkflows := 200.

	"Agrupar rectángulos según su workflow"
	rectanglesByWorkflow :=
		groupedRunners collect: [ :assoc |
			assoc key -> (rectangles select: [ :r |
				r model workflow name = assoc key ]) ].

	currentY := 50.

	rectanglesByWorkflow do: [ :pair |
		| workflowRects currentX |
		workflowRects := pair value.
		currentX := marginX.

		"Recorrer en filas de hasta 10"
		1 to: workflowRects size by: 10 do: [ :start |
			| end rowRects maxH |
			end := (start + 9) min: workflowRects size.
			rowRects := workflowRects copyFrom: start to: end.

			"Determinar altura máxima de la fila"
			maxH := rowRects inject: 0 into: [ :m :r | m max: r height ].

			"Reposicionar cada rectángulo"
			rowRects do: [ :rect |
				| centerY |
				centerY := currentY + (rect height / 2).
				rect translateTo: (currentX + rect width / 2) @ centerY.
				currentX := currentX + rect width + marginY ] .

			"Bajar Y para la siguiente fila"
			currentY := currentY + maxH + marginY.
			currentX := marginX ] .

		"Espacio extra tras cada workflow"
		currentY := currentY + spacingBetweenWorkflows ] .

	^ rectangles

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
GHRunnerCollection >> showDepthRunnerDetails: runner [
    "Abre una nueva ventana canvas mostrando solo la molécula del runner seleccionado"
    | detailCanvas detailGroup titleLabel |

    "1) Creo el canvas de la ventana"
    detailCanvas := RSCanvas new.

    "2) Creo un grupo independiente para dibujar la molécula detallada"
    detailGroup := RSGroup new.

    "3) Pinto la molécula ampliada sin órbitas"
    self createIndividualJobsFor: runner
                        withJobs: runner jobs
                        inGroup: detailGroup
              withNucleusSize: 150.   "o el tamaño que quieras"

    "4) Centrar el detailGroup en el canvas"
    detailGroup translateTo: (detailCanvas extent / 2).

    "5) Agregar el group al canvas"
    detailCanvas add: detailGroup.

    "6) Opcional: un título arriba"
    titleLabel := RSLabel new.
    titleLabel
        text: 'Details for: ', runner name asString;
        fontSize: 18;
        bold;
        color: Color black.
    "Lo posicionas manualmente"
    titleLabel translateTo: (0 @ (detailCanvas extent y - 30)).
    detailCanvas add: titleLabel.

    "7) Hacer interactivo el canvas"
    detailCanvas @ RSCanvasController.

    "8) Abrir en nueva ventana"
    ^ detailCanvas openInWorld

]

{ #category : 'public' }
GHRunnerCollection >> showDepthRunnerDetails: runner inGroup: ignoredGroup [
    "Abre una nueva ventana canvas mostrando solo la molécula del runner seleccionado"
    | detailCanvas detailGroup titleLabel |

    "1) Creo el canvas de la ventana"
    detailCanvas := RSCanvas new.

    "2) Creo un grupo independiente para dibujar la molécula detallada"
    detailGroup := RSGroup new.

    "3) Pinto la molécula ampliada sin órbitas"
    self createIndividualJobsFor: runner
                        withJobs: runner jobs
                        inGroup: detailGroup
              withNucleusSize: 150.   "o el tamaño que quieras"

    "4) Centrar el detailGroup en el canvas"
    detailGroup translateTo: (detailCanvas extent / 2).

    "5) Agregar el group al canvas"
    detailCanvas add: detailGroup.

    "6) Opcional: un título arriba"
    titleLabel := RSLabel new.
    titleLabel
        text: 'Details for: ', runner name asString;
        fontSize: 18;
        bold;
        color: Color black.
    "Lo posicionas manualmente"
    titleLabel translateTo: (0 @ (detailCanvas extent y - 30)).
    detailCanvas add: titleLabel.

    "7) Hacer interactivo el canvas"
    detailCanvas @ RSCanvasController.

    "8) Abrir en nueva ventana"
    ^ detailCanvas openInWorld

]

{ #category : 'public' }
GHRunnerCollection >> showJobDetails: aJob [
    | detailText |
    detailText := 'JOB DETAILS', String cr,
                  '==============', String cr,
                  'Name: ', aJob name asString, String cr,
                  'Status: ', aJob status asString, String cr,
                  'Conclusion: ', aJob conclusion asString, String cr,
                  'Started At: ', aJob startedAt asString, String cr,
                  'Completed At: ', aJob completedAt asString, String cr,
                  'Execution Time: ', aJob executionTime asString, ' minutes', String cr,
                  'Number of Steps: ', aJob steps size asString, String cr,
                  String cr,
                  'STEPS:', String cr,
                  '-------', String cr.
    
    "conclusion de cada step"
    aJob steps withIndexDo: [ :step :index |
        detailText := detailText, 
                      index asString, '. ', step name asString, 
                      ' (', step conclusion asString, ')', String cr.
    ].
    
    UIManager default inform: detailText.
    "O alternativamente, abrir inspector:"
    "aJob inspect."
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
GHRunnerCollection >> showStepDetails: aStep [
    | detailText executionTime |
    
    "Calcular tiempo de ejecución"
    executionTime := aStep completedAt 
        ifNotNil: [ (aStep completedAt - aStep startedAt) totalSeconds ]
        ifNil: [ 'N/A' ].
    
    detailText := 'STEP DETAILS', String cr,
                  '==============', String cr,
                  'Name: ', aStep name asString, String cr,
                  'Number: ', aStep number asString, String cr,
                  'Status: ', aStep status asString, String cr,
                  'Conclusion: ', aStep conclusion asString, String cr,
                  'Started At: ', aStep startedAt asString, String cr,
                  'Completed At: ', (aStep completedAt 
                      ifNotNil: [ aStep completedAt asString ] 
                      ifNil: [ 'Still running' ]), String cr,
                  'Execution Time: ', executionTime asString, ' seconds', String cr,
                  String cr.
    
    "Agregar log si existe y no está vacío"
    (aStep log isNotNil and: [ aStep log isNotEmpty ]) ifTrue: [
        detailText := detailText,
                      'LOG OUTPUT:', String cr,
                      '===========', String cr,
                      aStep log asString, String cr,
                      String cr.
    ].
    
    
    UIManager default inform: detailText.
    "Alternativamente, abrir inspector:"
    "aStep inspect."
]

{ #category : 'public' }
GHRunnerCollection >> squaredView [
]

{ #category : 'public' }
GHRunnerCollection >> squarifiedTreemap: dataArray inRect: rect layouts: layouts [
    "Algoritmo squarified treemap que minimiza aspect ratios"
    | remainingData currentRow currentRect |
    
    dataArray isEmpty ifTrue: [ ^ self ].
    
    remainingData := dataArray copy.
    currentRect := rect.
    
    [ remainingData isEmpty ] whileFalse: [
        | bestRow |
        bestRow := self findBestRow: remainingData forRect: currentRect.
        
        "Renderizar la fila actual"
        self layoutRow: bestRow inRect: currentRect layouts: layouts.
        
        "Actualizar datos restantes y rectángulo"
        remainingData := remainingData allButFirst: bestRow size.
        currentRect := self updateRectAfterRow: bestRow inRect: currentRect.
    ].
]

{ #category : 'public' }
GHRunnerCollection >> treemapDataFrom: groupedRunners runnerBoxes: runnerBoxes [
    "Peso = área total necesaria para sus cajas de runners"
    ^ groupedRunners collect: [ :pair |
        | key runnerData runBoxes size weight |
        key := pair key.
        runnerData := runnerBoxes at: key.
        "Extraer solo los runBox para calcular el tamaño del grid"
        runBoxes := runnerData collect: [ :entry | entry at: #runBox ].
        size := self estimateRequiredGridSizeFor: runBoxes
                                      maxRowWidth: 3000
                                           spacing: 6.
        weight := size x * (size y).
        { key. runnerData. weight. 1 }
    ].

]

{ #category : 'public' }
GHRunnerCollection >> updateRectAfterRow: row inRect: rect [
    "Actualiza el rectángulo después de colocar una fila"
    | totalWeight isHorizontal |
    
    totalWeight := row sum: [ :data | data at: 6 ].
    isHorizontal := rect width >= rect height.
    
    ^ isHorizontal
        ifTrue: [
            | usedHeight |
            usedHeight := rect height.
            Rectangle 
                origin: rect origin + (0 @ usedHeight)
                extent: rect width @ (rect height - usedHeight)
        ]
        ifFalse: [
            | usedWidth |
            usedWidth := rect width.
            Rectangle 
                origin: rect origin + (usedWidth @ 0)
                extent: (rect width - usedWidth) @ rect height
        ]
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

{ #category : 'accessing' }
GHRunnerCollection >> workflowColors [
   | colors |
	colors := { 
				Color blue muchLighter. Color red muchLighter. Color green muchLighter. 
				Color orange muchLighter. Color purple muchLighter. Color brown muchLighter.
				Color cyan muchLighter. Color magenta muchLighter. Color yellow muchLighter. Color gray muchLighter 
	  }.
	^ colors.
]

{ #category : 'public' }
GHRunnerCollection >> workflowHotspotView [
    | canvas groupedRunners workflowColors runnerBoxes treemapData treemapLayout |

    canvas := RSCanvas new.
    groupedRunners := self groupAndSortRunners: runners.
    workflowColors := self workflowColors.

    "1) Crear y normalizar las cajas de runners (como Dictionary, con los attempts dentro)"
    runnerBoxes := self buildRunnerBoxesFrom: groupedRunners colors: workflowColors.
    
    "2) Generar los datos de treemap (peso = área requerida)"
    treemapData := self treemapDataFrom: groupedRunners runnerBoxes: runnerBoxes.
    
    "3) Calcular layout y renderizar"
    treemapLayout := self calculateTreemapLayout: treemapData.
    self renderTreemap: treemapLayout
                on: canvas
         withRunnerBoxes: runnerBoxes
                  colors: workflowColors.

]

{ #category : 'public' }
GHRunnerCollection >> workflowHotspotViewByActor [
	| canvas groupedRunners currentY maxWidth workflowColors rectangles |
	
	canvas := RSCanvas new.
	
	"agrupar runners por actor y ordenar por fecha (más recientes primero)"
	groupedRunners := (runners groupedBy: [ :r | r actor login ]) 
		associations collect: [ :assoc |
			assoc key -> (assoc value asSortedCollection: [ :a :b | 
				a runStartedAt > b runStartedAt ]) ].
	
	groupedRunners := groupedRunners asSortedCollection: [ :a :b | a key < b key ].
	
	workflowColors := { 
		Color blue muchLighter. Color red muchLighter. Color green muchLighter. 
		Color orange muchLighter. Color purple muchLighter. Color brown muchLighter.
		Color cyan muchLighter. Color magenta muchLighter. Color yellow muchLighter. Color gray muchLighter 
	}.
	
	currentY := 50.
	maxWidth := 0.
	rectangles := OrderedCollection new.
	
	groupedRunners withIndexDo: [ :workflowGroup :workflowIndex |
		| workflowRunners workflowColor workflowLabel currentX maxHeightInRow |
		
		workflowRunners := workflowGroup value.
		workflowColor := workflowColors at: ((workflowIndex - 1) \\ workflowColors size + 1).
		
		workflowLabel := RSLabel new
			text: workflowGroup key;
			fontSize: 65;
			color: Color black;
			bold;
			translateTo: 10 @ (currentY - 75).
		canvas add: workflowLabel.
		
		currentX := 20.
		maxHeightInRow := 0.
		
		workflowRunners withIndexDo: [ :runner :runnerIndex |
			| rectangle width height color executionTime jobCount |
			
			jobCount := runner jobs size.
			executionTime := self getLastAttemptExecutionTime: runner.
			
			"cajita"
			width := (jobCount max: 1) * 25.  "ancho = número de jobs"
			height := 50.  "altura temporal"
			
			"color basado en conclusion"
			color := self getColorForConclusion: runner conclusion base: workflowColor.
			
			rectangle := RSBox new
				width: width;
				height: height;
				color: color;
				border: (RSBorder new 
					color: workflowColor darker; 
					width: 1);
				model: runner.
			
			rectangle translateTo: currentX + (width / 2) @ (currentY + (height / 2)).
			
			"información detallada"
			rectangle @ (RSPopup text: [ :runner |
				| realTime |
				realTime := self getLastAttemptExecutionTime: runner.
				'Workflow: ' , runner workflow name , String cr ,
				'Run: ' , runner name asString , String cr ,
				'Jobs: ' , runner jobs size asString , String cr ,
				'Execution Time: ' , realTime asString , 's' , String cr ,
				'Attempt: ' , runner runAttempt asString , String cr ,
				'Conclusion: ' , runner conclusion asString , String cr ,
				'Status: ' , runner status asString , String cr ,
				'Started: ' , runner runStartedAt asString , String cr ,
				'Click for detailed info...' ]).
			
			"interacciones"
			rectangle @ RSHighlightable new.
			rectangle when: RSMouseClick do: [ :evt | 
				self showRunnerDetails: evt shape model ] for: self.
			
			canvas add: rectangle.
			rectangles add: rectangle.
			
			currentX := currentX + width + 50.
			maxHeightInRow := maxHeightInRow max: height.
			maxWidth := maxWidth max: currentX.
			
			runnerIndex \\ 10 = 0 ifTrue: [
				currentX := 20.
				currentY := currentY + maxHeightInRow + 200.  "espacio reducido entre filas"
				maxHeightInRow := 0 ]
		].
		
		"espacio entre workflows"
		currentY := currentY + 300
	].
	
	"normalización"
	RSNormalizer height
		shapes: rectangles;
		from: 10;
		to: 150;
		normalize: [ :runner | self getLastAttemptExecutionTime: runner ].
	
	rectangles do: [ :rect |
		| currentPosition |
		currentPosition := rect position.
		rect translateTo: currentPosition x @ (currentPosition y + (rect height / 2) - 25)
	].
	
	canvas @ RSCanvasController.
	^ canvas open
]

{ #category : 'public' }
GHRunnerCollection >> wrapText: text maxWidth: maxWidth [
    "Dividir texto en líneas que quepan en el ancho especificado"
    | words lines currentLine currentWidth |
    
    words := text substrings: ' '.
    lines := OrderedCollection new.
    currentLine := ''.
    currentWidth := 0.
    
    words do: [ :word |
        | wordWidth |
        wordWidth := word size * 5. "Aproximación: 5 pixels por carácter"
        
        (currentWidth + wordWidth) > maxWidth ifTrue: [
            currentLine isEmpty ifFalse: [
                lines add: currentLine.
                currentLine := word.
                currentWidth := wordWidth.
            ] ifTrue: [
                "Si una sola palabra es muy larga, la agregamos anyway"
                lines add: word.
                currentLine := ''.
                currentWidth := 0.
            ].
        ] ifFalse: [
            currentLine isEmpty 
                ifTrue: [ 
                    currentLine := word.
                    currentWidth := wordWidth.
                ]
                ifFalse: [ 
                    currentLine := currentLine, ' ', word.
                    currentWidth := currentWidth + wordWidth + 5. "5 para el espacio"
                ].
        ].
    ].
    
    currentLine isEmpty ifFalse: [ lines add: currentLine ].
    
    ^ lines ifEmpty: [ OrderedCollection with: 'No text' ]
]

{ #category : 'public' }
GHRunnerCollection >> wrapTextToLines: text maxWidth: maxWidth [
    "Dividir texto en líneas que respeten el ancho máximo especificado"
    | words lines currentLine currentWidth approximateCharWidth |
    
    approximateCharWidth := 6. "Aproximación: 6 pixels por carácter con fontSize 9"
    words := text substrings: ' '.
    lines := OrderedCollection new.
    currentLine := ''.
    currentWidth := 0.
    
    words do: [ :word |
        | wordWidth spaceWidth |
        wordWidth := word size * approximateCharWidth.
        spaceWidth := approximateCharWidth.
        
        "Verificar si la palabra cabe en la línea actual"
        (currentWidth + wordWidth + (currentLine isEmpty ifTrue: [0] ifFalse: [spaceWidth])) > maxWidth ifTrue: [
            "La palabra no cabe, guardar línea actual y empezar nueva"
            currentLine isEmpty ifFalse: [
                lines add: currentLine.
                currentLine := word.
                currentWidth := wordWidth.
            ] ifTrue: [
                "Si una sola palabra es muy larga, la partimos"
                word size * approximateCharWidth > maxWidth ifTrue: [
                    | maxCharsPerLine partIndex |
                    maxCharsPerLine := (maxWidth / approximateCharWidth) floor max: 1.
                    partIndex := 1.
                    [ partIndex <= word size ] whileTrue: [
                        | part endIndex |
                        endIndex := (partIndex + maxCharsPerLine - 1) min: word size.
                        part := word copyFrom: partIndex to: endIndex.
                        lines add: part.
                        partIndex := endIndex + 1.
                    ].
                    currentLine := ''.
                    currentWidth := 0.
                ] ifFalse: [
                    lines add: word.
                    currentLine := ''.
                    currentWidth := 0.
                ].
            ].
        ] ifFalse: [
            "La palabra cabe en la línea actual"
            currentLine isEmpty 
                ifTrue: [ 
                    currentLine := word.
                    currentWidth := wordWidth.
                ]
                ifFalse: [ 
                    currentLine := currentLine, ' ', word.
                    currentWidth := currentWidth + spaceWidth + wordWidth.
                ].
        ].
    ].
    
    "Agregar la última línea si no está vacía"
    currentLine isEmpty ifFalse: [ lines add: currentLine ].
    
    "Si no hay líneas, retornar al menos una línea vacía"
    ^ lines ifEmpty: [ OrderedCollection with: 'No text' ]
]
