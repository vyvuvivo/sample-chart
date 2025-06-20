{{/*
Return a soft nodeAffinity definition 
{{ include "common.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
{{- range .values }}
            - {{ . }}
{{- end }}
    weight: 1
{{- end -}}

{{/*
Return a hard nodeAffinity definition
{{ include "common.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
{{- range .values }}
            - {{ . }}
{{- end }}
{{- end -}}

{{/*
Return a nodeAffinity definition
{{ include "common.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.nodes" -}}
{{- if eq .type "soft" }}
{{- include "common.affinities.nodes.soft" . | nindent 0 }}
{{- else if eq .type "hard" }}
{{- include "common.affinities.nodes.hard" . | nindent 0 }}
{{- end }}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods.soft" (dict "name" "FOO" "context" $) -}}
*/}}
{{- define "common.affinities.pods.soft" -}}
{{- $name := default "" .name -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels:
{{- (include "common.selectorLabels" .context) | nindent 10 }}
{{- if not (empty $name) }}
          app.kubernetes.io/name: {{ $name }}
{{- end }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods.hard" (dict "name" "FOO" "context" $) -}}
*/}}
{{- define "common.affinities.pods.hard" -}}
{{- $name := default "" .name -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
{{- (include "common.selectorLabels" .context) | nindent 8 }}
{{- if not (empty $name) }}
        app.kubernetes.io/name: {{ $name }}
{{- end }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "common.affinities.pods" -}}
{{- if eq .type "soft" }}
{{- include "common.affinities.pods.soft" . | nindent 0 }}
{{- else if eq .type "hard" }}
{{- include "common.affinities.pods.hard" . | nindent 0 }}
{{- end }}
{{- end -}}

{{/*
Return a full affinity definition
Usage:
{{ include "common.affinities" (dict "node" ... "pod" ... "podAnti" ... "context" $) }}
If no node/pod/podAnti are passed, default to soft podAntiAffinity with matchLabel app.kubernetes.io/name = {{ .Chart.Name }}
*/}}
{{- define "common.affinities" -}}
{{- $ctx := .context | default . }}
affinity:
{{- if .node }}
  nodeAffinity:
{{- include "common.affinities.nodes" .node | nindent 4 }}
{{- end }}

{{- if .pod }}
  podAffinity:
{{- include "common.affinities.pods" (merge (dict "context" .context) .pod) | nindent 4 }}
{{- end }}

{{- if .podAnti }}
  podAntiAffinity:
{{- include "common.affinities.pods" (merge (dict "context" .context) .podAnti) | nindent 4 }}
{{- else }}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: {{ $ctx.Chart.Name }}
          topologyKey: kubernetes.io/hostname
{{- end }}
{{- end -}}