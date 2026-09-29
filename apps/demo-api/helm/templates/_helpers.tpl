{{- define "demo-api.name" -}}
demo-api
{{- end -}}

{{- define "demo-api.labels" -}}
app.kubernetes.io/name: {{ include "demo-api.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
