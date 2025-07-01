Para descargar el proyecto, se debe crear una nueva imagen de Pharo 13. Una vez dentro de ella, en el Playground, se debe ejecutar:
```
Metacello new
    githubUser: 'CQuarkH' project: 'gha-failures-c' commitish: 'master' path: 'src';
    baseline: 'GHFailures';
    load.
