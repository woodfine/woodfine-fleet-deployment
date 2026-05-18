# foundry-workspace

Guías operativas para el nodo de plataforma del espacio de trabajo Foundry — la VM de GCE
que aloja el entorno de desarrollo asistido por IA de PointSav.

Este directorio contiene guías para los operadores y sesiones de IA que trabajan dentro del
espacio de trabajo: recuperación de recursos, aprovisionamiento de archivos, el inventario de
hooks de Claude Code y el flujo de trabajo de la puerta pre-commit.

## Contenido

| Guía | Propósito |
|---|---|
| `guide-foundry-vm-resource-recovery.md` | Recuperación de la VM ante presión de recursos (carga, memoria, swap) |
| `guide-onboarding-new-archive.md` | Aprovisionamiento de un nuevo Totebox Archive mediante `bin/onboarding/new-archive.sh` |
| `guide-claude-code-hooks-installed.md` | Inventario de los cinco hooks de Claude Code instalados en el espacio de trabajo |
| `guide-pre-commit-gate-operator-flow.md` | Trabajo con la puerta pre-commit — omisiones, falsos positivos, anulación de emergencia |

## TOPICs relacionados

Los artículos de arquitectura que respaldan estas guías viven en `content-wiki-documentation/architecture/`:
`foundry-services-slice-model`, `multi-engine-session-coordination`, `mailbox-atomicity`,
`cargo-target-per-user-discipline`, `pre-commit-defense-in-depth`.
