{{- define "spfa.name" -}}spfa{{- end -}}
{{- define "spfa.fullname" -}}{{ .Release.Name }}-{{ include "spfa.name" . }}{{- end -}}
