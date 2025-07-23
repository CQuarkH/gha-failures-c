Para descargar el proyecto, se debe crear una nueva imagen de Pharo 13. Una vez dentro de ella, en el Playground, se debe ejecutar:
```
Metacello new
    githubUser: 'CQuarkH' project: 'gha-failures-c' commitish: 'master' path: 'src';
    baseline: 'GHFailures';
    load.
```
## Ejemplo de Uso
- Los Runs de prueba están dentro de este mismo repositorio, en el directorio `vercel_next.js`
Para visualizar los runs, se puede utilizar lo siguiente:

```
| ghRunnersCollection |

ghRunnersCollection := GHRunnerCollection new.
ghRunnersCollection loadRunnersFromDir: 'RUNS_DIR' . 

ghRunnersCollection layerDesignView: 'build-and-deploy'.
```
