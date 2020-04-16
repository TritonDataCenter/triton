/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2020 Joyent, Inc.
 */

@Library('jenkins-joylib@v1.0.6') _

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
            name: 'COMPONENT_BRANCH',
            defaultValue: 'master',
            description:
                'The branch of the Triton/Manta components to build.'
            )
        string(
            name: 'COMPONENTS',
            defaultValue: '',
            description:
                'A space separated list of the repositories to build. ' +
                'By default, all components are included, but if any are ' +
                'specified here, <strong>only</strong> those are built, ' +
                'apart from sdc-headnode, which is automatically built ' +
                'unless this is a SmartOS-only build.'
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
                build(job: 'joyent-org/smartos-live/' + env.COMPONENT_BRANCH,
                    wait: true,
                    parameters: [
                        text(name: 'CONFIGURE_PROJECTS',
                            value:
                            'illumos-extra: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'illumos: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'local/kbmd: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'local/kvm-cmd: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'local/kvm: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'local/mdata-client: ' + env.COMPONENT_BRANCH + ': origin\n' +
                            'local/ur-agent: ' + env.COMPONENT_BRANCH + ': origin'),
                        booleanParam(name: 'BUILD_STRAP_CACHE', value: false),
                        text(name: 'PLATFORM_BUILD_FLAVOR', value: 'triton-and-smartos')
                    ])
            }
        }
        stage('binder') {
            steps {
                joyTriggerTritonComp(
                    repo: "binder",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('electric-moray') {
            steps {
                joyTriggerTritonComp(
                    repo: "electric-moray",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('ipxe') {
            steps {
                joyTriggerTritonComp(
                    repo: "ipxe",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('mahi') {
            steps {
                joyTriggerTritonComp(
                    repo: "mahi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-buckets-api') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-buckets-api",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-buckets-mdapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-buckets-mdapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-buckets-mdplacement') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-buckets-mdplacement",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-garbage-collector') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-garbage-collector",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-mackerel') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-mackerel",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-madtom') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-madtom",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-mako') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-mako",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-manatee') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-manatee",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-minnow') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-minnow",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-mola') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-mola",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-muskie') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-muskie",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-rebalancer') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-rebalancer",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-reshard') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-reshard",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('manta-storinfo') {
            steps {
                joyTriggerTritonComp(
                    repo: "manta-storinfo",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('moray') {
            steps {
                joyTriggerTritonComp(
                    repo: "moray",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('muppet') {
            steps {
                joyTriggerTritonComp(
                    repo: "muppet",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('pgstatsmon') {
            steps {
                joyTriggerTritonComp(
                    repo: "pgstatsmon",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('registrar') {
            steps {
                joyTriggerTritonComp(
                    repo: "registrar",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-adminui') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-adminui",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-amonredis') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-amonredis",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-assets') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-assets",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-booter') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-booter",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-cloudapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-cloudapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-cnapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-cnapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-docker') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-docker",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-dockerlogger') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-dockerlogger",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-fwapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-fwapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-imgapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-imgapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-manatee') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-manatee",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-manta') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-manta",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-napi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-napi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-nat') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-nat",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-nfsserver') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-nfsserver",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-papi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-papi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-portolan') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-portolan",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-rabbitmq') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-rabbitmq",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-sapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-sapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-sdc') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-sdc",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-system-tests') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-system-tests",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-ufds') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-ufds",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-vmapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-vmapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-volapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-volapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdc-workflow') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-workflow",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('sdcadm') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdcadm",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-cmon') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-cmon",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-cns') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-cns",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-grafana') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-grafana",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-kbmapi') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-kbmapi",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-logarchiver') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-logarchiver",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-mockcloud') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-mockcloud",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('triton-prometheus') {
            steps {
                joyTriggerTritonComp(
                    repo: "triton-prometheus",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
            }
        }
        stage('waferlock') {
            steps {
                joyTriggerTritonComp(
                    repo: "waferlock",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
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
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-agents-core",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('triton-cmon-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "triton-cmon-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-cn-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-cn-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-net-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-net-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-vm-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-vm-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-hagfish-watcher') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-hagfish-watcher",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-smart-login') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-smart-login",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-amon') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-amon",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-firewaller-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-firewaller-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
                stage('sdc-config-agent') {
                    steps {
                        joyTriggerTritonComp(
                            repo: "sdc-config-agent",
                            whenBranch: "weekly-build",
                            compBranch: env.COMPONENT_BRANCH,
                            isAgentBuild: true)
                    }
                }
            }
        }
        stage('agents-installer') {
            steps {
                joyTriggerTritonComp(
                    repo: "sdc-agents-installer",
                    whenBranch: "weekly-build",
                    compBranch: env.COMPONENT_BRANCH)
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
                    job: 'joyent-org/sdc-headnode/' + env.COMPONENT_BRANCH,
                    wait: true,
                    parameters: [
                        text(name: 'CONFIGURE_BRANCHES',
                            value:
                            "bits-branch: " + env.COMPONENT_BRANCH),
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
