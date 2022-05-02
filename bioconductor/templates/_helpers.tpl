{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bioconductor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bioconductor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "bioconductor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "bioconductor.labels" -}}
helm.sh/chart: {{ include "bioconductor.chart" . }}
{{ include "bioconductor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "bioconductor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bioconductor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "bioconductor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "bioconductor.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return which PVC to use
*/}}
{{- define "bioconductor.pvcname" -}}
{{- if .Values.persistence.existingClaim -}}
{{- printf "%s" .Values.persistence.existingClaim -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.persistence.name -}}
{{- end -}}
{{- end -}}

{{/*
Return which PVC to use for libraries
*/}}
{{- define "bioconductor.librariesClaimName" -}}
{{- if .Values.libraries.persistence.separateClaim.existingClaim -}}
{{- printf "%s" .Values.libraries.persistence.separateClaim.existingClaim -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.libraries.persistence.separateClaim.name -}}
{{- end -}}
{{- end -}}

{{/*
Creates the bash command for the init containers used to place files and change permissions in the rstudio pods
*/}}
{{- define "bioconductor.init-container-commands" -}}
{{- if and .Values.libraries.persistence.enabled (not .Values.libraries.persistence.separateClaim.enabled) }}
mkdir -p {{.Values.persistence.mountPath}}/persisted-library/R;
{{- end }}
cp -anrL /opt/configs/readonly/rstudio/ /home/;
chown -R rstudio:rstudio /home/rstudio;
{{- end -}}

