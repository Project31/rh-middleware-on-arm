#
# Do not edit, this is a generated file.  To regenerate,  run: ./generator/run.sh
#
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: syndesis
#
# Template flavor:
#
# Allow localhost refs: false
# Use docker images: false
# Syndesis Tag: latest
# Prometheus Tag: v2.1.0
# Postgresql Tag: 9.5
# OAuthProxy Tag: v4.0.0
#
  labels:
    app: syndesis
    syndesis.io/app: syndesis
    syndesis.io/type: infrastructure
parameters:
- name: ROUTE_HOSTNAME
  description: The external hostname to access Syndesis
- name: OPENSHIFT_MASTER
  description: Public OpenShift master address
  value: https://localhost:8443
  required: true
- name: OPENSHIFT_CONSOLE_URL
  description: The URL to the OpenShift console
  displayName: OpenShift Console URL
- name: OPENSHIFT_PROJECT
  description: The name of the OpenShift project Syndesis is being deployed into.
  displayName: OpenShift project to deploy into
  required: true
- name: SAR_PROJECT
  description: The user needs to have permissions to at least get a list of pods in the given project in order to be granted access to the Syndesis installation in the $OPENSHIFT_PROJECT
  displayName: OpenShift project to be used to authenticate the user against
  required: true
- name: OPENSHIFT_OAUTH_CLIENT_SECRET
  description: OpenShift OAuth client secret
  generate: expression
  from: "[a-zA-Z0-9]{64}"
  required: true
- description: Maximum amount of memory the PostgreSQL container can use.
  displayName: Memory Limit
  name: POSTGRESQL_MEMORY_LIMIT
  value: 255Mi
- description: The OpenShift Namespace where the PostgreSQL ImageStream resides.
  displayName: Namespace
  name: POSTGRESQL_IMAGE_STREAM_NAMESPACE
  value: openshift
- description: Username for PostgreSQL user that will be used for accessing the database.
  displayName: PostgreSQL Connection Username
  name: POSTGRESQL_USER
  value: syndesis
- description: Password for the PostgreSQL connection user.
  displayName: PostgreSQL Connection Password
  from: '[a-zA-Z0-9]{16}'
  generate: expression
  name: POSTGRESQL_PASSWORD
  required: true
- description: Name of the PostgreSQL database accessed.
  displayName: PostgreSQL Database Name
  name: POSTGRESQL_DATABASE
  required: true
  value: syndesis
- description: Volume space available for PostgreSQL data, e.g. 512Mi, 2Gi.
  displayName: PostgreSQL Volume Capacity
  name: POSTGRESQL_VOLUME_CAPACITY
  required: true
  value: 1Gi
- description: Password for the PostgreSQL sampledb user.
  displayName: PostgreSQL SampleDB Connection Password
  from: '[a-zA-Z0-9]{16}'
  generate: expression
  name: POSTGRESQL_SAMPLEDB_PASSWORD
  required: true
- description: Enables test-support endpoint on backend API
  displayName: Test Support Enabled
  name: TEST_SUPPORT_ENABLED
  required: true
  value: "false"
- description: Enables starting up with demo data
  displayName: Demo Data Enabled
  name: DEMO_DATA_ENABLED
  required: true
  value: "false"
- description: Registry from where to fetch Syndesis images
  displayName: Syndesis Image Registry
  name: SYNDESIS_REGISTRY
  value: 'docker.io'
- description: Should deployment of integrations be enabled?
  displayName: Enable Integration Deployment
  name: CONTROLLERS_INTEGRATION_ENABLED
  value: 'true'
- description: Namespace containing image streams
  displayName: Image Stream Namespace
  name: IMAGE_STREAM_NAMESPACE
  value: ''
- description: Secret to use to encrypt oauth cookies
  displayName: OAuth Cookie Secret
  name: OAUTH_COOKIE_SECRET
  generate: expression
  from: '[a-zA-Z0-9]{32}'
- name: SYNDESIS_ENCRYPT_KEY
  description: The encryption key used to encrypt/decrypt stored secrets
  generate: expression
  from: "[a-zA-Z0-9]{64}"
  required: true
- description: Volume space available for Prometheus data, e.g. 512Mi, 2Gi.
  displayName: Prometheus Volume Capacity
  name: PROMETHEUS_VOLUME_CAPACITY
  value: 1Gi
  required: true
- description: Maximum amount of memory the Prometheus container can use.
  displayName: Memory Limit
  name: PROMETHEUS_MEMORY_LIMIT
  value: 512Mi
  required: true
- description: Volume space available for Meta data, e.g. 512Mi, 2Gi.
  displayName: Meta Volume Capacity
  name: META_VOLUME_CAPACITY
  required: true
  value: 1Gi
  required: true
- description: Maximum amount of memory the syndesis-meta service might use.
  displayName: Memory Limit
  name: META_MEMORY_LIMIT
  value: 512Mi
  required: true
- description: Maximum amount of memory the syndesis-server service might use.
  displayName: Memory Limit
  name: SERVER_MEMORY_LIMIT
  value: 800Mi
  required: true
- description: Maximum number of integrations single user can create
  displayName: Maximum number of integrations
  name: MAX_INTEGRATIONS_PER_USER
  value: "1"
  required: true
- description: Interval for checking the state of the integrations.
  displayName: Integration state check interval
  name: INTEGRATION_STATE_CHECK_INTERVAL
  value: "60"
  required: true
- description: Key used to perform authentication of client side stored state.
  displayName: Client side state authentication key
  from: '[a-zA-Z0-9]{32}'
  generate: expression
  name: CLIENT_STATE_AUTHENTICATION_KEY
  required: true
- description: Key used to perform encryption of client side stored state.
  displayName: Client side state encryption key
  from: '[a-zA-Z0-9]{32}'
  generate: expression
  name: CLIENT_STATE_ENCRYPTION_KEY
  required: true
- description: Volume space available for the upgrade process (backup data), e.g. 512Mi, 2Gi.
  displayName: Upgrade Volume Capacity
  name: UPGRADE_VOLUME_CAPACITY
  required: true
  value: 1Gi
- description: How to expose services, via OpenShift Route (false) or via 3scale (true)
  displayName: Expose services via 3scale
  name: CONTROLLERS_EXPOSE_VIA3SCALE
  required: true
  value: 'false'
message: |-
  Syndesis is deployed to ${ROUTE_HOSTNAME}.
