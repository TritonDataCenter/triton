/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2020 Joyent, Inc.
 */

@Library('jenkins-joylib@v1.0.4') _

pipeline {

    agent {
        label joyCommonLabels(image_ver: '19.4.0')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        parallelsAlwaysFailFast()
    }
    parameters {
        string(
            name: 'COMPONENTS',
            defaultValue: '',
            description:
                'A space separated list of the repositories to build. ' +
                'By default, all components are included, but if any are ' +
                'specified here, sdc-headnode is automatically added unless ' +
                'this is a SmartOS only build.'
            )
    }

    stages {
        stage('compare jenkinsfile') {
            when { branch 'weekly-build' }
            steps {
                /*
                * This checks that the Jenkinsfile in the checked-out workspace
                * matches the one we'd otherwise generate. Run this first to
                * prevent wasting time building incorrect components.
                */
                nodejs('sdcnode-v8-zone64') {
                    sh './tools/releng/weekly-build'
                }
            }
        }
        stage('triton/manta components') {
            when {
                allOf {
                    branch 'weekly-build'
                    triggeredBy cause: 'UserIdCause'
                }
            }
        /*
         * This builds all components required for the headnode in parallel.
         * We don't indent the enclosed stages to improve readability.
         */
            parallel {
        stage('platform build') {
            when {
                allOf {
                    branch 'weekly-build'
                    triggeredBy cause: 'UserIdCause'
                    expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*smartos-live.*" }
                }
            }
            steps {
                build(job:'joyent-org/smartos-live/master',
                    wait: true,
                    parameters: [
                        text(name: 'CONFIGURE_PROJECTS',
                            value:
                            "illumos-extra: master: origin\n" +
                            'illumos: master: origin\n' +
                            'local/kbmd: master: origin\n' +
                            'local/kvm-cmd: master: origin\n' +
                            'local/kvm: master: origin\n' +
                            'local/mdata-client: master: origin\n' +
                            'local/ur-agent: master: origin'),
                        booleanParam(name: 'BUILD_STRAP_CACHE', value: false),
                        choiceParam(name: 'PLATFORM_BUILD_FLAVOR', value: 'triton-and-smartos')
                    ])
            }
        }
        stage('binder') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*binder.*" }
            }
            steps {
                build(job: 'joyent-org/binder/master', wait: true)
            }
        }
        stage('electric-moray') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*electric-moray.*" }
            }
            steps {
                build(job: 'joyent-org/electric-moray/master', wait: true)
            }
        }
        stage('ipxe') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*ipxe.*" }
            }
            steps {
                build(job: 'joyent-org/ipxe/master', wait: true)
            }
        }
        stage('mahi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*mahi.*" }
            }
            steps {
                build(job: 'joyent-org/mahi/master', wait: true)
            }
        }
        stage('manta-buckets-api') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-buckets-api.*" }
            }
            steps {
                build(job: 'joyent-org/manta-buckets-api/master', wait: true)
            }
        }
        stage('manta-buckets-mdapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-buckets-mdapi.*" }
            }
            steps {
                build(job: 'joyent-org/manta-buckets-mdapi/master', wait: true)
            }
        }
        stage('manta-buckets-mdplacement') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-buckets-mdplacement.*" }
            }
            steps {
                build(job: 'joyent-org/manta-buckets-mdplacement/master', wait: true)
            }
        }
        stage('manta-garbage-collector') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-garbage-collector.*" }
            }
            steps {
                build(job: 'joyent-org/manta-garbage-collector/master', wait: true)
            }
        }
        stage('manta-mackerel') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-mackerel.*" }
            }
            steps {
                build(job: 'joyent-org/manta-mackerel/master', wait: true)
            }
        }
        stage('manta-madtom') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-madtom.*" }
            }
            steps {
                build(job: 'joyent-org/manta-madtom/master', wait: true)
            }
        }
        stage('manta-mako') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-mako.*" }
            }
            steps {
                build(job: 'joyent-org/manta-mako/master', wait: true)
            }
        }
        stage('manta-manatee') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-manatee.*" }
            }
            steps {
                build(job: 'joyent-org/manta-manatee/master', wait: true)
            }
        }
        stage('manta-minnow') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-minnow.*" }
            }
            steps {
                build(job: 'joyent-org/manta-minnow/master', wait: true)
            }
        }
        stage('manta-mola') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-mola.*" }
            }
            steps {
                build(job: 'joyent-org/manta-mola/master', wait: true)
            }
        }
        stage('manta-muskie') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-muskie.*" }
            }
            steps {
                build(job: 'joyent-org/manta-muskie/master', wait: true)
            }
        }
        stage('manta-rebalancer') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-rebalancer.*" }
            }
            steps {
                build(job: 'joyent-org/manta-rebalancer/master', wait: true)
            }
        }
        stage('manta-reshard') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-reshard.*" }
            }
            steps {
                build(job: 'joyent-org/manta-reshard/master', wait: true)
            }
        }
        stage('manta-storinfo') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*manta-storinfo.*" }
            }
            steps {
                build(job: 'joyent-org/manta-storinfo/master', wait: true)
            }
        }
        stage('moray') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*moray.*" }
            }
            steps {
                build(job: 'joyent-org/moray/master', wait: true)
            }
        }
        stage('muppet') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*muppet.*" }
            }
            steps {
                build(job: 'joyent-org/muppet/master', wait: true)
            }
        }
        stage('pgstatsmon') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*pgstatsmon.*" }
            }
            steps {
                build(job: 'joyent-org/pgstatsmon/master', wait: true)
            }
        }
        stage('registrar') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*registrar.*" }
            }
            steps {
                build(job: 'joyent-org/registrar/master', wait: true)
            }
        }
        stage('sdc-adminui') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-adminui.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-adminui/master', wait: true)
            }
        }
        stage('sdc-amonredis') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-amonredis.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-amonredis/master', wait: true)
            }
        }
        stage('sdc-assets') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-assets.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-assets/master', wait: true)
            }
        }
        stage('sdc-booter') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-booter.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-booter/master', wait: true)
            }
        }
        stage('sdc-cloudapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-cloudapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-cloudapi/master', wait: true)
            }
        }
        stage('sdc-cnapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-cnapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-cnapi/master', wait: true)
            }
        }
        stage('sdc-docker') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-docker.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-docker/master', wait: true)
            }
        }
        stage('sdc-dockerlogger') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-dockerlogger.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-dockerlogger/master', wait: true)
            }
        }
        stage('sdc-fwapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-fwapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-fwapi/master', wait: true)
            }
        }
        stage('sdc-imgapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-imgapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-imgapi/master', wait: true)
            }
        }
        stage('sdc-manatee') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-manatee.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-manatee/master', wait: true)
            }
        }
        stage('sdc-manta') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-manta.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-manta/master', wait: true)
            }
        }
        stage('sdc-napi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-napi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-napi/master', wait: true)
            }
        }
        stage('sdc-nat') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-nat.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-nat/master', wait: true)
            }
        }
        stage('sdc-nfsserver') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-nfsserver.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-nfsserver/master', wait: true)
            }
        }
        stage('sdc-papi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-papi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-papi/master', wait: true)
            }
        }
        stage('sdc-portolan') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-portolan.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-portolan/master', wait: true)
            }
        }
        stage('sdc-rabbitmq') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-rabbitmq.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-rabbitmq/master', wait: true)
            }
        }
        stage('sdc-sapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-sapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-sapi/master', wait: true)
            }
        }
        stage('sdc-sdc') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-sdc.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-sdc/master', wait: true)
            }
        }
        stage('sdc-system-tests') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-system-tests.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-system-tests/master', wait: true)
            }
        }
        stage('sdc-ufds') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-ufds.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-ufds/master', wait: true)
            }
        }
        stage('sdc-vmapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-vmapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-vmapi/master', wait: true)
            }
        }
        stage('sdc-volapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-volapi.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-volapi/master', wait: true)
            }
        }
        stage('sdc-workflow') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-workflow.*" }
            }
            steps {
                build(job: 'joyent-org/sdc-workflow/master', wait: true)
            }
        }
        stage('sdcadm') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdcadm.*" }
            }
            steps {
                build(job: 'joyent-org/sdcadm/master', wait: true)
            }
        }
        stage('triton-cmon') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-cmon.*" }
            }
            steps {
                build(job: 'joyent-org/triton-cmon/master', wait: true)
            }
        }
        stage('triton-cns') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-cns.*" }
            }
            steps {
                build(job: 'joyent-org/triton-cns/master', wait: true)
            }
        }
        stage('triton-grafana') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-grafana.*" }
            }
            steps {
                build(job: 'joyent-org/triton-grafana/master', wait: true)
            }
        }
        stage('triton-kbmapi') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-kbmapi.*" }
            }
            steps {
                build(job: 'joyent-org/triton-kbmapi/master', wait: true)
            }
        }
        stage('triton-logarchiver') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-logarchiver.*" }
            }
            steps {
                build(job: 'joyent-org/triton-logarchiver/master', wait: true)
            }
        }
        stage('triton-mockcloud') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-mockcloud.*" }
            }
            steps {
                build(job: 'joyent-org/triton-mockcloud/master', wait: true)
            }
        }
        stage('triton-prometheus') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-prometheus.*" }
            }
            steps {
                build(job: 'joyent-org/triton-prometheus/master', wait: true)
            }
        }
        stage('waferlock') {
            when {
                branch 'weekly-build'
                triggeredBy cause: 'UserIdCause'
                expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*waferlock.*" }
            }
            steps {
                build(job: 'joyent-org/waferlock/master', wait: true)
            }
        }
            }
        /* End triton/manta component parallel */
        }
        /*
         * Build all agents in parallel, then build the agents-installer
         * which bundles them into a shar archive.
         */
        stage('agents parallel') {
            when {
                allOf {
                    branch 'weekly-build'
                    triggeredBy cause: 'UserIdCause'
                }
            }
            parallel {
                stage('sdc-agents-core') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-agents-core.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-agents-core/master',
                            wait: true)
                    }
                }
                stage('triton-cmon-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*triton-cmon-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/triton-cmon-agent/master',
                            wait: true)
                    }
                }
                stage('sdc-cn-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-cn-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-cn-agent/master',
                            wait: true)
                    }
                }
                stage('sdc-net-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-net-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-net-agent/master',
                            wait: true)
                    }
                }
                stage('sdc-vm-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-vm-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-vm-agent/master',
                            wait: true)
                    }
                }
                stage('sdc-hagfish-watcher') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-hagfish-watcher.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-hagfish-watcher/master',
                            wait: true)
                    }
                }
                stage('sdc-smart-login') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-smart-login.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-smart-login/master',
                            wait: true)
                    }
                }
                stage('sdc-amon') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-amon.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-amon/master',
                            wait: true)
                    }
                }
                stage('sdc-firewaller-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-firewaller-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-firewaller-agent/master',
                            wait: true)
                    }
                }
                stage('sdc-config-agent') {
                    when {
                        branch 'weekly-build'
                        triggeredBy cause: 'UserIdCause'
                        expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-config-agent.*" }
                    }
                    steps {
                        build(
                            job: 'joyent-org/sdc-config-agent/master',
                            wait: true)
                    }
                }
            }
        }
        stage('agents-installer') {
            when {
                allOf {
                    branch 'weekly-build'
                    triggeredBy cause: 'UserIdCause'
                    expression { params.COMPONENTS == "" || params.COMPONENTS =~ ".*sdc-agents-installer.*" }
                }
            }
            steps {
                build(
                    job: 'joyent-org/sdc-agents-installer/master',
                    wait: true)
            }
        }
        /*
         * Now that all components are built, build the headnode images.
         */
        stage('sdc-headnode') {
            when {
                allOf {
                    branch 'weekly-build'
                    triggeredBy cause: 'UserIdCause'
                }
            }
            steps {
                build(
                    job: 'joyent-org/sdc-headnode/master',
                    wait: true,
                    parameters: [
                        text(name: 'CONFIGURE_BRANCHES',
                            value:
                            "bits-branch: master"),
                        booleanParam(name: 'INCLUDE_DEBUG_STAGE', value: true)
                    ])
            }
        }
    }
    post {
        always {
            joyMattermostNotification(channel: 'jenkins')
        }
    }
}
