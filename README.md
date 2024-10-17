# Clústeres de Kubernetes con Minikube

Esta guía explica cómo crear dos clústeres de Kubernetes separados llamados `dev` y `qa` utilizando Minikube.

## Prerrequisitos

Antes de comenzar, asegúrate de tener lo siguiente instalado:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Un hipervisor como VirtualBox, HyperKit o Docker para ejecutar la VM de Minikube

## Paso 1: Verificar Prerrequisitos

Verifica que Minikube y kubectl estén instalados:

```bash
minikube version
kubectl version --client
```

## Paso 2: Iniciar el Clúster dev
Inicia el primer clúster de Minikube, nombrándolo dev:

```bash
minikube start -p dev --kubernetes-version=v1.30.2 --memory=3096
```

Esto creará un clúster llamado dev con los recursos y la versión especificada.

Verificar el Clúster dev
Verifica que el clúster dev esté corriendo:

```bash
minikube status -p dev
```
Cambia el contexto de kubectl al clúster dev:

```bash
kubectl config use-context dev
```

## Paso 3: Iniciar el Clúster qa
Ahora crea el segundo clúster llamado qa, también con la versión v1.30.2 de Kubernetes y 3096 MB de memoria:

```bash
minikube start -p qa --kubernetes-version=v1.30.2 --memory=3096
```

Esto creará otro clúster llamado qa con la misma configuración.

Verificar el Clúster qa
Asegúrate de que el clúster qa esté corriendo:

```bash
minikube status -p qa
```
Cambia el contexto de kubectl al clúster qa:

```bash
kubectl config use-context qa
```

## Paso 4: Listar Ambos Clústeres
Para ver todos los clústeres disponibles, ejecuta:

```bash
kubectl config get-contexts
```

Deberías ver listados tanto dev como qa. Puedes cambiar entre ellos según sea necesario:

```bash
kubectl config use-context dev

kubectl config use-context qa
```

## Paso 5: Interactuar con Cada Clúster
Ahora puedes desplegar aplicaciones, gestionar recursos o ejecutar cualquier otro comando de Kubernetes en cada clúster cambiando entre los contextos como se mostró anteriormente.

Limpieza
Para detener y eliminar los clústeres cuando hayas terminado, usa:

```bash
minikube delete -p dev
minikube delete -p qa
```

Notas
Si estás usando un hipervisor como VirtualBox o Docker, asegúrate de que tu sistema tenga suficientes recursos (por ejemplo, CPU, memoria) para ejecutar múltiples clústeres de Minikube.
Puedes personalizar la configuración de cada clúster pasando parámetros adicionales (por ejemplo, --cpus) al iniciar Minikube.
