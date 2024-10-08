#!/bin/bash

set -euo pipefail

# Variables
DEV_PROFILE="dev"
QA_PROFILE="qa"
DEV_CPUS=2
DEV_MEMORY=3096
QA_CPUS=2
QA_MEMORY=3096
DEV_K8S_VERSION="v1.25.0"
QA_K8S_VERSION="v1.26.3"
DEV_ARGO_PORT=30080
QA_ARGO_PORT=30081
ARGO_NAMESPACE="argocd"

# Función para verificar si un perfil existe
profile_exists() {
  local profile=$1
  minikube profile list | grep -w "$profile" >/dev/null 2>&1
}

# Función para configurar Argo CD como NodePort
configure_argocd_nodeport() {
  local profile=$1
  local nodeport=$2

  echo "========================================"
  echo "Configurando Argo CD en el perfil '$profile' para usar NodePort $nodeport"
  echo "========================================"

  # Cambiar al perfil de minikube correspondiente
  minikube profile "$profile"

  # Verificar si el espacio de nombres 'argocd' existe, si no, crearlo
  if ! kubectl get namespace "$ARGO_NAMESPACE" >/dev/null 2>&1; then
    echo "Creando namespace '$ARGO_NAMESPACE' en el perfil '$profile'..."
    kubectl create namespace "$ARGO_NAMESPACE"
  else
    echo "Namespace '$ARGO_NAMESPACE' ya existe en el perfil '$profile'."
  fi

  # Instalar Argo CD si no está ya instalado
  if ! kubectl get deployment argocd-server -n "$ARGO_NAMESPACE" >/dev/null 2>&1; then
    echo "Instalando Argo CD en el perfil '$profile'..."
    kubectl apply -n "$ARGO_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "Esperando a que los pods de Argo CD estén listos en el perfil '$profile'..."
    kubectl rollout status deployment argocd-server -n "$ARGO_NAMESPACE"
  else
    echo "Argo CD ya está instalado en el perfil '$profile'."
  fi

  # Verificar si el servicio 'argocd-server' ya está configurado con el NodePort correcto
  current_nodeport=$(kubectl get svc argocd-server -n "$ARGO_NAMESPACE" -o jsonpath="{.spec.ports[?(@.name=='https')].nodePort}")
  if [ "$current_nodeport" != "$nodeport" ]; then
    echo "Configurando el servicio 'argocd-server' a NodePort $nodeport en el perfil '$profile'..."
    kubectl patch svc argocd-server -n "$ARGO_NAMESPACE" -p \
      "{\"spec\": {\"type\": \"NodePort\", \"ports\": [{\"port\": 443, \"targetPort\": 443, \"nodePort\": $nodeport, \"name\": \"https\"}]}}"
    echo "Argo CD en el perfil '$profile' está configurado para NodePort $nodeport"
  else
    echo "El servicio 'argocd-server' ya está configurado con NodePort $nodeport en el perfil '$profile'."
  fi

  echo
}

# Función para obtener la contraseña inicial de Argo CD
get_argocd_password() {
  local profile=$1
  minikube profile "$profile"
  local secret_name
  secret_name=$(kubectl -n "$ARGO_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")
  echo "$(echo "$secret_name" | base64 -D)"
}

# Función para iniciar o crear un perfil de Minikube
start_or_create_profile() {
  local profile=$1
  local cpus=$2
  local memory=$3
  local k8s_version=$4

  if profile_exists "$profile"; then
    echo "========================================"
    echo "Perfil '$profile' ya existe. Reiniciando..."
    echo "========================================"
    minikube stop -p "$profile"
    minikube start -p "$profile" --driver=docker --cpus="$cpus" --memory="$memory" --kubernetes-version="$k8s_version"
  else
    echo "========================================"
    echo "Creando e iniciando el perfil '$profile'..."
    echo "========================================"
    minikube start -p "$profile" --driver=docker --cpus="$cpus" --memory="$memory" --kubernetes-version="$k8s_version"
  fi
}

# Función para actualizar Homebrew y paquetes
update_brew() {
  echo "========================================"
  echo "Actualizando Homebrew y paquetes..."
  echo "========================================"
  brew update && brew upgrade minikube kubectl || echo "Ya tienes las últimas versiones de minikube y kubectl."
}

# Función principal
main() {
  echo "========================================"
  echo "Verificando versiones de Minikube y kubectl..."
  echo "========================================"
  minikube version
  kubectl version --client

  # Actualizar Homebrew y kubectl
  update_brew

  # Crear e iniciar el perfil 'dev'
  start_or_create_profile "$DEV_PROFILE" "$DEV_CPUS" "$DEV_MEMORY" "$DEV_K8S_VERSION"

  # Configurar Argo CD en 'dev'
  configure_argocd_nodeport "$DEV_PROFILE" "$DEV_ARGO_PORT"

  # Crear e iniciar el perfil 'qa'
  start_or_create_profile "$QA_PROFILE" "$QA_CPUS" "$QA_MEMORY" "$QA_K8S_VERSION"

  # Configurar Argo CD en 'qa'
  configure_argocd_nodeport "$QA_PROFILE" "$QA_ARGO_PORT"

  # Obtener contraseñas de Argo CD
  echo "========================================"
  echo "Obteniendo contraseñas iniciales de Argo CD..."
  echo "========================================"

  DEV_PASSWORD=$(get_argocd_password "$DEV_PROFILE")
  QA_PASSWORD=$(get_argocd_password "$QA_PROFILE")

  # Mostrar URLs y credenciales
  echo "========================================"
  echo "Configuración completada exitosamente."
  echo "========================================"
  echo "Accede a Argo CD en los siguientes URLs:"
  echo "- Dev: https://localhost:$DEV_ARGO_PORT"
  echo "- QA: https://localhost:$QA_ARGO_PORT"
  echo
  echo "Credenciales de Argo CD:"
  echo "- Usuario: admin"
  echo "- Contraseña para Dev: $DEV_PASSWORD"
  echo "- Contraseña para QA: $QA_PASSWORD"
  echo
  echo "Nota: Podrías recibir advertencias de seguridad en el navegador debido a certificados SSL auto-firmados. Puedes ignorarlas para uso local."
}

# Ejecutar la función principal
main

