# LAB06-ARSW-TERRAFORM Infraestructura como Código con Terraform (Azure)
**Realizado por:** David Alejandro Patacon Henao 

## Desarrollo del laboratorio

### Backend remoto de Terraform

Despues de haber creado el ```resourse group```, el ```storage account``` y el ```container``` para el backend remoto de Terraform, se procedió a crear el archivo `backend.hcl` con la siguiente configuración:

```hcl
resource_group_name = "rg-tfstate-lab6"
storage_account_name = "sttfstate12345678"
container_name = "tfstate"
key = "lab6.terraform.tfstate"
```
- **resource_group_name:** grupo de recursos del backend
- **storage_account_name:** nombre de la cuenta de almacenamiento
- **container_name:** contenedor del state
- **key:** nombre del archivo de state

---

### Configurar el provider de Azure
Luego se creó el archivo `providers.tf` con la siguiente configuración para el provider de Azure:

```tf
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {}
}
provider "azurerm" {
  features {}
}
```
- **required_version:** obliga a usar una versión compatible de Terraform
- **required_providers:** define el proveedor de Azure
- **backend "azurerm" {}:** indica que el state vivirá en Azure Storage
- **provider "azurerm" { features {} }:** activa el proveedor de Azure

---

### Definir variables
En el archivo `variables.tf` se definieron las siguientes variables:

```tf
variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
}

variable "vm_count" {
  description = "Número de VMs"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Usuario administrador"
  type        = string
}

variable "ssh_public_key" {
  description = "Ruta a la clave pública SSH"
  type        = string
}

variable "allow_ssh_from_cidr" {
  description = "CIDR permitido para SSH"
  type        = string
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {}
}
```
- **prefix:** prefijo común de nombres
- **location:** región
- **vm_count:** cantidad de máquinas virtuales
- **admin_username:** usuario Linux
- **ssh_public_key:** archivo de clave pública
- **allow_ssh_from_cidr:** IP pública en formato /32
- **tags:** metadatos de los recursos

---

### Variables de entorno
En el archivo `env/dev.tfvars` se asignaron valores a las variables:
```hcl
prefix              = "lab6"
location            = "centralus"
vm_count            = 2
admin_username      = "student"
ssh_public_key      = "~/.ssh/id_ed25519.pub"
allow_ssh_from_cidr = "186.28.26.89/32"

tags = {
  owner   = "AlejandroHenao2572"
  course  = "ARSW"
  env     = "dev"
  expires = "2026-12-31"
}
```
Este archivo contiene valores concretos para el entorno de desarrollo.

---

### Archivo cloud-init
El archivo `cloud-init.yaml` se creó con el siguiente contenido para configurar las VMs

```yaml
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - echo "Hola desde $(hostname)" > /var/www/html/index.nginx-debian.html
  - systemctl enable nginx
  - systemctl restart nginx
```
- **#cloud-config:** indica que es un archivo cloud-init
- **package_update:** true: actualiza la lista de paquetes
- **packages:** - nginx: instala nginx
- **runcmd:** comandos que se ejecutan al iniciar la VM
- **echo "Hola desde $(hostname)" ...:** crea una página web con el nombre del host
- **systemctl enable nginx:** habilita nginx al arranque
- **systemctl restart nginx:** reinicia nginx para aplicar cambios

### Ejecución de Terraform

Para ejecutar Terraform, se siguieron los siguientes pasos:

Inicialización del backend remoto:
![alt text](docs/img/image.png)

Revision rapida:
![alt text](docs/img/image2.png)

Ejecución del plan:
![alt text](docs/img/image3.png)

Aplicación del plan:
![alt text](docs/img/image-6.png)
![alt text](docs/img/image-7.png)

Output de Terraform:

```txt
lb_public_ip = "172.202.22.148"
resource_group_name = "lab6-rg"
vm_names = [
  "lab6-vm-0",
  "lab6-vm-1",
]
```

Entrar a la IP pública del Load Balancer desde el navegador:  

> **IP pública del Load Balancer:** http://172.202.22.148

- Respuesta de la VM 0:
![alt text](docs/img/image-4.png)

- Respuesta de la VM 1:
![alt text](docs/img/image-3.png)

- Pruebas con curl:
![alt text](docs/img/image-5.png)


### Workflow CI/CD con GitHub Actions

Se implementó el workflow `.github/workflows/terraform.yml` para automatizar la validación y despliegue de la infraestructura con Terraform.

Este workflow tiene dos ejecuciones principales:

- **Pull Request hacia `main`**: ejecuta `terraform fmt`, `terraform validate` y `terraform plan`.
- **Ejecución manual (`workflow_dispatch`)**: ejecuta `terraform apply` para aplicar los cambios en Azure.

#### Funcionamiento general
- Usa **OIDC** para autenticarse en Azure sin credenciales largas.
- Toma como base el directorio `./infra`.
- Inicializa Terraform con el backend remoto en Azure Storage.
- Crea la llave pública SSH requerida por la infraestructura.
- Publica el archivo del plan como artefacto en el pipeline.

#### Resultado
Con este flujo, cada cambio en Terraform se revisa antes de llegar a `main`, y el despliegue final se realiza de forma controlada y manual.

Se creo una rama para testear el workflow y se hizo un PR a main para validar su funcionamiento.

Terraform Plan:

![alt text](docs/img/ci.png)  
![alt text](docs/img/ci2.png)

Terraform Apply:
![alt text](docs/img/ci3.png)
