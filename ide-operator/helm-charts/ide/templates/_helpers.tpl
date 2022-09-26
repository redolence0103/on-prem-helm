# {{- define "ide.hashName" -}}
# {{- if .Values.hashName }}
# {{- .Values.hashName | trunc 63 | trimSuffix "-" }}
# {{- end }}
# {{- end }}

# {{- define "ide.chart" -}}
# {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
# {{- end }}

# {{/*
# Selector labels
# */}}
# {{- define "ide.selectorLabels" -}}
# app.kubernetes.io/name: {{ include "ide.hashName" . }}
# app.kubernetes.io/instance: {{ .Release.Name }}
# {{- end }}

# {{/*
# Common labels
# */}}
# {{- define "ide.labels" -}}
# helm.sh/chart: {{ include "ide.chart" . }}
# {{ include "ide.selectorLabels" . }}
# {{- if .Chart.AppVersion }}
# app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
# {{- end }}
# app.kubernetes.io/managed-by: {{ .Release.Service }}
# {{- end }}

# {{/*
# Create the name of the service account to use
# */}}
# {{- define "ide.serviceAccountName" -}}
# {{- if .Values.serviceAccount.csreate }}
# {{- default (include "ide.hashName" .) .Values.serviceAccount.name }}
# {{- else }}
# {{- default "default" .Values.serviceAccount.name }}
# {{- end }}
# {{- end }}