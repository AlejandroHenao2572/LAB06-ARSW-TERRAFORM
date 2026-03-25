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