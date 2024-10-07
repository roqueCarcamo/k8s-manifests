#!/bin/bash

set -e

# Función para configurar Argo CD como NodePort
configure_argocd_nodeport() {
  local profile=$1
  local nodeport=$2

  echo "Configurando Argo CD en el perfil '$profile' para usar NodePort $nodeport"

  # Cambiar al perfil de minikube correspondiente
  minikube profile "$profile"

  # Verificar si el espacio de nombres 'argocd' existe, si no, crearlo
  if ! kubectl get namespace argocd >/dev/null 2>&1; then
    kubectl create namespace argocd
    echo "Namespace 'argocd' creado en el perfil '$profile'."
  else
    echo "Namespace 'argocd' ya existe en el perfil '$profile'."
  fi

  # Instalar Argo CD si no está ya instalado
  if ! kubectl get deployment argocd-server -n argocd >/dev/null 2>&1; then
    echo "Instalando Argo CD en el perfil '$profile'..."
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "Esperando a que los pods de Argo CD estén listos en el perfil '$profile'..."
    kubectl rollout status deployment argocd-server -n argocd
  else
    echo "Argo CD ya está instalado en el perfil '$profile'."
  fi

  # Cambiar el tipo de servicio a NodePort y asignar el nodePort específico
  echo "Configurando el servicio 'argocd-server' a NodePort $nodeport en el perfil '$profile'..."
  kubectl patch svc argocd-server -n argocd -p \
    "{\"spec\": {\"type\": \"NodePort\", \"ports\": [{\"port\": 443, \"targetPort\": 443, \"nodePort\": $nodeport, \"name\": \"https\"}]}}"

  echo "Argo CD en el perfil '$profile' está configurado para NodePort $nodeport"
}

# Reiniciar y configurar el perfil 'dev'
echo "Reiniciando y configurando el perfil 'dev'..."
minikube stop -p dev
minikube start -p dev --driver=docker --cpus=2 --memory=3096 --kubernetes-version=v1.25.0

configure_argocd_nodeport dev 30080

# Reiniciar y configurar el perfil 'qa'
echo "Reiniciando y configurando el perfil 'qa'..."
minikube stop -p qa
minikube start -p qa --driver=docker --cpus=2 --memory=3096 --kubernetes-version=v1.25.0

configure_argocd_nodeport qa 30081

echo "Perfiles 'dev' y 'qa' reiniciados y Argo CD expuestos en los puertos 30080 y 30081 respectivamente."