objects:
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: syndesis-server
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/syndesis/syndesis-server:latest
      importPolicy:
        scheduled: true
      name: "latest"
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: syndesis-ui
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-ui
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/syndesis/syndesis-ui:latest
      importPolicy:
        scheduled: true
      name: "latest"
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: syndesis-meta
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-meta
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/syndesis/syndesis-meta:latest
      importPolicy:
        scheduled: true
      name: "latest"
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: oauth-proxy
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-oauthproxy
  spec:
    tags:
    - from:
        kind: DockerImage
        name: quay.io/openshift/origin-oauth-proxy:v4.0.0
      importPolicy:
        scheduled: true
      name: "v4.0.0"
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: prometheus
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/prom/prometheus:v2.1.0
      importPolicy:
        scheduled: true
      name: "v2.1.0"
- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: postgres_exporter
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db-metrics
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/wrouesnel/postgres_exporter:v0.4.7
      importPolicy:
        scheduled: true
      name: "v0.4.7"

- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    name: syndesis-s2i
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: s2i-java
  spec:
    tags:
    - from:
        kind: DockerImage
        name: ${SYNDESIS_REGISTRY}/syndesis/syndesis-s2i:latest
      importPolicy:
        scheduled: true
      name: "latest"

- apiVersion: v1
  kind: Secret
  metadata:
    name: syndesis-oauth-proxy-cookie-secret
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  stringData:
    oauthCookieSecret: ${OAUTH_COOKIE_SECRET}
- apiVersion: v1
  kind: Secret
  metadata:
    name: syndesis-server-secret
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  stringData:
    clientStateAuthenticationKey: ${CLIENT_STATE_AUTHENTICATION_KEY}
    clientStateEncryptionKey: ${CLIENT_STATE_ENCRYPTION_KEY}
- apiVersion: v1
  kind: Secret
  metadata:
    name: syndesis-global-config
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  stringData:
    syndesis: "latest"
    postgresql: "9.5"
    oauthproxy: "v4.0.0"
    prometheus: "v2.1.0"
    params: |-
      ROUTE_HOSTNAME=${ROUTE_HOSTNAME}
      OPENSHIFT_MASTER=${OPENSHIFT_MASTER}
      OPENSHIFT_PROJECT=${OPENSHIFT_PROJECT}
      OPENSHIFT_OAUTH_CLIENT_SECRET=${OPENSHIFT_OAUTH_CLIENT_SECRET}
      POSTGRESQL_MEMORY_LIMIT=${POSTGRESQL_MEMORY_LIMIT}
      POSTGRESQL_IMAGE_STREAM_NAMESPACE=${POSTGRESQL_IMAGE_STREAM_NAMESPACE}
      POSTGRESQL_USER=${POSTGRESQL_USER}
      POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD}
      POSTGRESQL_DATABASE=${POSTGRESQL_DATABASE}
      POSTGRESQL_VOLUME_CAPACITY=${POSTGRESQL_VOLUME_CAPACITY}
      POSTGRESQL_SAMPLEDB_PASSWORD=${POSTGRESQL_SAMPLEDB_PASSWORD}
      TEST_SUPPORT_ENABLED=${TEST_SUPPORT_ENABLED}
      DEMO_DATA_ENABLED=${DEMO_DATA_ENABLED}
      SYNDESIS_REGISTRY=${SYNDESIS_REGISTRY}
      CONTROLLERS_INTEGRATION_ENABLED=${CONTROLLERS_INTEGRATION_ENABLED}
      IMAGE_STREAM_NAMESPACE=${IMAGE_STREAM_NAMESPACE}
      OAUTH_COOKIE_SECRET=${OAUTH_COOKIE_SECRET}
      SYNDESIS_ENCRYPT_KEY=${SYNDESIS_ENCRYPT_KEY}
      PROMETHEUS_MEMORY_LIMIT=${PROMETHEUS_MEMORY_LIMIT}
      PROMETHEUS_VOLUME_CAPACITY=${PROMETHEUS_VOLUME_CAPACITY}
- apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: syndesis-default
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-infrastructure
- apiVersion: v1
  kind: Service
  metadata:
    name: syndesis-ui
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-ui
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-ui
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-ui
    name: syndesis-ui
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-ui
    strategy:
      rollingParams:
        intervalSeconds: 1
        maxSurge: 25%
        maxUnavailable: 25%
        timeoutSeconds: 600
        updatePeriodSeconds: 1
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
      type: Rolling
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/type: infrastructure
          syndesis.io/component: syndesis-ui
      spec:
        serviceAccountName: syndesis-default
        containers:
        - name: syndesis-ui
          image: ' '

          imagePullPolicy: IfNotPresent
          livenessProbe:
            httpGet:
              path: "/"
              port: 8080
            initialDelaySeconds: 30
          readinessProbe:
            httpGet:
              path: "/"
              port: 8080
            initialDelaySeconds: 1
          ports:
          - containerPort: 8080
          volumeMounts:
          - mountPath: /usr/share/nginx/html/config
            name: config-volume
          # Set to burstable with a low memory footprint to start (50 Mi)
          resources:
            limits:
              memory: 255Mi
            requests:
              memory: 50Mi
        volumes:
        - configMap:
            name: syndesis-ui-config
          name: config-volume
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - syndesis-ui
        from:
          kind: ImageStreamTag
          name: syndesis-ui:latest
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange

    - type: ConfigChange
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: syndesis-ui-config
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-ui
  data:
    config.json: |
      {
        "apiBase": "https://${ROUTE_HOSTNAME}",
        "apiEndpoint": "/api/v1",
        "title": "Syndesis",
        "consoleUrl": "${OPENSHIFT_CONSOLE_URL}",
        "project": "${OPENSHIFT_PROJECT}",
        "datamapper": {
          "baseMappingServiceUrl": "https://${ROUTE_HOSTNAME}/api/v1/atlas/",
          "baseJavaInspectionServiceUrl": "https://${ROUTE_HOSTNAME}/api/v1/atlas/java/",
          "baseXMLInspectionServiceUrl": "https://${ROUTE_HOSTNAME}/api/v1/atlas/xml/",
          "baseJSONInspectionServiceUrl": "https://${ROUTE_HOSTNAME}/api/v1/atlas/json/",
          "disableMappingPreviewMode": false
        },
        "features" : {
          "logging": false
        },
        "branding": {
          "appName": "Syndesis",
          "favicon32": "/favicon-32x32.png",
          "favicon16": "/favicon-16x16.png",
          "touchIcon": "/apple-touch-icon.png",
          "productBuild": false
       }
      }

- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: syndesis-db-metrics-config
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db-metrics
  data:
    queries.yaml: |
        pg_database:
          query: " SELECT pg_database.datname, pg_database_size(pg_database.datname) as size FROM pg_database"
          metrics:
            - datname:
                usage: "LABEL"
                description: "Name of the database"
            - size:
                usage: "GAUGE"
                description: "Disk space used by the database"

- apiVersion: v1
  kind: ConfigMap
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db
    name: syndesis-sampledb-config
  data:
    add-sample-db.sh: |
      #!/bin/bash
      until bash -c "psql -h 127.0.0.1 -U $POSTGRESQL_USER -q -d $POSTGRESQL_DATABASE -c 'SELECT 1'"; do
        echo "Waiting for Postgres server..."
        sleep 1
      done
      echo "***** creating sampledb"
      psql <<EOF
        CREATE DATABASE sampledb;
        CREATE USER sampledb WITH PASSWORD '$POSTGRESQL_SAMPLEDB_PASSWORD';
        GRANT ALL PRIVILEGES ON DATABASE sampledb to sampledb;
      EOF
      psql -d sampledb -U sampledb <<'EOF'
        CREATE TABLE IF NOT EXISTS contact (first_name VARCHAR, last_name VARCHAR, company VARCHAR, lead_source VARCHAR, create_date DATE);
        INSERT INTO contact VALUES ('Joe','Jackson','Red Hat','db',current_timestamp);
        CREATE TABLE IF NOT EXISTS todo (id SERIAL PRIMARY KEY, task VARCHAR, completed INTEGER);
        CREATE OR REPLACE FUNCTION add_lead(
          first_and_last_name varchar,
          company varchar,
          phone varchar,
          email varchar,
          lead_source varchar,
          lead_status varchar,
          rating varchar)

          RETURNS void
          LANGUAGE 'plpgsql'

        AS $BODY$
        DECLARE
          task varchar;
        BEGIN
          task := concat(lead_status || ' ', 'Lead: Please contact ', first_and_last_name, ' from ' || company, ' via phone: ' || phone, ' via email: ' || email, '. ', 'Lead is from ' || lead_source, '. Rating: ' || rating, '.');
          insert into todo(task,completed) VALUES (task,0);
        END;
        $BODY$;

        CREATE OR REPLACE FUNCTION create_lead(
          OUT first_name text,
          OUT last_name text,
          OUT company text,
          OUT lead_source text)
          RETURNS SETOF record
          AS
          $$
            SELECT first_name, last_name, company, lead_source
            FROM contact;
          $$
           LANGUAGE 'sql' VOLATILE;
      EOF

      echo "***** sampledb created"
    postStart.sh: |
      #!/bin/bash
      /var/lib/pgsql/sampledb/add-sample-db.sh &>  /proc/1/fd/1

- apiVersion: v1
  kind: ConfigMap
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db
    name: syndesis-db-conf
  data:
    syndesis-postgresql.conf: |
      log_autovacuum_min_duration = 0
      log_line_prefix = '%t %a %i %e %c '
      logging_collector = off
      autovacuum_max_workers = 6
      autovacuum_naptime = 15s
      autovacuum_vacuum_threshold = 25
      autovacuum_vacuum_scale_factor = 0.1
      autovacuum_analyze_threshold = 10
      autovacuum_analyze_scale_factor = 0.05
      autovacuum_vacuum_cost_delay = 10ms
      autovacuum_vacuum_cost_limit = 2000

- apiVersion: v1
  kind: Service
  metadata:
    name: syndesis-db
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db
  spec:
    ports:
    - name: postgresql
      nodePort: 0
      port: 5432
      protocol: TCP
      targetPort: 5432
    - name: metrics
      nodePort: 0
      port: 9187
      protocol: TCP
      targetPort: 9187
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-db
    sessionAffinity: None
    type: ClusterIP
  status:
    loadBalancer: {}
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: syndesis-db
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: ${POSTGRESQL_VOLUME_CAPACITY}

- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    name: syndesis-db
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-db
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-db
    strategy:
      type: Recreate
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/component: syndesis-db
      spec:
        serviceAccountName: syndesis-default
        containers:
        - capabilities: {}
          env:
          - name: POSTGRESQL_USER
            value: ${POSTGRESQL_USER}
          - name: POSTGRESQL_PASSWORD
            value: ${POSTGRESQL_PASSWORD}
          - name: POSTGRESQL_DATABASE
            value: ${POSTGRESQL_DATABASE}
          - name: POSTGRESQL_SAMPLEDB_PASSWORD
            value: ${POSTGRESQL_SAMPLEDB_PASSWORD}
          image: ' '
          imagePullPolicy: IfNotPresent
          lifecycle:
            postStart:
              exec:
                command:
                - /bin/sh
                - -c
                - /var/lib/pgsql/sampledb/postStart.sh
          livenessProbe:
            initialDelaySeconds: 60
            tcpSocket:
              port: 5432
          name: postgresql
          ports:
          - containerPort: 5432
            protocol: TCP
          readinessProbe:
            exec:
              command:
              - /bin/sh
              - -i
              - -c
              - psql -h 127.0.0.1 -U $POSTGRESQL_USER -q -d $POSTGRESQL_DATABASE -c 'SELECT 1'
            initialDelaySeconds: 5
          # DB QoS class is "Guaranteed" (requests == limits)
          # Note: On OSO there is no Guaranteed class, its always burstable
          resources:
            limits:
              memory: ${POSTGRESQL_MEMORY_LIMIT}
            requests:
              memory: ${POSTGRESQL_MEMORY_LIMIT}
          volumeMounts:
          - mountPath: /var/lib/pgsql/data
            name: syndesis-db-data
          - mountPath: /var/lib/pgsql/sampledb
            name: syndesis-sampledb-config
          - mountPath: /opt/app-root/src/postgresql-cfg/
            name: syndesis-db-conf
        - capabilities: {}
          env:
          - name: DATA_SOURCE_NAME
            value: postgresql://${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}@localhost:5432/syndesis?sslmode=disable
          - name: PG_EXPORTER_EXTEND_QUERY_PATH
            value: /etc/postgres/exporter/queries.yaml
          image: ' '

          imagePullPolicy: IfNotPresent
          name: syndesis-db-metrics
          livenessProbe:
            failureThreshold: 5
            tcpSocket:
              port: 9187
            initialDelaySeconds: 60
          readinessProbe:
            failureThreshold: 5
            tcpSocket:
              port: 9187
            initialDelaySeconds: 30
          ports:
          - containerPort: 9187
            name: prometheus
          resources:
            limits:
              memory: 256Mi
            requests:
              memory: 20Mi
          volumeMounts:
          - mountPath: /etc/postgres/exporter
            name: syndesis-db-metrics-config
        volumes:
        - name: syndesis-db-metrics-config
          configMap:
            name: syndesis-db-metrics-config
        - name: syndesis-db-data
          persistentVolumeClaim:
            claimName: syndesis-db
        - configMap:
            defaultMode: 511
            name: syndesis-sampledb-config
          name: syndesis-sampledb-config
        - configMap:
            name: syndesis-db-conf
          name: syndesis-db-conf
    triggers:
    - type: ConfigChange
    - imageChangeParams:
        automatic: true
        containerNames:
        - postgresql
        from:
          kind: ImageStreamTag
          name: postgresql:9.5
          namespace: ${POSTGRESQL_IMAGE_STREAM_NAMESPACE}
      type: ImageChange
    - imageChangeParams:
        automatic: true
        containerNames:
        - syndesis-db-metrics
        from:
          kind: ImageStreamTag
          name: postgres_exporter:v0.4.7
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-meta
    name: syndesis-meta
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
      name: http
    - port: 8181
      protocol: TCP
      targetPort: 8181
      name: prometheus
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-meta
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: syndesis-meta
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-meta
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: ${META_VOLUME_CAPACITY}
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-meta
    name: syndesis-meta
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-meta
    strategy:
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
      type: Recreate
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/type: infrastructure
          syndesis.io/component: syndesis-meta
      spec:
        serviceAccountName: syndesis-server
        containers:
        - name: syndesis-meta
          env:
          - name: JAVA_APP_DIR
            value: /deployments
          - name: LOADER_HOME
            value: /deployments/ext
          - name: JAVA_OPTIONS
            value: "-Djava.net.preferIPv4Stack=true -Duser.home=/tmp"
          image: ' '

          imagePullPolicy: IfNotPresent
          readinessProbe:
            httpGet:
              path: /health
              port: 8181
              scheme: HTTP
            initialDelaySeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8181
              scheme: HTTP
            initialDelaySeconds: 300
            periodSeconds: 20
            failureThreshold: 5
          ports:
          - containerPort: 8080
            name: http
            protocol: TCP
          - containerPort: 9779
            name: prometheus
            protocol: TCP
          - containerPort: 8778
            name: jolokia
            protocol: TCP
          resources:
            limits:
              memory: ${META_MEMORY_LIMIT}
            requests:
              memory: 280Mi
          # spring-boot automatically picks up application.yml from ./config
          workingDir: /deployments
          volumeMounts:
          - name: config-volume
            mountPath: /deployments/config
          - name: ext-volume
            mountPath: /deployments/ext
        volumes:
        - name: ext-volume
          persistentVolumeClaim:
            claimName: syndesis-meta
        - name: config-volume
          configMap:
            name: syndesis-meta-config
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - syndesis-meta
        from:
          kind: ImageStreamTag
          name: syndesis-meta:latest
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange

    - type: ConfigChange

- apiVersion: v1
  kind: ConfigMap
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-meta
    name: syndesis-meta-config
  data:
    application.yml: |-
      server:
        port: 8080
      # We only want the status, not the full data. Hence security on, sensitive off.
      # See https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-monitoring.html
      # For details
      management:
        port: 8181
        security:
          enabled: true
      endpoints:
        health:
          sensitive: false
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-oauthproxy
    annotations:
      service.alpha.openshift.io/serving-cert-secret-name: syndesis-oauthproxy-tls
    name: syndesis-oauthproxy
  spec:
    ports:
    - port: 8443
      protocol: TCP
      targetPort: 8443
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-oauthproxy
- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
    annotations:
      console.alpha.openshift.io/overview-app-route: "true"
    name: syndesis
  spec:
    host: ${ROUTE_HOSTNAME}
    port:
      targetPort: 8443
    tls:
      insecureEdgeTerminationPolicy: Redirect
      termination: reencrypt
    to:
      kind: Service
      name: syndesis-oauthproxy
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-oauthproxy
    name: syndesis-oauthproxy
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-oauthproxy
    strategy:
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
      type: Recreate
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/type: infrastructure
          syndesis.io/component: syndesis-oauthproxy
      spec:
        containers:
        - name: syndesis-oauthproxy
          image: ' '
          args:
            - --provider=openshift
            - --client-id=system:serviceaccount:${OPENSHIFT_PROJECT}:syndesis-oauth-client
            - --client-secret=${OPENSHIFT_OAUTH_CLIENT_SECRET}
            - --upstream=http://syndesis-server/api/
            - --upstream=http://syndesis-server/mapper/
            - --upstream=http://syndesis-ui/
            - --tls-cert=/etc/tls/private/tls.crt
            - --tls-key=/etc/tls/private/tls.key
            - --cookie-secret=$(OAUTH_COOKIE_SECRET)
            - --pass-access-token
            - --skip-provider-button
            - --skip-auth-regex=/logout
            - --skip-auth-regex=/[^/]+\.(png|jpg|eot|svg|ttf|woff|woff2)
            - --skip-auth-regex=/api/v1/swagger.*
            - --skip-auth-regex=/api/v1/index.html
            - --skip-auth-regex=/api/v1/credentials/callback
            - --skip-auth-regex=/api/v1/version
            - --skip-auth-preflight
            - --openshift-ca=/etc/pki/tls/certs/ca-bundle.crt
            - --openshift-ca=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            - --openshift-sar={"namespace":"${SAR_PROJECT}","resource":"pods","verb":"get"}
            # Disabled for now: --pass-user-bearer-token as this requires extra permission which only
            # can be given by a cluster-admin
          env:
          - name: OAUTH_COOKIE_SECRET
            valueFrom:
              secretKeyRef:
                name: syndesis-oauth-proxy-cookie-secret
                key: oauthCookieSecret
          ports:
          - containerPort: 8443
            name: public
            protocol: TCP
          readinessProbe:
            httpGet:
              port: 8443
              path: /oauth/healthz
              scheme: HTTPS
            initialDelaySeconds: 15
            timeoutSeconds: 10
          livenessProbe:
            httpGet:
              port: 8443
              path: /oauth/healthz
              scheme: HTTPS
            initialDelaySeconds: 15
            timeoutSeconds: 10
          volumeMounts:
          - mountPath: /etc/tls/private
            name: syndesis-oauthproxy-tls
          resources:
            limits:
              memory: 200Mi
            requests:
              memory: 20Mi
        serviceAccountName: syndesis-oauth-client
        volumes:
        - name: syndesis-oauthproxy-tls
          secret:
            secretName: syndesis-oauthproxy-tls
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - syndesis-oauthproxy
        from:
          kind: ImageStreamTag
          name: oauth-proxy:v4.0.0
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange

    - type: ConfigChange
- apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: syndesis-server
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
- apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: syndesis-integration
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
    name: syndesis-server
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
      name: http
    - port: 8181
      protocol: TCP
      targetPort: 8181
      name: prometheus
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-server
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
    name: syndesis-server
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-server
    strategy:
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
      type: Recreate
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/type: infrastructure
          syndesis.io/component: syndesis-server
      spec:
        serviceAccountName: syndesis-server
        containers:
        - name: syndesis-server
          env:
          - name: JAVA_APP_DIR
            value: /deployments
          - name: JAVA_OPTIONS
            value: "-Djava.net.preferIPv4Stack=true -Duser.home=/tmp"
          - name: NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: ENDPOINTS_TEST_SUPPORT_ENABLED
            value: ${TEST_SUPPORT_ENABLED}
          - name: CONTROLLERS_INTEGRATION_ENABLED
            value: ${CONTROLLERS_INTEGRATION_ENABLED}
          - name: POSTGRESQL_SAMPLEDB_PASSWORD
            value: ${POSTGRESQL_SAMPLEDB_PASSWORD}
          - name: CLIENT_STATE_AUTHENTICATION_ALGORITHM
            value: "HmacSHA1"
          - name: CLIENT_STATE_AUTHENTICATION_KEY
            valueFrom:
              secretKeyRef:
                name: syndesis-server-secret
                key: clientStateAuthenticationKey
          - name: CLIENT_STATE_ENCRYPTION_ALGORITHM
            value: "AES/CBC/PKCS5Padding"
          - name: CLIENT_STATE_ENCRYPTION_KEY
            valueFrom:
              secretKeyRef:
                name: syndesis-server-secret
                key: clientStateEncryptionKey
          - name: CLIENT_STATE_TID
            value: "1"
          - name: INTEGRATION_STATE_CHECK_INTERVAL
            value: ${INTEGRATION_STATE_CHECK_INTERVAL}
          - name: CONTROLLERS_EXPOSE_VIA3SCALE
            value: ${CONTROLLERS_EXPOSE_VIA3SCALE}
          image: ' '

          imagePullPolicy: IfNotPresent
          livenessProbe:
            httpGet:
              port: 8080
              path: /api/v1/version
              httpHeaders:
              - name: Accept
                value: 'text/plain'
            initialDelaySeconds: 300
            periodSeconds: 20
            failureThreshold: 5
          readinessProbe:
            httpGet:
              path: "/health"
              port: 8181
            initialDelaySeconds: 10
          ports:
          - containerPort: 8080
            name: http
          - containerPort: 9779
            name: prometheus
          - containerPort: 8778
            name: jolokia
          workingDir: /deployments
          volumeMounts:
          - name: config-volume
            mountPath: /deployments/config
          # Set QoS class to "Guaranteed" (limits == requests)
          # This doesn't work on OSO as there is a fixed ratio
          # from limit to resource (80% currently). 'requests' is ignored there
          resources:
            limits:
              memory: ${SERVER_MEMORY_LIMIT}
              cpu: 750m
            requests:
              memory: 256Mi
              cpu: 450m
        volumes:
        - name: config-volume
          configMap:
            name: syndesis-server-config
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - syndesis-server
        from:
          kind: ImageStreamTag
          name: syndesis-server:latest
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange

    - type: ConfigChange

