#!/bin/bash

# --- Konfiguration ---
FRONTEND_IMAGE="meine-webseite:v1"
BACKEND_IMAGE="my-api:v1"
K8S_MANIFESTS_DIR="k8s"
FRONTEND_CONTEXT="./fullstack/frontend"
BACKEND_CONTEXT="./fullstack/backend"
INGRESS_SVC_NAME="ingress-nginx-controller"
INGRESS_NAMESPACE="ingress-nginx"
LOCAL_PORT=8080
INGRESS_TARGET_PORT=80

# --- Funktionen ---

# Prüft den Exit-Code des letzten Befehls
check_status() {
    if [ $? -ne 0 ]; then
        echo "❌ FEHLER: $1 konnte nicht erfolgreich ausgeführt werden." >&2
        exit 1
    fi
}

# --- Start des Clusters ---

echo "#############################################"
echo "🚀 1. Minikube starten und Addons aktivieren"
echo "#############################################"

# 1. Minikube starten
minikube start
check_status "Minikube Start"

# 2. Ingress Addon aktivieren
minikube addons enable ingress
check_status "Minikube Ingress Addon"

# 2.5 Warten auf Ingress Controller Deployment
echo "   -> Warte auf Ingress Controller Deployment Rollout..."
kubectl rollout status deployment ingress-nginx-controller --namespace ${INGRESS_NAMESPACE} --timeout=120s
check_status "Warten auf Ingress Controller Deployment"

# NEU: Zusätzliche Wartezeit für Netzwerkstabilität des Admission Webhook
echo "   -> Warte 10 Sekunden auf Webhook Netzwerk-Stabilität..."
sleep 10

# 3. Docker-Umgebung auf Minikube umstellen
eval $(minikube docker-env)
check_status "Minikube Docker-Umgebung setzen"

# --- Image Build ---

echo "#############################################"
echo "📦 2. Docker Images bauen (in Minikube-VM)"
echo "#############################################"

# 4. Frontend Image bauen (mit der aktuellen, korrigierten Version)
echo "   -> Baue Frontend Image: ${FRONTEND_IMAGE}"
docker build --no-cache -t ${FRONTEND_IMAGE} ${FRONTEND_CONTEXT}
check_status "Frontend Image Build"

# 5. Backend Image bauen
echo "   -> Baue Backend Image: ${BACKEND_IMAGE}"
docker build -t ${BACKEND_IMAGE} ${BACKEND_CONTEXT}
check_status "Backend Image Build"

# --- Deployment ---

echo "#############################################"
echo "♻️ 3. Vorhandene Ressourcen bereinigen"
echo "#############################################"
# Löscht Deployments, Services und Ingress, um Konflikte zu vermeiden.
kubectl delete -f ${K8S_MANIFESTS_DIR} --ignore-not-found=true
check_status "Ressourcen-Cleanup"

echo "#############################################"
echo "🏗️ 4. Kubernetes Ressourcen deployen"
echo "#############################################"

# 6. K8s Manifeste anwenden (Deployments, Services, Ingress)
kubectl apply -f ${K8S_MANIFESTS_DIR}
check_status "Kubernetes Apply"

# 7. Warten, bis alle Deployments bereit sind
echo "   -> Warte auf Pod-Bereitschaft (Timeout 2 Min)..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=database --timeout=120s
check_status "Warten auf Pods"
echo "   -> Alle Anwendungs-Pods sind bereit."

# --- Anwendung zugänglich machen und Logs starten ---

echo "#############################################"
echo "🌐 5. Anwendung Port-Forwarding starten"
echo "#############################################"

PORT_FORWARD_CMD="kubectl port-forward svc/${INGRESS_SVC_NAME} ${LOCAL_PORT}:${INGRESS_TARGET_PORT} -n ${INGRESS_NAMESPACE}"

echo "🔥 Führe DIESEN BEFEHL in einem NEUEN TERMINAL aus und **lasse ihn laufen**, um die Webseite zugänglich zu machen:"
echo ""
echo "  ${PORT_FORWARD_CMD}"
echo ""

echo "#############################################"
echo "📝 6. Backend Logs verfolgen"
echo "#############################################"

echo "🔥 Führe DIESEN BEFEHL in einem ZWEITEN NEUEN TERMINAL aus, um die Logs zu sehen:"
echo ""
echo "  kubectl logs -f -l app=backend"
echo ""

echo "#############################################"
echo "✅ SETUP ABGESCHLOSSEN"
echo "#############################################"
echo "Öffne nun zwei neue Terminalfenster und führe die obigen 🔥 Befehle aus."
echo ""
echo "➡️ WEBSEITE ZUGRIFFSADRESSE:"
echo "--------------------------"
echo "   http://localhost:${LOCAL_PORT}/"
echo "--------------------------"
