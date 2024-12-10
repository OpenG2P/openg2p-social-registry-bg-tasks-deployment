{{/*
Expand the name of the chart.
*/}}
{{- define "g2p-sr-bg.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "g2p-sr-bg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return podAnnotations
*/}}
{{- define "g2p-sr-bg.podAnnotations" -}}
{{- if .Values.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) }}
{{- end }}
{{- if and .Values.metrics.enabled .Values.metrics.podAnnotations }}
{{ include "common.tplvalues.render" (dict "value" .Values.metrics.podAnnotations "context" $) }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "g2p-sr-bg.serviceAccountName" -}}
{{ default (printf "%s" (include "common.names.fullname" .)) .Values.serviceAccount.name }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "g2p-sr-bg.fullname" -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "g2p-sr-bg.labels" -}}
helm.sh/chart: {{ include "g2p-sr-bg.chart" . }}
{{ include "g2p-sr-bg.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "g2p-sr-bg.selectorLabels" -}}
app.kubernetes.io/name: {{ include "g2p-sr-bg.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "g2p-sr-bg.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper  image name
*/}}
{{- define "g2p-sr-bg.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Unified template to render environment variables with type checks and possible valueFrom rendering.
*/}}
{{- define "g2p-sr-bg.envVars" -}}
{{- $context := . -}}  # We directly use the root context since 'context' was previously just the root passed as 'context'.
{{- $envVars := merge (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) dict -}}  # Merging all environment variable definitions into a single map.
{{- range $k, $v := $envVars }}
- name: {{ $k }}
  {{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
  value: {{ $v | quote }}
  {{- else if kindIs "string" $v }}
  value: {{ include "common.tplvalues.render" (dict "value" $v "context" $context) | squote }}
  {{- else }}
  valueFrom:
    {{- include "common.tplvalues.render" (dict "value" $v "context" $context) | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