# workaround camel-k metrics
- apiVersion: v1
  kind: ConfigMap
  metadata:
    annotations:
      io.syndesis/upgrade-mode: keep
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
    name: syndesis-prometheus-agent-config
  data:
    prometheus-config.yml: |-
      #
      # Copyright (C) 2016 Red Hat, Inc.
      #
      # Licensed under the Apache License, Version 2.0 (the "License");
      # you may not use this file except in compliance with the License.
      # You may obtain a copy of the License at
      #
      #     http://www.apache.org/licenses/LICENSE-2.0
      #
      # Unless required by applicable law or agreed to in writing, software
      # distributed under the License is distributed on an "AS IS" BASIS,
      # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      # See the License for the specific language governing permissions and
      # limitations under the License.
      #
      
      startDelaySecs: 5
      ssl: false
      blacklistObjectNames: ["java.lang:*"]
      rules:
      # Syndesis Camel Context
        - pattern: 'io.syndesis.camel<context=([^,]+), type=context, name=([^,]+)><>LastExchangeCompletedTimestamp'
          name: io.syndesis.camel.LastExchangeCompletedTimestamp
          help: Last Exchange Completed Timestamp
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'io.syndesis.camel<context=([^,]+), type=context, name=([^,]+)><>LastExchangeFailureTimestamp'
          name: io.syndesis.camel.LastExchangeFailureTimestamp
          help: Last Exchange Failure Timestamp
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'io.syndesis.camel<context=([^,]+), type=context, name=([^,]+)><>StartTimestamp'
          name: io.syndesis.camel.StartTimestamp
          help: Start Timestamp
          type: COUNTER
          labels:
            context: $1
            type: context
      # Context level
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>ExchangesCompleted'
          name: org.apache.camel.ExchangesCompleted
          help: Exchanges Completed
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>ExchangesFailed'
          name: org.apache.camel.ExchangesFailed
          help: Exchanges Failed
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>ExchangesInflight'
          name: org.apache.camel.ExchangesInflight
          help: Exchanges Inflight
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>ExchangesTotal'
          name: org.apache.camel.ExchangesTotal
          help: Exchanges Total
          type: COUNTER
          labels:
            context: $1
            type: context
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>FailuresHandled'
          name: org.apache.camel.FailuresHandled
          help: Failures Handled
          labels:
              context: $1
              type: context
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>ExternalRedeliveries'
          name: org.apache.camel.ExternalRedeliveries
          help: External Redeliveries
          labels:
              context: $1
              type: context
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>MaxProcessingTime'
          name: org.apache.camel.MaxProcessingTime
          help: Maximum Processing Time
          labels:
              context: $1
              type: context
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>MeanProcessingTime'
          name: org.apache.camel.MeanProcessingTime
          help: Mean Processing Time
          labels:
              context: $1
              type: context
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>MinProcessingTime'
          name: org.apache.camel.MinProcessingTime
          help: Minimum Processing Time
          labels:
              context: $1
              type: context
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>Redeliveries'
          name: org.apache.camel.Redeliveries
          help: Redeliveries
          labels:
              context: $1
              type: context
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=context, name=([^,]+)><>TotalProcessingTime'
          name: org.apache.camel.TotalProcessingTime
          help: Total Processing Time
          labels:
              context: $1
              type: context
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=consumers, name=([^,]+)><>InflightExchanges'
          name: org.apache.camel.InflightExchanges
          help: Inflight Exchanges
          labels:
              context: $1
              type: context
          type: GAUGE
      
      
      # Route level
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>ExchangesCompleted'
          name: org.apache.camel.ExchangesCompleted
          help: Exchanges Completed
          type: COUNTER
          labels:
            context: $1
            route: $2
            type: routes
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>ExchangesFailed'
          name: org.apache.camel.ExchangesFailed
          help: Exchanges Failed
          type: COUNTER
          labels:
            context: $1
            route: $2
            type: routes
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>ExchangesInflight'
          name: org.apache.camel.ExchangesInflight
          help: Exchanges Inflight
          type: COUNTER
          labels:
            context: $1
            route: $2
            type: routes
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>ExchangesTotal'
          name: org.apache.camel.ExchangesTotal
          help: Exchanges Total
          type: COUNTER
          labels:
            context: $1
            route: $2
            type: routes
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>FailuresHandled'
          name: org.apache.camel.FailuresHandled
          help: Failures Handled
          labels:
              context: $1
              route: $2
              type: routes
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>ExternalRedeliveries'
          name: org.apache.camel.ExternalRedeliveries
          help: External Redeliveries
          labels:
              context: $1
              route: $2
              type: routes
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>MaxProcessingTime'
          name: org.apache.camel.MaxProcessingTime
          help: Maximum Processing Time
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>MeanProcessingTime'
          name: org.apache.camel.MeanProcessingTime
          help: Mean Processing Time
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>MinProcessingTime'
          name: org.apache.camel.MinProcessingTime
          help: Minimum Processing Time
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>Redeliveries'
          name: org.apache.camel.Redeliveries
          help: Redeliveries
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>TotalProcessingTime'
          name: org.apache.camel.TotalProcessingTime
          help: Total Processing Time
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=routes, name=([^,]+)><>InflightExchanges'
          name: org.apache.camel.InflightExchanges
          help: Inflight Exchanges
          labels:
              context: $1
              route: $2
              type: routes
          type: GAUGE
      
      # Processor level
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>ExchangesCompleted'
          name: org.apache.camel.ExchangesCompleted
          help: Exchanges Completed
          type: COUNTER
          labels:
            context: $1
            processor: $2
            type: processors
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>ExchangesFailed'
          name: org.apache.camel.ExchangesFailed
          help: Exchanges Failed
          type: COUNTER
          labels:
            context: $1
            processor: $2
            type: processors
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>ExchangesInflight'
          name: org.apache.camel.ExchangesInflight
          help: Exchanges Inflight
          type: COUNTER
          labels:
            context: $1
            processor: $2
            type: processors
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>ExchangesTotal'
          name: org.apache.camel.ExchangesTotal
          help: Exchanges Total
          type: COUNTER
          labels:
            context: $1
            processor: $2
            type: processors
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>FailuresHandled'
          name: org.apache.camel.FailuresHandled
          help: Failures Handled
          labels:
              context: $1
              processor: $2
              type: processors
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>ExternalRedeliveries'
          name: org.apache.camel.ExternalRedeliveries
          help: External Redeliveries
          labels:
              context: $1
              processor: $2
              type: processors
          type: COUNTER
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>MaxProcessingTime'
          name: org.apache.camel.MaxProcessingTime
          help: Maximum Processing Time
          labels:
              context: $1
              processor: $2
              type: processors
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>MeanProcessingTime'
          name: org.apache.camel.MeanProcessingTime
          help: Mean Processing Time
          labels:
              context: $1
              processor: $2
              type: processors
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>MinProcessingTime'
          name: org.apache.camel.MinProcessingTime
          help: Minimum Processing Time
          labels:
              context: $1
              processor: $2
              type: processors
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>Redeliveries'
          name: org.apache.camel.Redeliveries
          help: Redeliveries
          labels:
              context: $1
              processor: $2
              type: processors
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>TotalProcessingTime'
          name: org.apache.camel.TotalProcessingTime
          help: Total Processing Time
          labels:
              context: $1
              processor: $2
              type: processors
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=processors, name=([^,]+)><>InflightExchanges'
          name: org.apache.camel.InflightExchanges
          help: Inflight Exchanges
          labels:
              context: $1
              processor: $2
              type: processors
          type: COUNTER
      
      # Consumers
        - pattern: 'org.apache.camel<context=([^,]+), type=consumers, name=([^,]+)><>InflightExchanges'
          name: org.apache.camel.InflightExchanges
          help: Inflight Exchanges
          labels:
              context: $1
              consumer: $2
              type: consumers
          type: GAUGE
      
      # Services
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>MaxDuration'
          name: org.apache.camel.MaxDuration
          help: Maximum Duration
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>MeanDuration'
          name: org.apache.camel.MeanDuration
          help: Mean Duration
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>MinDuration'
          name: org.apache.camel.MinDuration
          help: Minimum Duration
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>TotalDuration'
          name: org.apache.camel.TotalDuration
          help: Total Duration
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>ThreadsBlocked'
          name: org.apache.camel.ThreadsBlocked
          help: Threads Blocked
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.camel<context=([^,]+), type=services, name=([^,]+)><>ThreadsInterrupted'
          name: org.apache.camel.ThreadsInterrupted
          help: Threads Interrupted
          labels:
              context: $1
              service: $2
              type: services
          type: GAUGE
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>NumLogicalRuntimeFaults'
          name: org.apache.cxf.NumLogicalRuntimeFaults
          help: Number of logical runtime faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>NumLogicalRuntimeFaults'
          name: org.apache.cxf.NumLogicalRuntimeFaults
          help: Number of logical runtime faults
          type: GAUGE
          labels:
             bus.id: $1
             type: $2
             service: $3
             port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>AvgResponseTime'
          name: org.apache.cxf.AvgResponseTime
          help: Average Response Time
          type: GAUGE
          labels:
             bus.id: $1
             type: $2
             service: $3
             port: $4
             operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>AvgResponseTime'
          name: org.apache.cxf.AvgResponseTime
          help: Average Response Time
          type: GAUGE
          labels:
                bus.id: $1
                type: $2
                service: $3
                port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>NumInvocations'
          name: org.apache.cxf.NumInvocations
          help: Number of invocations
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>NumInvocations'
          name: org.apache.cxf.NumInvocations
          help: Number of invocations
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>MaxResponseTime'
          name: org.apache.cxf.MaxResponseTime
          help: Maximum Response Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>MaxResponseTime'
          name: org.apache.cxf.MaxResponseTime
          help: Maximum Response Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>MinResponseTime'
          name: org.apache.cxf.MinResponseTime
          help: Minimum Response Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>MinResponseTime'
          name: org.apache.cxf.MinResponseTime
          help: Minimum Response Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>TotalHandlingTime'
          name: org.apache.cxf.TotalHandlingTime
          help: Total Handling Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>TotalHandlingTime'
          name: org.apache.cxf.TotalHandlingTime
          help: Total Handling Time
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>NumRuntimeFaults'
          name: org.apache.cxf.NumRuntimeFaults
          help: Number of runtime faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>NumRuntimeFaults'
          name: org.apache.cxf.NumRuntimeFaults
          help: Number of runtime faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>NumUnCheckedApplicationFaults'
          name: org.apache.cxf.NumUnCheckedApplicationFaults
          help: Number of unchecked application faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>NumUnCheckedApplicationFaults'
          name: org.apache.cxf.NumUnCheckedApplicationFaults
          help: Number of unchecked application faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+), operation=([^,]+)><>NumCheckedApplicationFaults'
          name: org.apache.cxf.NumCheckedApplicationFaults
          help: Number of checked application faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
              operation: $5
        - pattern: 'org.apache.cxf<bus.id=([^,]+), type=([^,]+), service=([^,]+), port=([^,]+)><>NumCheckedApplicationFaults'
          name: org.apache.cxf.NumCheckedApplicationFaults
          help: Number of checked application faults
          type: GAUGE
          labels:
              bus.id: $1
              type: $2
              service: $3
              port: $4
      

