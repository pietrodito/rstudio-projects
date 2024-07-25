# ovaliDB

Un package pour requêter facilement aux DB issues d'ePMSI

## Structure des DB

Une base de données par nature d'établissement.

Soit 8 bases de données :

| Champ | Statut | Nature     | Nom de la BD |
|-------|--------|------------|--------------|
| MCO   | DGF    | MCO ex-DG  | MCO_DGF      |
| MCO   | OQN    | MCO ex-OQN | MCO_OQN      |
| HAD   | DGF    | HAD ex-DG  | HAD_DGF      |
| HAD   | OQN    | HAD ex-OQN | HAD_OQN      |
| SMR   | DGF    | SMR ex-DG  | SMR_DGF      |
| SMR   | OQN    | SMR ex-OQN | SMR_OQN      |
| PSY   | DGF    | PSY ex-DG  | PSY_DGF      |
| PSY   | OQN    | PSY ex-OQN | PSY_OQN      |

## Performances

Nous allons utiliser le package [`pool`](http://rstudio.github.io/pool/articles/why-pool.html) qui permet de ne pas se soucier du nombre de connexions `


