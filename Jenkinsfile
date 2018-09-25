/* 
* Copyright (c) 2017 and Confidential to Pegasystems Inc. All rights reserved.  
*/ 

pipeline {
    agent any

    options {
      timestamps()
      timeout(time: 15, unit: 'MINUTES')
      withCredentials([
        usernamePassword(credentialsId: 'PDM_JFrogRepository', 
            passwordVariable: 'P@ssw0rd_pega', 
            usernameVariable: 'pega_admin')
        /*usernamePassword(credentialsId: 'puneeth_export', 
            passwordVariable: 'rules', 
            usernameVariable: 'puneeth_export')*/
        ])
    }

    stages {

        stage('Check for merge conflicts'){
            steps {
                echo ('Clear workspace')
                dir ('build/export') {
                    deleteDir()
                }

                echo 'Determine Conflicts'
                sh "./gradlew"
		sh "./gradlew getConflicts -PtargetURL=${PEGA_DEV} -Pbranch=TestDevOps4 -PpegaUsername=puneeth_export -PpegaPassword=rules"
            }
        }

        stage('Run unit tests'){
          steps {
            echo 'Execute tests'

            withEnv(['TESTRESULTSFILE="TestResult.xml"']) {
              sh "./gradlew executePegaUnitTests -PtargetURL=${PEGA_DEV} -PpegaUsername=puneeth_export -PpegaPassword=rules -PtestResultLocation=${WORKSPACE} -PtestResultFile=${TESTRESULTSFILE}"
                    
             // junit(allowEmptyResults: true, testResults: "${env.WORKSPACE}/${env.TESTRESULTSFILE}")

              script {
                if (currentBuild.result != null) {
                  input(message: 'Ready to share tests have failed, would you like to abort the pipeline?')
                }
              }
            }
          }
       }
       stage('Approve for Merge?'){
		steps {
	
		/*input message: 'Proceed with Merge'
		echo 'Merging the rules..'*/

		 mail (
		           subject: "Approval for ${env.BUILD_NUMBER}",
			             body: "Your build ${env.BUILD_NUMBER}, ${env.RUN_DISPLAY_URL}/input/",
				               to: "puneeth.in@gmail.com"
					             )
		input message: 'Ready to go?' 

		}

       }
       stage('Export from Dev') {
                   steps {
		                   echo 'Exporting application from Dev environment : ' + env.PEGA_DEV
				                   sh "./gradlew performOperation -Dprpc.service.util.action=export -Dpega.rest.server.url=${env.PEGA_DEV}/PRRestService -Dpega.rest.username=puneeth_export -Dpega.rest.password=rules -Duser.temp.dir=${WORKSPACE}/tmp"
							  }
							               }


       stage('Merge branch'){
       /* when {
          environment name: "PERFORM_MERGE", value: "true"
        }*/

        steps{

            echo 'Perform Merge' 

            sh "./gradlew merge -PtargetURL=${env.PEGA_DEV} -Pbranch=TestDevOps4 -PpegaUsername=puneeth_export -PpegaPassword=rules"
            echo 'Evaluating merge Id from gradle script = ' + env.MERGE_ID
            timeout(time: 5, unit: 'MINUTES') {
                echo "Setting the timeout for 1 min.."
                retry(10) {
                    echo "Merge is still being performed. Retrying..."
                    sh "./gradlew getMergeStatus -PtargetURL=${env.PEGA_DEV} -PpegaUsername=puneeth_export -PpegaPassword=rules"
                    echo "Merge Status : ${env.MERGE_STATUS}"
                }
            }
          }
        }


        /*stage('Publish to Artifactory') {

            steps {
                echo 'Publishing to Artifactory '
                sh "./gradlew artifactoryPublish -PartifactoryUser= -PartifactoryPassword="
            }
        }

        stage('Regression Tests') {

            steps {
                echo 'Run regression tests'
                echo 'Publish to production repository'
            }
        }*/

        stage('Fetch from Artifactory') {

            steps {
              echo 'Fetching application archive from Artifactory'
              sh  "./gradlew fetchFromArtifactory -PartifactoryUser=pega_admin -PartifactoryPassword=P@ssw0rd_pega --debug"
            }
        }

        /*stage('Create restore point') {

            steps {
                echo 'Creating restore point'
                sh "./gradlew createRestorePoint -PtargetURL=${PEGA_PROD} -PpegaUsername=${IMS_USER} -PpegaPassword=${IMS_PASSWORD}"
            }
        }
        stage('Deploy to production') {

            steps {
              echo 'Deploying to production : ' + env.PEGA_PROD

              sh "./gradlew performOperation -Dprpc.service.util.action=import -Dpega.rest.server.url=${env.PEGA_PROD}/PRRestService -Dpega.rest.username=puneeth_export  -Dpega.rest.password=rules -Duser.temp.dir=${WORKSPACE}/tmp --debug"
            }
        }*/
  }

  post {
    failure {
      mail (
          subject: "${JOB_NAME} ${BUILD_NUMBER} merging branch  has failed",
          body: "Your build ${env.BUILD_NUMBER} has failed.  Find details at ${env.RUN_DISPLAY_URL}", 
          to: "puneeth.in@gmail.com"
      )
    }   
  }
}