- apiVersion: v1
  kind: ConfigMap
  metadata:
    annotations:
      io.syndesis/upgrade-mode: keep
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
    name: syndesis-server-config
  data:
    application.yml: |-
      deployment:
        load-demo-data: ${DEMO_DATA_ENABLED}
      cors:
        allowedOrigins: https://${ROUTE_HOSTNAME}

      cache:
        cluster:
          name: SyndesisCluster
        max:
          entries: 100
      encrypt:
        key: ${SYNDESIS_ENCRYPT_KEY}
      spring:
        zipkin:
          enabled: false
        datasource:
          url: jdbc:postgresql://syndesis-db:5432/syndesis?sslmode=disable
          username: ${POSTGRESQL_USER}
          password: ${POSTGRESQL_PASSWORD}
          driver-class-name: org.postgresql.Driver
      security:
        basic:
          enabled: false
      management:
        port: 8181
        security:
          enabled: true
      endpoints:
        health:
          sensitive: false
        jsondb:
          enabled: true
      monitoring:
        kind: default
      features:
        monitoring:
          enabled: true
        public-api:
          enabled: true
      openshift:
        apiBaseUrl: ${OPENSHIFT_MASTER}/oapi/v1
        namespace: ${NAMESPACE}
        imageStreamNamespace: ${IMAGE_STREAM_NAMESPACE}
        builderImageStreamTag: syndesis-s2i:latest
        deploymentMemoryRequestMi: 200
        deploymentMemoryLimitMi: 512
        mavenOptions: "-XX:+UseG1GC -XX:+UseStringDeduplication -Xmx310m"
      dao:
        kind: jsondb
      controllers:
        maxIntegrationsPerUser: ${MAX_INTEGRATIONS_PER_USER}
        maxDeploymentsPerUser: ${MAX_INTEGRATIONS_PER_USER}
        integrationStateCheckInterval: ${INTEGRATION_STATE_CHECK_INTERVAL}
# START:CAMEL-K
- kind: Role
  apiVersion: rbac.authorization.k8s.io/v1beta1
  metadata:
    name: camel-k
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
  rules:
  - apiGroups:
    - camel.apache.org
    resources:
    - "*"
    verbs: [ get, list, create, update, delete, deletecollection, watch]
- kind: RoleBinding
  apiVersion: rbac.authorization.k8s.io/v1beta1
  metadata:
    name: camel-k
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-server
  subjects:
  - kind: ServiceAccount
    name: syndesis-server
  roleRef:
    kind: Role
    name: camel-k
    apiGroup: rbac.authorization.k8s.io
# END:CAMEL-K
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: todo
      syndesis.io/component: todo
    name: todo
  spec:
    ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080
    selector:
      app: syndesis
      syndesis.io/app: todo
      syndesis.io/component: todo

- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: todo
      syndesis.io/component: todo
    name: todo
  spec:
    host: todo-${ROUTE_HOSTNAME}
    path: /
    port:
      targetPort: 8080
    tls:
      insecureEdgeTerminationPolicy: Allow
      termination: edge
    to:
      kind: Service
      name: todo
      weight: 100

- apiVersion: image.openshift.io/v1
  kind: ImageStream
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: todo
    name: todo
  spec:
    lookupPolicy:
      local: false
  status:
    tags:
      - items:
        tag: latest

- apiVersion: build.openshift.io/v1
  kind: BuildConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: todo
    name: todo
  spec:
    postCommit: {}
    resources: {}
    runPolicy: Serial
    source:
      git:
        uri: 'https://github.com/syndesisio/todo-example.git'
      type: Git
    output:
      to:
        kind: ImageStreamTag
        name: 'todo:latest'
    strategy:
      sourceStrategy:
        from:
          kind: ImageStreamTag
          name: 'php:7.0'
          namespace: openshift
      type: Source
    triggers:
      - type: ConfigChange
      - imageChange:
        type: ImageChange

- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: todo
    name: todo
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: todo
      syndesis.io/component: todo
    strategy:
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
      type: Recreate
    template:
      metadata:
        annotations:
          openshift.io/container.todo.image.entrypoint: '["container-entrypoint","/bin/sh","-c","$STI_SCRIPTS_PATH/usage"]'
        creationTimestamp: null
        labels:
          app: syndesis
          syndesis.io/app: todo
          syndesis.io/component: todo
      spec:
        containers:
          - env:
              - name: TODO_DB_SERVER
                value: syndesis-db
              - name: TODO_DB_NAME
                value: sampledb
              - name: TODO_DB_USER
                value: sampledb
              - name: TODO_DB_PASS
                value: ${POSTGRESQL_SAMPLEDB_PASSWORD}
            imagePullPolicy: Always
            name: todo
            image: ' '
            resources:
              limits:
                memory: 256Mi
              requests:
                memory: 256Mi
            ports:
              - containerPort: 8080
                name: http
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
    test: false
    triggers:
      - type: ConfigChange
      - imageChangeParams:
          automatic: true
          containerNames:
            - todo
          from:
            kind: ImageStreamTag
            name: todo:latest
        type: ImageChange
