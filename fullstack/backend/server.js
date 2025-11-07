const express = require('express');
const app = express();
const PORT = 8080;

app.use(express.json()); // Erlaubt das Parsen von JSON im Request Body

// Verarbeitet die POST-Anfrage des Frontends
app.post('/api/submit-challenge', (req, res) => {
    const hostname = process.env.HOSTNAME || 'Unbekannt';
    const { name, songTitle, message, timestamp } = req.body;

    // 2. BACKEND LOG (Eingang & Daten)
    console.log(`[BACKEND] Nachricht vom Frontend empfangen.`);
    console.log(`[BACKEND]   Name: ${name}`);
    console.log(`[BACKEND]   Song: "${songTitle}"`);
    console.log(`[BACKEND]   Message: "${message.substring(0, 50)}..."`); // Erste 50 Zeichen
    console.log(`[BACKEND]   Timestamp: ${timestamp}`);
    console.log(`[BACKEND]   Quelle: IP ${req.ip}`);

    // --- SIMULATION DATABASE SCHREIBEN ---
    const dbService = 'db-service:5432'; // Der Kubernetes Service-Name der Datenbank

    // 3. BACKEND LOG (DB Interaktion)
    // Im echten Fall würde hier Code stehen, der eine Verbindung zur DB aufbaut und die Daten speichert.
    // Wir protokollieren vom Backend aus, dass die Info an die DB gesendet (simuliert) wurde.
    console.log(`[BACKEND] Bereite Daten für die Speicherung in der Datenbank vor.`);
    console.log(`[BACKEND] Versuch, DB zu kontaktieren über Service: ${dbService}`);
    // Hier würde die eigentliche Datenbank-Logik folgen (z.B. ein INSERT INTO...)

    // 4. DB LOG (SIMULIERT - da das Backend der einzige ist, der direkt mit der DB spricht)
    // Dieser Log würde im Backend-Pod erscheinen, simuliert aber die Handlung der DB.
    console.log(`[DB-SIMULATED] Daten für "${name}" (${songTitle}) erfolgreich verarbeitet und bereit zur Speicherung.`);
    
    // Antwort an das Frontend senden
    res.json({
        status: `Deine Blues-Message wurde erfolgreich verarbeitet! (Simuliert)`,
        pod_hostname: hostname,
        db_connection_target: dbService
    });
    
    console.log(`[BACKEND] Antwort 200 an Frontend gesendet. Verarbeitung abgeschlossen.`);
});

app.listen(PORT, () => {
    console.log(`[BACKEND] API lauscht auf Port ${PORT}`);
});
