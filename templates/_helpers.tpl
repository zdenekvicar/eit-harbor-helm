{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.name" -}}
{{- default "harbor" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.fullname" -}}
{{- $name := default "harbor" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "harbor.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "harbor.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "harbor.name" . }}"
{{- end -}}

{{- define "harbor.isAutoGenedCertNeeded" -}}
  {{- if and (and .Values.ingress.enabled .Values.ingress.tls.enabled) (not .Values.ingress.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.notaryServiceName" -}}
{{- printf "%s-notary-server" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "harbor.fullname" . }}-database
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" | b64enc | quote -}}
  {{- else -}}
    {{- .Values.database.external.username | b64enc | quote -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.rawUsername" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.password" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password | b64enc | quote -}}
  {{- else -}}
    {{- .Values.database.external.password | b64enc | quote -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.coreDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "registry" -}}
  {{- else -}}
    {{- .Values.database.external.coreDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clairDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "postgres" -}}
  {{- else -}}
    {{- .Values.database.external.clairDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notaryServerDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "notaryserver" -}}
  {{- else -}}
    {{- .Values.database.external.notaryServerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.notarySignerDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "notarysigner" -}}
  {{- else -}}
    {{- .Values.database.external.notarySignerDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.sslmode" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.database.external.sslmode -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.clair" -}}
postgres://{{ template "harbor.database.rawUsername" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.clairDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notaryServer" -}}
postgres://{{ template "harbor.database.rawUsername" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notaryServerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notarySigner" -}}
postgres://{{ template "harbor.database.rawUsername" . }}:{{ template "harbor.database.rawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notarySignerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.redis.host" -}}
  {{- if .Values.redis.external.enabled -}}
    {{- .Values.redis.external.host -}}
  {{- else -}}
    {{- .Release.Name }}-redis-master
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.port" -}}
  {{- if .Values.redis.external.enabled -}}
    {{- .Values.redis.external.port -}}
  {{- else -}}
    {{- .Values.redis.master.port }}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.databaseIndex" -}}
  {{- if .Values.redis.external.enabled -}}
    {{- .Values.redis.external.databaseIndex -}}
  {{- else -}}
    {{- printf "%s" "0" }}
  {{- end -}}
{{- end -}}

{{- define "harbor.redis.password" -}}
  {{- if and .Values.redis.external.enabled .Values.redis.external.usePassword -}}
    {{- .Values.redis.external.password -}}
  {{- else if and (not .Values.redis.external.enabled) .Values.redis.usePassword -}}
    {{- .Values.redis.password -}}
  {{- end -}}
{{- end -}}

{{/*the username redis is used for a placeholder as no username needed in redis*/}}
{{- define "harbor.redisForJobservice" -}}
  {{- if and .Values.redis.external.enabled .Values.redis.external.usePassword -}}
    redis:{{ template "harbor.redis.password" . }}@{{ template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}/{{ template "harbor.redis.databaseIndex" }}
  {{- else if and (not .Values.redis.external.enabled) .Values.redis.usePassword -}}
    redis:{{ template "harbor.redis.password" . }}@{{ template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}/{{ template "harbor.redis.databaseIndex" }}
  {{- else }}
    {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}/{{ template "harbor.redis.databaseIndex" }}
  {{- end -}}
{{- end -}}

{{/*
host:port,pool_size,password
100 is the default value of pool size
*/}}
{{- define "harbor.redisForUI" -}}
  {{- template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }},100,{{ template "harbor.redis.password" . }}
{{- end -}}

{{- define "clair.config.yaml" -}}
clair:
  database:
    type: pgsql
    options:
      source: "{{ template "harbor.database.clair" . }}"
      # Number of elements kept in the cache
      # Values unlikely to change (e.g. namespaces) are cached in order to save prevent needless roundtrips to the database.
      cachesize: 16384

  api:
    # API server port
    port: 6060
    healthport: 6061

    # Deadline before an API request will respond with a 503
    timeout: 300s
  updater:
    interval: {{ .Values.clair.updatersInterval }}h

  notifier:
    attempts: 3
    renotifyinterval: 2h
    http:
      endpoint: "http://{{ template "harbor.fullname" . }}-ui/service/notifications/clair"
{{- end -}}

{{- define "server-config.postgres.json" -}}
{
  "server": {
    "http_addr": ":4443"
  },
  "trust_service": {
    "type": "remote",
    "hostname": "{{ template "harbor.fullname" . }}-notary-signer",
    "port": "7899",
    "tls_ca_file": "./notary-signer-ca.crt",
    "key_algorithm": "ecdsa"
  },
  "logging": {
    "level": "debug"
  },
  "storage": {
    "backend": "postgres",
    "db_url": "{{ template "harbor.database.notaryServer" . }}"
  },
  "auth": {
      "type": "token",
      "options": {
          "realm": "{{ .Values.externalURL }}/service/token",
          "service": "harbor-notary",
          "issuer": "harbor-token-issuer",
          "rootcertbundle": "/root.crt"
      }
  }
}
{{- end -}}

{{- define "signer-config.postgres.json" -}}
{
  "server": {
    "grpc_addr": ":7899",
    "tls_cert_file": "./notary-signer.crt",
    "tls_key_file": "./notary-signer.key"
  },
  "logging": {
    "level": "debug"
  },
  "storage": {
    "backend": "postgres",
    "db_url": "{{ template "harbor.database.notarySigner" . }}",
    "default_alias": "defaultalias"
  }
}
{{- end -}}

{{- define "registry.config.yaml" -}}
version: 0.1
log:
  level: {{ .Values.registry.logLevel }}
  fields:
    service: registry
storage:
  {{- $storage := .Values.registry.storage }}
  {{- $type := $storage.type }}
  {{- if eq $type "filesystem" }}
  filesystem:
    rootdirectory: {{ $storage.filesystem.rootdirectory }}
    {{- if $storage.filesystem.maxthreads }}
    maxthreads: {{ $storage.filesystem.maxthreads }}
    {{- end }}
  {{- else if eq $type "azure" }}
  azure:
    accountname: {{ $storage.azure.accountname }}
    container: {{ $storage.azure.container }}
    {{- if $storage.azure.realm }}
    realm: {{ $storage.azure.realm }}
    {{- end }}
  {{- else if eq $type "gcs" }}
  gcs:
    bucket: {{ $storage.gcs.bucket }}
    {{- if $storage.gcs.rootdirectory }}
    rootdirectory: {{ $storage.gcs.rootdirectory }}
    {{- end }}
    {{- if $storage.gcs.chunksize }}
    chunksize: {{ $storage.gcs.chunksize }}
    {{- end }}
  {{- else if eq $type "s3" }}
  s3:
    region: {{ $storage.s3.region }}
    bucket: {{ $storage.s3.bucket }}
    {{- if $storage.s3.regionendpoint }}
    regionendpoint: {{ $storage.s3.regionendpoint }}
    {{- end }}
    {{- if $storage.s3.encrypt }}
    encrypt: {{ $storage.s3.encrypt }}
    {{- end }}
    {{- if $storage.s3.secure }}
    secure: {{ $storage.s3.secure }}
    {{- end }}
    {{- if $storage.s3.v4auth }}
    v4auth: {{ $storage.s3.v4auth }}
    {{- end }}
    {{- if $storage.s3.chunksize }}
    chunksize: {{ $storage.s3.chunksize }}
    {{- end }}
    {{- if $storage.s3.rootdirectory }}
    rootdirectory: {{ $storage.s3.rootdirectory }}
    {{- end }}
    {{- if $storage.s3.storageclass }}
    storageclass: {{ $storage.s3.storageclass }}
    {{- end }}
  {{- else if eq $type "swift" }}
  swift:
    authurl: {{ $storage.swift.authurl }}
    username: {{ $storage.swift.username }}
    container: {{ $storage.swift.container }}
    {{- if $storage.swift.region }}
    region: {{ $storage.swift.region }}
    {{- end }}
    {{- if $storage.swift.tenant }}
    tenant: {{ $storage.swift.tenant }}
    {{- end }}
    {{- if $storage.swift.tenantid }}
    tenantid: {{ $storage.swift.tenantid }}
    {{- end }}
    {{- if $storage.swift.domain }}
    domain: {{ $storage.swift.domain }}
    {{- end }}
    {{- if $storage.swift.domainid }}
    domainid: {{ $storage.swift.domainid }}
    {{- end }}
    {{- if $storage.swift.trustid }}
    trustid: {{ $storage.swift.trustid }}
    {{- end }}
    {{- if $storage.swift.insecureskipverify }}
    insecureskipverify: {{ $storage.swift.insecureskipverify }}
    {{- end }}
    {{- if $storage.swift.chunksize }}
    chunksize: {{ $storage.swift.chunksize }}
    {{- end }}
    {{- if $storage.swift.prefix }}
    prefix: {{ $storage.swift.prefix }}
    {{- end }}
    {{- if $storage.swift.authversion }}
    authversion: {{ $storage.swift.authversion }}
    {{- end }}
    {{- if $storage.swift.endpointtype }}
    endpointtype: {{ $storage.swift.endpointtype }}
    {{- end }}
    {{- if $storage.swift.tempurlcontainerkey }}
    tempurlcontainerkey: {{ $storage.swift.tempurlcontainerkey }}
    {{- end }}
    {{- if $storage.swift.tempurlmethods }}
    tempurlmethods: {{ $storage.swift.tempurlmethods }}
    {{- end }}
  {{- else if eq $type "oss" }}
  oss:
    accesskeyid: {{ $storage.oss.accesskeyid }}
    region: {{ $storage.oss.region }}
    bucket: {{ $storage.oss.bucket }}
    {{- if $storage.oss.endpoint }}
    endpoint: {{ $storage.oss.endpoint }}
    {{- end }}
    {{- if $storage.oss.internal }}
    internal: {{ $storage.oss.internal }}
    {{- end }}
    {{- if $storage.oss.encrypt }}
    encrypt: {{ $storage.oss.encrypt }}
    {{- end }}
    {{- if $storage.oss.secure }}
    secure: {{ $storage.oss.secure }}
    {{- end }}
    {{- if $storage.oss.chunksize }}
    chunksize: {{ $storage.oss.chunksize }}
    {{- end }}
    {{- if $storage.oss.rootdirectory }}
    rootdirectory: {{ $storage.oss.rootdirectory }}
    {{- end }}
  {{- end }}
  cache:
    layerinfo: redis
  maintenance:
    uploadpurging:
      enabled: false
  delete:
    enabled: true
redis:
  addr: "{{ template "harbor.redis.host" . }}:{{ template "harbor.redis.port" . }}"
  password: {{ template "harbor.redis.password" . }}
  db: {{ template "harbor.redis.databaseIndex" . }}
http:
  addr: :5000
  # set via environment variable
  # secret: placeholder
  debug:
    addr: localhost:5001
auth:
  token:
    issuer: harbor-token-issuer
    realm: "{{ .Values.externalURL }}/service/token"
    rootcertbundle: /etc/registry/root.crt
    service: harbor-registry
notifications:
  endpoints:
    - name: harbor
      disabled: false
      url: http://{{ template "harbor.fullname" . }}-ui/service/notifications
      timeout: 3000ms
      threshold: 5
      backoff: 1s
{{- end -}}


{{- define "jobservice.config.yaml" -}}
protocol: "http"
port: 8080
worker_pool:
    workers: {{ .Values.jobservice.maxWorkers }}
    backend: "redis"
    redis_pool:
      redis_url: "{{ template "harbor.redisForJobservice" . }}"
      namespace: "harbor_job_service_namespace"
logger:
    path: "/var/log/jobs"
    level: "INFO"
    archive_period: 14 #days
admin_server: "http://{{ template "harbor.fullname" . }}-adminserver"
{{- end -}}