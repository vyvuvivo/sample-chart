{{/*
Return the image string, supporting global.imageRegistry override.
If global.imageRegistry is set, use it as the registry.
If image.registry is "ghcr.io", include the registry in the image string.
Otherwise, use image.repository directly.
*/}}
{{- define "common.image" -}}
{{- $globalRegistry := "" }}
{{- if and (hasKey .Values "global") (hasKey .Values.global "imageRegistry") }}
  {{- $globalRegistry = .Values.global.imageRegistry }}
{{- end }}
{{- $registry := default .Values.image.registry $globalRegistry }}
{{- $repository := .Values.image.repository }}
{{- $tag := default .Values.image.tag .Chart.AppVersion }}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}


{{/*
Return the imagePullSecrets list, combining global.imagePullSecrets and image.imagePullSecrets.
*/}}
{{- define "common.imagePullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if and (hasKey .Values "global") (hasKey .Values.global "imagePullSecrets") }}
    {{- $pullSecrets = append $pullSecrets .Values.global.imagePullSecrets -}}
  {{- end -}}

  {{- if .Values.image.pullSecret }}
    {{- $pullSecrets = append $pullSecrets .Values.image.pullSecret -}}
  {{- end -}}
  
  {{- $pullSecrets = uniq $pullSecrets }}

  {{- if (not (empty $pullSecrets)) }}
  {{- range $pullSecrets }}
- name: {{ . }}
  {{- end }}
  {{- end }}
{{- end -}}