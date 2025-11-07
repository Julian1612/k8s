cument.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('challengeForm');
    const submitButton = document.getElementById('submitButton');
    const responseMessageDiv = document.getElementById('responseMessage');

    // WICHTIG: Wir nutzen den relativen Pfad /api/submit-challenge.
    // Dieser wird vom Browser zur aktuellen Host-IP gesendet und dann
    // durch den Kubernetes Ingress-Controller an den 'backend-service:8080' geroutet!
    const backendUrl = '/api/submit-challenge'; 

    form.addEventListener('submit', async (event) => {
        event.preventDefault(); // Verhindert das Neuladen der Seite

        // 1. FRONTEND LOG (Wird im Browser-Konsole erscheinen)
        console.log('[FRONTEND] "Sende Blues-Message!" Button geklickt. Sammle Formulardaten.');
        
        submitButton.textContent = 'Sende Daten an Backend...';
        submitButton.disabled = true;
        responseMessageDiv.classList.add('hidden');
        responseMessageDiv.classList.remove('error');

        const formData = {
            name: document.getElementById('name').value,
            songTitle: document.getElementById('songTitle').value,
            message: document.getElementById('message').value,
            timestamp: new Date().toISOString(),
        };

        try {
            console.log('[FRONTEND] Sende POST-Anfrage an Backend über Ingress Pfad:', backendUrl);
            const response = await fetch(backendUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            });
            
            // Prüfen, ob die Antwort erfolgreich war (Status 200-299)
            if (!response.ok) {
                throw new Error(`HTTP Fehler! Status: ${response.status}`);
            }

            const data = await response.json();

            // Erfolgsmeldung anzeigen
            responseMessageDiv.innerHTML = `
                <p>Nachricht empfangen! Dein Status:</p>
                <p><strong>${data.status}</strong></p>
                <small>Verarbeitet von Backend Pod: ${data.pod_hostname}</small>
            `;
            responseMessageDiv.classList.remove('hidden');
            responseMessageDiv.style.backgroundColor = '#27ae60'; // Grüner Hintergrund
            submitButton.textContent = 'Blues-Message gesendet!';
            form.reset(); // Formular zurücksetzen

        } catch (error) {
            // Fehlerbehandlung
            console.error('[FRONTEND ERROR] Fehler bei der API-Anfrage:', error);
            responseMessageDiv.innerHTML = `
                <p>❌ Fehler beim Senden deiner Blues-Message!</p>
                <p>Prüfe die Backend-Logs (kubectl logs -f <PodName>) und stelle sicher, dass Ingress läuft.</p>
                <p>Fehlerdetails: ${error.message}</p>
            `;
            responseMessageDiv.classList.remove('hidden');
            responseMessageDiv.classList.add('error'); // Roter Hintergrund
            submitButton.textContent = 'Fehler aufgetreten!';
        } finally {
            submitButton.disabled = false;
        }
    });
});
