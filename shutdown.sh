#/bin/bash

# --- Konfiguration ---
K8S_MANIFESTS_DIR="k8s"

# --- Funktionen ---

# Prüft den Exit-Code des letzten Befehls
check_status() {
    if [ $? -ne 0 ]; then
        echo "⚠️ WARNUNG: $1 konnte nicht erfolgreich ausgeführt werden. Wird ignoriert und fortgesetzt." >&2
        # Wir ignorieren Fehler hier, da z.B. das Löschen von Ressourcen fehlschlägt,
        # wenn diese bereits gelöscht wurden.
    fi
}

echo "#############################################"
echo "🗑️ 1. Kubernetes Ressourcen löschen"
echo "#############################################"

# Löscht alle Deployments, Services und Ingress-Ressourcen,
# basierend auf den Manifest-Dateien im k8s/ Ordner.
echo "   -> Lösche Deployments, Services und Ingress..."
kubectl delete -f ${K8S_MANIFESTS_DIR} --ignore-not-found=true
check_status "Kubernetes Ressourcen löschen"
echo "   -> Alle Anwendungs-Ressourcen gelöscht."

echo "#############################################"
echo "🛑 2. Minikube stoppen und löschen"
echo "#############################################"

# Stoppt die Minikube-VM
echo "   -> Stoppe Minikube-VM..."
minikube stop
check_status "Minikube Stopp"

# Löscht die Minikube-VM und alle darin gespeicherten Docker Images
echo "   -> Lösche Minikube-VM und alle Daten permanent..."
minikube delete
check_status "Minikube Delete"

echo "#############################################"
echo "✅ CLEANUP ABGESCHLOSSEN"
echo "#############################################"
echo "Dein System ist jetzt sauber. Führe 'start_k8s_cluster.sh' aus, um neu zu starten."
