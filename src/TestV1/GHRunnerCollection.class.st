Class {
	#name : 'GHRunnerCollection',
	#superclass : 'Object',
	#instVars : [
		'runners'
	],
	#category : 'TestV1',
	#package : 'TestV1'
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
GHRunnerCollection >> getColorForConclusion: conclusion base: baseColor [
	"Retorna color basado en la conclusión del runner"
	conclusion = 'success' ifTrue: [ ^ Color green alpha: 0.7 ].
	conclusion = 'failure' ifTrue: [ ^ Color red alpha: 0.7 ].
	conclusion = 'cancelled' ifTrue: [ ^ Color orange alpha: 0.7 ].
	conclusion = 'skipped' ifTrue: [ ^ Color gray alpha: 0.7 ].
	^ baseColor alpha: 0.7
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
	"Calcula el tiempo de ejecución del último attempt del runner"
	| lastAttemptJobs totalTime |
	
	"Filtrar jobs del último attempt"
	lastAttemptJobs := runner jobs select: [ :job | 
		job runAttempt = runner runAttempt ].
	
	"Calcular tiempo total sumando duración de todos los jobs del último attempt"
	totalTime := lastAttemptJobs inject: 0 into: [ :sum :job |
		| jobDuration |
		jobDuration := (job startedAt notNil and: [ job completedAt notNil ])
			ifTrue: [ (job completedAt - job startedAt) asSeconds ]
			ifFalse: [ 0 ].
		sum + jobDuration ].
	
	^ totalTime max: 1  "mínimo 1 segundo para visualización"
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

{ #category : 'public' }
GHRunnerCollection >> workflowHotspotView [
	| canvas groupedRunners currentY maxWidth workflowColors rectangles |
	
	canvas := RSCanvas new.
	
	"agrupar runners por workflow y ordenar por fecha (más recientes primero)"
	groupedRunners := (runners groupedBy: [ :r | r workflow name ]) 
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
	
	"procesar cada grupo de workflow"
	groupedRunners withIndexDo: [ :workflowGroup :workflowIndex |
		| workflowRunners workflowColor workflowLabel currentX maxHeightInRow |
		
		workflowRunners := workflowGroup value.
		workflowColor := workflowColors at: ((workflowIndex - 1) \\ workflowColors size + 1).
		
		"label del workflow"
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
			
			"actualizar posición para siguiente rectángulo"
			currentX := currentX + width + 50.
			maxHeightInRow := maxHeightInRow max: height.
			maxWidth := maxWidth max: currentX.
			
			"salto de línea cada 10 runners exactamente"
			runnerIndex \\ 10 = 0 ifTrue: [
				currentX := 20.
				currentY := currentY + maxHeightInRow + 200.  
				maxHeightInRow := 0 ]
		].
		
		"espacio entre workflows"
		currentY := currentY + 300
	].
	
	"normalización de altura"
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
