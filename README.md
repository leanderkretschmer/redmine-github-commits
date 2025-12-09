# github_commits

Ein Redmine-Plugin, das GitHub-Repositories mit Redmine-Tickets verknüpft und Commits automatisch verfolgt. Das Plugin ermöglicht es, in jedem Ticket ein Git-Repository zu verlinken und zeigt alle zugehörigen Commits in einem eigenen Git-Tab an.

## Kompatibilität

- **Redmine 6.0+** (getestet mit Redmine 6.0.0 und Rails 7.2)
- **Ruby 3.3+**

## Features

- **Repository-Verknüpfung pro Ticket**: Jedes Ticket kann ein oder mehrere Git-Repositories verlinken
- **Git-Tab**: Neuer Tab "Git" im Ticket-View (neben "Historie" und "Eigenschaftsänderungen") zeigt alle Commits
- **Sidebar-Anzeige**: Letzte Commits werden in der Sidebar neben den Kommentaren angezeigt
- **Webhook-Unterstützung**: Unterstützt GitHub Webhooks für automatische Commit-Verarbeitung
- **Private Repositories**: Unterstützt private Repositories mit Repository-spezifischen Webhook-Secrets
- **Rückwärtskompatibel**: Unterstützt weiterhin das `#rm123` Pattern in Commit-Nachrichten

## Installation

1. Kopieren Sie das Plugin-Verzeichnis nach `plugins/github_commits` in Ihrer Redmine-Installation
2. Starten Sie Redmine neu - **keine Migrationen erforderlich!**
3. Das Plugin verwendet Redmine Custom Fields für die Speicherung (wird automatisch erstellt)

## Verwendung

### Repository-Verknüpfung

1. Öffnen Sie ein Ticket
2. Scrollen Sie nach unten zum Bereich "Repositories"
3. Geben Sie die Repository-URL ein (z.B. `https://github.com/owner/repo`)
4. Geben Sie optional ein Repository-spezifisches Webhook Secret ein
5. Klicken Sie auf "Hinzufügen"

### GitHub Webhook einrichten

1. Gehen Sie zu Ihrem GitHub-Repository → Settings → Webhooks
2. Klicken Sie auf "Add webhook"
3. **Payload URL**: `https://ihre-redmine-domain.com/github_commits/create_comment.json`
4. **Content type**: `application/json`
5. **Secret**: Verwenden Sie entweder:
   - Das globale `GITHUB_SECRET_TOKEN` (Umgebungsvariable), ODER
   - Das Repository-spezifische Secret (wenn im Ticket gesetzt)
6. **Events**: Wählen Sie "Just the push event" oder "Send me everything"
7. Klicken Sie auf "Add webhook"

### Commit-Verarbeitung

Das Plugin verarbeitet Commits auf zwei Arten:

1. **Repository-basiert**: Wenn ein Repository mit einem Ticket verknüpft ist, werden alle Commits zu diesem Repository automatisch dem Ticket zugeordnet
2. **Pattern-basiert**: Commits mit `#rm123` in der Nachricht werden dem entsprechenden Ticket zugeordnet (rückwärtskompatibel)

### Git-Tab

- Der Git-Tab erscheint automatisch, sobald ein Repository verknüpft ist oder Commits vorhanden sind
- Zeigt alle Commits mit SHA, Nachricht, Autor, Branch und Datum
- Commits sind anklickbar und führen direkt zur GitHub-Seite des Commits

### Sidebar

- Die letzten 10 Commits werden automatisch in der Sidebar angezeigt
- Klicken Sie auf "Alle Commits anzeigen" um zum Git-Tab zu gelangen

## Konfiguration

### Umgebungsvariable (optional)

Setzen Sie `GITHUB_SECRET_TOKEN` als globale Fallback-Option für Webhook-Verifizierung:

```bash
export GITHUB_SECRET_TOKEN="ihr-secret-token"
```

## Migration von alter Version

Wenn Sie von einer älteren Version migrieren:

1. Führen Sie die Migrationen aus: `rake redmine:plugins:migrate`
2. Bestehende Commits mit `#rm123` Pattern funktionieren weiterhin
3. Sie können nun zusätzlich Repositories direkt verlinken

## Entwicklung

### Tests ausführen

```bash
rake redmine:plugins:test:functionals RAILS_ENV=test
```

## Lizenz

Siehe LICENSE-Datei
