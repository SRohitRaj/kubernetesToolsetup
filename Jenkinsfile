pipeline {
    agent any
    stages {
           stage ('Pre-requisites') {
               steps {
                  sshagent(credentials : ['ubuntu']) {
                  //  sh "ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST mkdir -p ${tools_dir}"  
                      sh "ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST ls"
                   
                  }
               }
           }
            stage ('Checkout') {
             steps{
             checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'githubcredentials', url: 'https://github.com/devendradhoot/kubernetes-tools-setup.git']]])      
            }
            }
           stage('Environment Setup') {
             steps {
                 script { 
                     sh  'echo "#!/bin/bash" > ENV.sh'
                     sh  'echo export BOTTOKEN=$BOTTOKEN >> ENV.sh'
                     sh  'echo export BOT_APP_ID=$BOT_APP_ID >> ENV.sh'
                     sh  'echo export BOT_APP_PWD=$BOT_APP_PWD >> ENV.sh'
                     sh  'echo export BOT_HOST_PATH=$BOT_HOST_PATH >> ENV.sh'
                     sh  'echo export KUBECOST=$KUBECOST >> ENV.sh'
                     sh  'echo export GRAFANA_HOST_PATH=$GRAFANA_HOST_PATH >> ENV.sh'
                     sh  'echo export K8DASH_HOST_PATH=$K8DASH_HOST_PATH >> ENV.sh'
                     sh  'echo export PROMETHEUS_HOST_PATH=$PROMETHEUS_HOST_PATH >> ENV.sh'
                     sh  'echo export SOCKSHOP_HOST_PATH=$SOCKSHOP_HOST_PATH >> ENV.sh'
                     sh  'echo export CHAOS_MESH_PATH=$CHAOS_MESH_PATH >> ENV.sh'
                     sh  'echo export ARGOCD_HOST=$ARGOCD_HOST >> ENV.sh'
                     sh  'echo export DASHBOARD_HOST_PATH=$DASHBOARD_HOST_PATH >> ENV.sh'
                   sshagent(credentials : ['ubuntu']) {
                    sh "scp -r -o StrictHostKeyChecking=no * $ssh_user@$HOST:${tools_dir}"                
                    }
                }
             }
         }
        stage('cert-manager') {
            when {
              expression { params.Application == 'cert-manager' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/cert-manager/cert-manager.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
         stage('Dashboard') {
            when {
              expression { params.Application == 'Dashboard' || params.Application == 'All'}
            } 
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    sh ${tools_dir}/dashboard/dashboard.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
          
           stage('K8-Dash') {
            when {
              expression { params.Application == 'K8-Dash' || params.Application == 'All'}
            }   
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/k8dash/k8dash.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
          stage('HPA') {
            when {
              expression { params.Application == 'HPA' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/hpa/hpa.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
         stage('Ingress-Controller') {
            when {
              expression { params.Application == 'Ingress-Controller' || params.Application == 'All'}
            } 
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/ingress-controller/ingress-controller.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
          stage('Metrics-Server') {
            when {
              expression { params.Application == 'Metrics-Server' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/metrics-server/metrics_server.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

          stage('Helm-Installation') {
            when {
              expression { params.Application == 'Helm-Installation' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/helm-installation/helm_installation.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

          stage('Litmus-Chaos') {
             when {
              expression { params.Application == 'Litmus-Chaos' || params.Application == 'All'}
            }     
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    cd ${tools_dir}/litmus/
                    bash ./setup.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

        stage('Prometheus') {
            when {
              expression { params.Application == 'Prometheus' || params.Application == 'All'}
            }
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    cd ${tools_dir}/prometheus
                    bash ./setup.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
         stage('Grafana') {
             when {
              expression { params.Application == 'Grafana' || params.Application == 'All'}
            }
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    cd ${tools_dir}/grafana
                    bash ./setup.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

          stage('Chaos-Mesh') {
            when {
              expression { params.Application == 'Chaos-Mesh' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/chaos-mesh/chaos.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

   /*         stage('ELK-Stack') {
              when {
              expression { params.Application == 'ELK-Stack' || params.Application == 'All'}
            }
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/elk/elk.sh
                    exit
                    EOF"""
                    }
                }
             }
         } */   
        stage('Collaboration-Tools') {
            when {
              expression { params.Application == 'Collaboration-Tools' || params.Application == 'All'}
            }
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/collaboration-tools/botkube.sh
                    exit
                    EOF"""
                    }
                }
             }
         }



            stage('GitOps') {
            when {
              expression { params.Application == 'GitOps' || params.Application == 'All'}
            }    
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    sh ${tools_dir}/gitops/argocd.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

            stage('Argo-Rollouts') {
            when {
              expression { params.Application == 'Argo-Rollouts' || params.Application == 'All'}
            }    
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/argro-rollouts/argocd-rollout.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

          stage('Workflows') {
            when {
              expression { params.Application == 'Workflows' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/argo-workflow/argocd-workflow.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

             stage('KubeCost') {
             when {
              expression { params.Application == 'KubeCost' || params.Application == 'All'}
            }     
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/kubecost/kubecost.sh
                    exit
                    EOF"""
                    }
                }
             }
         }
          stage('Istio') {
            when {
              expression { params.Application == 'Istio' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/istio/istio-setup.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

          stage('Trivy') {
            when {
              expression { params.Application == 'Trivy' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/trivy/trivy_install.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

        //  stage('Tracee') {
        //         when {
        //         expression { params.Application == 'Tracee' || params.Application == 'All'}
        //         }  
        //         steps {
        //             script {
        //                 sshagent(credentials : ['ubuntu']) {
        //                 sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
        //                 bash ${tools_dir}/tracee/tracee_syscalls.sh
        //                 exit
        //                 EOF"""
        //                 }
        //             }
        //         }
        //     }

           stage('UFW') {
            when {
              expression { params.Application == 'UFW' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/ufw/ufw_install.sh
                    exit
                    EOF"""
                    }
                }
             }
         }


        // stage('Falco') {
        //     when {
        //       expression { params.Application == 'Falco' || params.Application == 'All'}
        //     }  
        //      steps {
        //          script {
        //             sshagent(credentials : ['ubuntu']) {
        //             sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
        //             bash ${tools_dir}/falco/falco_installation.sh
        //             exit
        //             EOF"""
        //             }
        //         }
        //      }
        //  }


         stage('Kube-Bench') {
            when {
              expression { params.Application == 'Kube-Bench' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    cd ${tools_dir}/kube-bench
                    bash ./kube-bench_installation.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

        stage('Kubesec') {
            when {
              expression { params.Application == 'Kubesec' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    bash ${tools_dir}/kube-sec/kubesec_install.sh
                    exit
                    EOF"""
                    }
                }
             }
         }

        stage('Kube-hunter') {
            when {
              expression { params.Application == 'Kube-hunter' || params.Application == 'All'}
            }  
             steps {
                 script {
                    sshagent(credentials : ['ubuntu']) {
                    sh """ssh  -o StrictHostKeyChecking=no -tt $ssh_user@$HOST << EOF
                    . ${tools_dir}/ENV.sh
                    kubectl apply -f  ${tools_dir}/kube-hunter/job.yaml
                    exit
                    EOF"""
                    }
                }
             }
         }
   


        }
    }
