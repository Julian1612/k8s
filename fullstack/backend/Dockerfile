# Basis Image für Node.js
FROM node:20-alpine

# Setze das Arbeitsverzeichnis im Container
WORKDIR /usr/src/app

# Kopiere package.json und installiere Abhängigkeiten
COPY package.json .
RUN npm install

# Kopiere den Rest des Codes
COPY . .

# Exponiere den Port, auf dem die App lauscht
EXPOSE 8080

# Starte die Anwendung
CMD [ "npm", "start" ]