- apiVersion: authorization.openshift.io/v1
  kind: RoleBinding
  metadata:
    name: syndesis:editors
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  roleRef:
    name: edit
  subjects:
  - kind: ServiceAccount
    name: syndesis-server
- apiVersion: authorization.openshift.io/v1
  kind: RoleBinding
  metadata:
    name: syndesis:viewers
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  roleRef:
    name: view
  subjects:
  - kind: ServiceAccount
    name: syndesis-prometheus
- apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: syndesis-prometheus
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus

- apiVersion: v1
  kind: ConfigMap
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus
    name: syndesis-prometheus-config
  data:
    prometheus.yml: |-
      global:
        scrape_interval:     5s
        evaluation_interval: 5s

      scrape_configs:
        - job_name: prometheus
          static_configs:
            - targets:
              - localhost:9090

          metric_relabel_configs:
          - source_labels: [__name__]
            regex: go_(.+)
            action: drop
          - source_labels: [__name__]
            regex: http_(.+)
            action: drop
          - source_labels: [__name__]
            regex: net_(.+)
            action: drop
          - source_labels: [__name__]
            regex: process_(.+)
            action: drop
          - source_labels: [__name__]
            regex: prometheus_(.+)
            action: drop
          - source_labels: [__name__]
            regex: tsdb_(.+)
            action: drop

        - job_name: integration-pods

          kubernetes_sd_configs:
          - role: pod
            namespaces:
              names:
                - ${OPENSHIFT_PROJECT}

          relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_label_syndesis_io_type]
            action: keep
            regex: integration
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - action: labelmap
            regex: __meta_kubernetes_pod_annotation_(syndesis.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
          metric_relabel_configs:
          - source_labels: [__name__]
            regex: jmx_(.+)
            action: drop
          - source_labels: [__name__]
            regex: jvm_(.+)
            action: drop
          - source_labels: [__name__]
            regex: process_(.+)
            action: drop
          - source_labels: [type, __name__]
            separator: ':'
            regex: context:(org_apache_camel_ExchangesTotal|org_apache_camel_ExchangesFailed|io_syndesis_camel_StartTimestamp|io_syndesis_camel_LastExchangeCompletedTimestamp|io_syndesis_camel_LastExchangeFailureTimestamp)
            action: keep

- apiVersion: v1
  kind: Service
  metadata:
    name: syndesis-prometheus
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus
  spec:
    ports:
    - name: prometheus
      port: 80
      protocol: TCP
      targetPort: 9090
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-prometheus
  status:
    loadBalancer: {}
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: syndesis-prometheus
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: ${PROMETHEUS_VOLUME_CAPACITY}
- apiVersion: apps.openshift.io/v1
  kind: DeploymentConfig
  metadata:
    name: syndesis-prometheus
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
      syndesis.io/component: syndesis-prometheus
  spec:
    replicas: 1
    selector:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/component: syndesis-prometheus
    strategy:
      type: Recreate
      resources:
        limits:
          memory: "256Mi"
        requests:
          memory: "20Mi"
    template:
      metadata:
        labels:
          app: syndesis
          syndesis.io/app: syndesis
          syndesis.io/type: infrastructure
          syndesis.io/component: syndesis-prometheus
      spec:
        serviceAccountName: syndesis-prometheus
        containers:
        - name: prometheus
          image: ' '

          imagePullPolicy: IfNotPresent
          args:
            - '--config.file=/etc/prometheus/prometheus.yml'
            - '--storage.tsdb.retention=30d'
          livenessProbe:
            httpGet:
              port: 9090
            initialDelaySeconds: 60
          ports:
          - containerPort: 9090
          readinessProbe:
            httpGet:
              port: 9090
            initialDelaySeconds: 30
          # DB QoS class is "Guaranteed" (requests == limits)
          # Note: On OSO there is no Guaranteed class, its always burstable
          resources:
            limits:
              memory: ${PROMETHEUS_MEMORY_LIMIT}
            requests:
              memory: ${PROMETHEUS_MEMORY_LIMIT}
          volumeMounts:
          - name: syndesis-prometheus-data
            mountPath: /prometheus
          - name: syndesis-prometheus-config
            mountPath: /etc/prometheus
        volumes:
        - name: syndesis-prometheus-data
          persistentVolumeClaim:
            claimName: syndesis-prometheus
        - name: syndesis-prometheus-config
          configMap:
            name: syndesis-prometheus-config
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - prometheus
        from:
          kind: ImageStreamTag
          name: prometheus:v2.1.0
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: ImageChange

    - type: ConfigChange
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: syndesis-upgrade
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: ${UPGRADE_VOLUME_CAPACITY}
- apiVersion: template.openshift.io/v1
  kind: Template
  metadata:
    labels:
      app: syndesis
      syndesis.io/app: syndesis
      syndesis.io/type: infrastructure
    name: syndesis-upgrade
    annotations:
      openshift.io/display-name: "Syndesis Upgrade"
      description: |-
        This is the upgrade application for Syndesis.
      openshift.io/long-description: |-
        When this template is applied then an upgrade to a new Syndesis version is performed.
        Only the infrastructure components are updated, no running integration is touched.
        Before doing the upgrade a backup is performed and restored in case of a rollback.
      tags: "syndesis,upgrade"
      iconClass: icon-rh-integration
      openshift.io/provider-display-name: "Red Hat, Inc."
      openshift.io/documentation-url: "https://syndesis.io"
      openshift.io/support-url: "https://access.redhat.com"
  parameters:
  - name: UPGRADE_REGISTRY
    description: 'Registry from where to pick up the upgrade pod'
    value: docker.io
    required: true
  message: |-
    Syndesis upgrade process started
  objects:
  - apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: syndesis-upgrade
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: ${UPGRADE_VOLUME_CAPACITY}
  - apiVersion: v1
    kind: Pod
    metadata:
      name: syndesis-upgrade-latest
    spec:
      serviceAccountName: syndesis-operator
      containers:
      - name: upgrade
        image: ${UPGRADE_REGISTRY}/syndesis/syndesis-upgrade:latest
        env:
          - name: SYNDESIS_UPGRADE_PROJECT
            valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
        imagePullPolicy: IfNotPresent
        args:
          - "--backup"
          - "/opt/backup"
        volumeMounts:
        - mountPath: /opt/backup
          name: backup-dir
      volumes:
      - name: backup-dir
        persistentVolumeClaim:
          claimName: syndesis-upgrade
      restartPolicy: Never
