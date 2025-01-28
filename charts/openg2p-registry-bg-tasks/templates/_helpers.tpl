{{- define "registry-bg-tasks.serviceAccountName" -}}
{{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- end -}}

{{- define "registry-bg-tasks.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.producer.image .Values.worker.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Render Env values section
*/}}
{{- define "registry-bg-tasks.baseEnvVars" -}}
{{- $context := .context -}}
{{- range $k, $v := .envVars }}
- name: {{ $k }}
{{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
  value: {{ $v | quote }}
{{- else if kindIs "string" $v }}
  value: {{ include "common.tplvalues.render" ( dict "value" $v "context" $context ) | squote }}
{{- else }}
  valueFrom: {{- include "common.tplvalues.render" ( dict "value" $v "context" $context ) | nindent 4}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "registry-bg-tasks.producer.envVars" -}}
{{- $envVars := merge (deepCopy .Values.commonEnvVars) (deepCopy .Values.commonEnvVarsFrom) (deepCopy .Values.producer.envVars) (deepCopy .Values.producer.envVarsFrom) -}}
{{- include "registry-bg-tasks.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}

{{- define "registry-bg-tasks.worker.envVars" -}}
{{- $envVars := merge (deepCopy .Values.commonEnvVars) (deepCopy .Values.commonEnvVarsFrom) (deepCopy .Values.worker.envVars) (deepCopy .Values.worker.envVarsFrom) -}}
{{- include "registry-bg-tasks.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}
