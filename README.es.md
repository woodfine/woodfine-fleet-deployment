<div align="center">

<img src="https://raw.githubusercontent.com/woodfine/woodfine-media-assets/main/ASSET-SIGNET-MASTER.svg" width="72" alt="Woodfine Management Corp.">

# Woodfine Management Corp.
### *El Despliegue Institucional en Vivo de la Plataforma PointSav*

[![Estado: Despliegue Activo](https://img.shields.io/badge/Estado-Despliegue_Activo-22863a.svg?style=flat-square)](#inventario-de-flota-activa)
[![Cumplimiento: SOC 3 / DARP](https://img.shields.io/badge/Cumplimiento-SOC_3_%2F_DARP-0075ca.svg?style=flat-square)](#cumplimiento-y-gobernanza)

<br/>

**[→ woodfinegroup.com](https://woodfinegroup.com)** &nbsp;·&nbsp; **[→ Wiki de Gobernanza Corporativa](https://github.com/woodfine/content-wiki-corporate)** &nbsp;·&nbsp; **[→ Ingeniería PointSav](https://github.com/pointsav/pointsav-monorepo)**

</div>

<br/>

> [!NOTE]
> Este repositorio no contiene cuentas financieras activas, datos de personal ni cargas útiles de red propietarias. El rol de supervisión previsto para la Sovereign Data Foundation aún no ha sido ejecutado formalmente.

---

## El Problema que Nadie Ha Resuelto

El mercado de bienes raíces tokenizados se aproxima a los 30 billones de dólares. Los inversores institucionales pueden adquirir hoy participaciones fraccionarias en edificios comerciales a través de plataformas digitales. Lo que se transfiere en esas transacciones es un título — el derecho legal de poseer el activo.

Lo que no se transfiere es la historia del inmueble.

El registro de arrendamientos — cada contrato de arrendamiento, enmienda y fecha de vencimiento que define la capacidad generadora de ingresos del activo — vive en el CRM del administrador de propiedades anterior. El historial de mantenimiento vive en la plataforma de gestión de instalaciones. Los planos BIM que describen la estructura física se encuentran en el servidor del arquitecto. Los datos de IoT que registran el rendimiento operativo del inmueble en tiempo real fluyen hacia la nube del proveedor de sensores.

Cada uno de estos registros pertenece a un tercero. Cuando el activo cambia de manos, el comprador recibe el título y comienza el proceso de reconstruir la historia desde cero.

Woodfine está cerrando esta brecha.

---

## Qué Cambia un PropertyArchive

Woodfine está desplegando un PropertyArchive de PointSav para cada activo bajo gestión — un entorno operativo autónomo que contiene todos los registros relativos a esa propiedad en un único archivo verificado criptográficamente, portable y sellado.

Un PropertyArchive mantenido desde el primer permiso contiene simultáneamente:

| Tipo de Registro | Qué captura | Relevancia comercial |
|:---|:---|:---|
| Registros legales | Título, permisos, cumplimiento normativo | El derecho a operar el activo |
| Planos BIM | Estructura física, datos espaciales, especificaciones | La geometría del activo |
| Registro de arrendamientos | Cada contrato, enmienda, historial de pagos y vencimiento | La capacidad generadora de ingresos — lo que los inversores institucionales suscriben |
| Datos IoT | Lecturas continuas de sensores: HVAC, acceso, servicios | El rendimiento operativo en tiempo real |
| Libro mayor financiero | Gasto de capital, mantenimiento, contratos de servicio | La estructura de costos del activo |
| Historial de mantenimiento | Cada reparación, mejora y evento de servicio | El perfil de condición física y pasivos |
| Registros de personal | Proveedores de servicios, contratistas, relaciones clave | La red operativa del activo |

El registro de arrendamientos es la dimensión de mayor relevancia comercial. El valor de un inmueble es su flujo de ingresos. Ese flujo está definido por sus arrendamientos. Tokenizar un título sin el registro de arrendamientos es tokenizar la carcasa y dejar el valor fuera de la cadena.

Cuando Woodfine vende un inmueble, el comprador recibe una Imagen de Disco de Arranque del PropertyArchive completo — una máquina virtual autónoma que contiene el historial ininterrumpido y verificado criptográficamente del activo desde su inicio. Arranca en cualquier hipervisor estándar. No requiere ninguna relación continua con los sistemas de Woodfine.

---

## El Modelo Operativo

### Despliegue Zero-Touch

La gestión de registros institucionales no debería requerir un departamento de TI. La flota de Woodfine se despliega mediante un ciclo de aprovisionamiento Zero-Touch: un programa de inicio con un solo clic prepara el hardware, una interfaz de texto administra el archivo, y el intercambio de claves criptográficas gestiona el emparejamiento de hardware. Sin nombres de usuario. Sin contraseñas.

### Autorización Basada en Máquina

El acceso a los archivos de Woodfine no se concede mediante credenciales. Se concede a través de la topología física de la red. Si dos máquinas no están emparejadas criptográficamente, no pueden comunicarse. No existe una base de datos de credenciales que robar porque no existen credenciales.

---

## Inventario de Flota Activa

### Entrega Perimetral

| Directorio | Función | Estado |
|:---|:---|:---|
| `media-marketing-landing` | Sitio web público — telemetría sin cookies | 🟢 Activo |
| `media-knowledge-corporate` | Wiki de gobernanza corporativa | 🟡 Aprovisionando |
| `media-knowledge-projects` | Wiki de proyectos inmobiliarios | 🟡 Aprovisionando |
| `media-knowledge-distribution` | Sala de prensa | 🟡 Aprovisionando |

### Infraestructura

| Directorio | Función | Estado |
|:---|:---|:---|
| `route-network-admin` | Enrutamiento de red privada y registro MBA | 🟡 Aprovisionando |
| `fleet-infrastructure-cloud` | Nodo de retransmisión en GCP — pruebas activas | 🟡 Pruebas Activas |
| `fleet-infrastructure-leased` | Nodos de servidor dedicado arrendado | 🟡 Aprovisionando |
| `fleet-infrastructure-onprem` | Hardware en las instalaciones | 🟡 Aprovisionando |

### Archivos Totebox

| Directorio | Tipo de Archivo | Estado |
|:---|:---|:---|
| `cluster-totebox-corporate` | CorporateArchive — libros financieros, actas, registros estatutarios | 🟡 Aprovisionando |
| `cluster-totebox-personnel` | PersonnelArchive — registros de identidad, historial de contactos | 🟢 Activo |
| `cluster-totebox-property` | PropertyArchive — registros de propiedad, permisos, BIM, IoT, arrendamientos | 🟡 Aprovisionando |
| `vault-privategit-source` | Control de versiones interno con acceso restringido | 🟡 Aprovisionando |

---

## Cumplimiento y Gobernanza

Todos los nodos operativos se están desplegando bajo estándares de cumplimiento SOC 3 y DARP. La máquina de entrada F12 es el punto de control humano obligatorio para el ingreso de todos los registros base. Nada entra en el almacenamiento a largo plazo sin que un operador humano autorice manualmente la entrada del libro mayor.

---

*© 2026 Woodfine Management Corp. Todos los derechos reservados.*

*→ English version: [README.md](./README.md)*
