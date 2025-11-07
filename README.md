Nr.,CKAD Thema,Ressource,Ziel / Matrix-Easter Egg,Spezifische Anforderungen
I. Basiskonfiguration & Sicherheit (Die Initialisierung),,,,
1.1,ConfigMaps,oracle-config (ConfigMap),"Speicherung der globalen ""Orakel""-Nachrichten.",Frontend-Nachrichten als Key-Value-Paare speichern.
1.2,Secrets,morpheus-access-secret (Secret),Speicherung des Agent Smith API-Tokens & DB-Passworts.,Daten müssen Base64-kodiert sein.
1.3,ServiceAccounts/RBAC,morpheus-monitor-sa (ServiceAccount),Identität für den Monitoring-Sidecar-Pod.,Nur Lesezugriff auf Pods und Deployments.
1.4,ServiceAccounts/RBAC,pod-reader (Role),Definiert die Berechtigung zum Lesen von Pods.,"Erlaubt get, list, watch auf die Ressource pods."
1.5,ServiceAccounts/RBAC,monitor-binding (RoleBinding),Bindet die Rolle an den ServiceAccount.,Bindet morpheus-monitor-sa an die pod-reader Role.
---,---,---,---,---
II. Speicher & Workloads (Die Pod-Fabrik),,,,
2.1,Image Management,Dockerfile,Erstellung des redpill-frontend-Images.,Muss Multi-Stage-Build nutzen und den SecurityContext-User berücksichtigen.
2.2,PV/PVC,matrix-db-pv (PV),Definiert den Speicherbereich (für Minikube).,Typ hostPath (für lokale Minikube-Umgebung) mit 1Gi Größe.
2.3,PV/PVC,db-data-pvc (PVC),Fordert den persistenten Speicher für die DB an.,Request 1Gi Speicher.
2.4,Multi-Container / Init,backend-api (Deployment),Simuliert das API-Backend.,"Nutzt Init Container (""The Keymaker"") zur DB-Migrationssimulation (muss warten auf DB)."
2.5,Multi-Container / Sidecar,frontend-web (Deployment),Das zentrale Frontend der Anwendung.,"Pod nutzt Sidecar-Container (""Cypher-Spy-Logger"") zum Log-Monitoring. Nutzt emptyDir Volume zur Dateifreigabe."
2.6,Ressourcen/SecContexts,(Frontend Pod),Definiert garantierte Ressourcen und Sicherheit.,Pod muss runAsUser: 1000 nutzen. Container muss Request (z.B. 100m CPU) und Limit (z.B. 200Mi Memory) definieren.
---,---,---,---,---
III. Workload-Automatisierung (Die Programmierung),,,,
3.1,Jobs,oracle-backup-job (Job),Einmalige Aufgabe: Backup der Konfiguration.,Container führt ein kurzes Skript aus und terminiert erfolgreich.
3.2,CronJobs,wakeup-call (CronJob),Wiederkehrende Aufgabe: Tägliches Prüfen des Backend-Status.,"schedule auf einen täglichen Intervall setzen (z.B. ""0 3 * * *"")."
---,---,---,---,---
IV. Networking & Observability (Der Zugangspunkt),,,,
4.1,Services,matrix-db-svc (ClusterIP),Interner Zugriff für das Backend auf die Datenbank.,Typ ClusterIP. Selektiert die DB-Pods.
4.2,Services,backend-api-svc (ClusterIP),Interner Zugriff für das Frontend auf das Backend-API.,Typ ClusterIP.
4.3,Services,nodeport-frontend-svc (NodePort),Exponiert das Frontend für den direkten Minikube-Zugriff.,Typ NodePort. Port 80.
4.4,Services,lb-frontend-svc (LoadBalancer),Simuliert den Cloud-Zugriff.,Typ LoadBalancer.
4.5,Liveness/Readiness,(Frontend Pod),Stellt Verfügbarkeit und Bereitschaft sicher.,livenessProbe (httpGet) und readinessProbe (httpGet) auf den Hauptcontainer setzen.
4.6,NetworkPolicies,db-isolation-policy (NetworkPolicy),Isoliert die Datenbank-Pods.,Erlaubt eingehenden Traffic (Ingress) nur von Pods mit Label app: backend-api.
4.7,Ingress,redpill-ingress (Ingress),Externer Zugriff über einen Hostnamen.,Konfiguriert einen host (redpill.matrix) und leitet Anfragen an nodeport-frontend-svc weiter.
---,---,---,---,---
V. Helm-Deployment (Die Schiffssteuerung),,,,
5.1,Helm-Charts,Helm Chart (redpill-chart),Bündelung des gesamten Frontend-Deployments.,"Chart muss Deployment, Service (NodePort) und ConfigMap enthalten."
5.2,Helm-Charts,values.yaml (Datei),Konfigurierbarkeit des Deployments.,"Muss die replicaCount, den serviceType (NodePort/ClusterIP) und die MATRIX_TITLE konfigurierbar machen."
5.3,Helm-Charts,Templating,Dynamische YAML-Generierung.,"Nutzt Conditional Logic (if/else), um verschiedene Service-Typen basierend auf values.yaml zu erstellen."
