Para descargar el proyecto, se debe crear una nueva imagen de Pharo 13. Una vez dentro de ella, en el Playground, se debe ejecutar:
```
Metacello new
    githubUser: 'CQuarkH' project: 'gha-failures-c' commitish: 'master' path: 'src';
    baseline: 'GHFailures';
    load.
```

Ejemplo de Uso: Visualización de Runners como cuadrados
- Alto: Tiempo de Ejecución
- Ancho: Número de Jobs

```
| ghRunnersCollection |

ghRunnersCollection := GHRunnerCollection new.
ghRunnersCollection loadRunnersFromDir: 'RUTA_A_LOS_RUNNERS' . 

ghRunnersCollection workflowHotspotView . "visualización de runners agrupados por workflows"

ghRunnersCollection hotspotViewByActor . "visualización de runners agrupados por actor/usuario"
```
