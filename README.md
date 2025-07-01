Para descargar el proyecto, se debe crear una nueva imagen de Pharo 13. Una vez dentro de ella, en el Playground, se debe ejecutar:
```
Metacello new
    githubUser: 'CQuarkH' project: 'gha-failures-c' commitish: 'master' path: 'src';
    baseline: 'GHFailures';
    load.
```
## Ejemplo de Uso

Para cargar los Runners, se debe utilizar el script `scrap_formated_runs.py`, de la siguiente manera:
```
python3 scrap_formated_runs.py REPO OWNER --individual --token TOKEN_GH --max-runs 300 --no-logs

```
Luego de lo anterior, para visualizarlos, se puede utilizar lo siguiente:

```
| ghRunnersCollection |

ghRunnersCollection := GHRunnerCollection new.
ghRunnersCollection loadRunnersFromDir: 'RUTA_A_LOS_RUNNERS_EXTRAIDOS' . 

ghRunnersCollection workflowHotspotView . "visualización de runners agrupados por workflows"

ghRunnersCollection hotspotViewByActor . "visualización de runners agrupados por actor/usuario"
```
