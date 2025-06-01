{{/*
Generate the full name of the resource.
*/}}
{{- define "my-app.fullname" -}}
{{ .Release.Name }}
{{- end -}}

{{/*
Generate the name of the app.
*/}}
{{- define "my-app.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Generate common labels for all resources.
*/}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Generate selector labels for a specific component.
*/}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
