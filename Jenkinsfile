pipeline {
    agent none
    environment {
        repo_url = 'https://github.com/sahirug/spring-petclinic'
        repo_branch = 'new-pipeline-script-branch'
        stage_start = 'STAGE_START'
        stage_end = 'STAGE_END'
    }
    
    stages {
        stage('Checkout') {
            agent any
            steps {
                script {
                    try {
                        signalStageStart('Checkout')
                        git(url: "${repo_url}", branch: "${repo_branch}")
                        sh 'ls -la'
                        signalStageEnd('Checkout')
                    } catch (e) {
                        handleErr(e)
                        signalStageEnd('Checkout')
                        throw e 
                    }
                }
            }
        }
        
        stage('Commit Changes') {
            agent any
            steps {
                script {
                    try {
                        signalStageStart('Commit Changes')
                        def publisher = LastChanges.getLastChangesPublisher "LAST_SUCCESSFUL_BUILD", "SIDE", "LINE", true, true, "", "", "", "", ""
                        publisher.publishLastChanges()
                        def changes = publisher.getLastChanges()
                        for (commit in changes.getCommits()) {
                            def commitInfo = commit.getCommitInfo()
                            echo commitInfo.getCommitId()
                            echo commitInfo.getCommitMessage()
                            echo commitInfo.getCommiterName()
                            echo commitInfo.getCommitDate()
                        }
                        sh "ls -la"
                        signalStageEnd('Commit Changes')
                    } catch (e) {
                        handleErr(e)
                        signalStageEnd('Commit Changes')
                        throw e
                    }
                }
            }
        }

        // stage('Maven Build and Test') {
        //     agent {
        //         docker {
        //             image 'maven:3.5.3'
        //         }
        //     }
        //     steps {
        //         script {
        //             try {
        //                 signalStageStart('Maven Build and Test')
        //                 sh 'ls -la'
        //                 sh 'mvn clean install -U'
        //                 signalStageEnd('Maven Build and Test')
        //             } catch (e) {
        //                 handleErr(e)
        //                 signalStageEnd('Maven Build and Test')
        //                 throw e
        //             }
        //         }
        //     }
        // }

        stage('Test Result Extraction') {
            agent any
            steps {
                script {
                    try {
                        signalStageStart('Test Result Extraction')
                        def files = findFiles(glob: "**/TEST-*.xml")
                        def runs = 0, fails = 0, skips = 0, success = 0
                        for (def file : files) {
                            echo "Found TEST file ===> ${file.path}"
                            def testResults = new File(WORKSPACE + '/' + file.path).getText('UTF-8').trim()
                            def parser = new XmlParser()
                            parser.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false)
                            parser.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
                            parser.setFeature("http://xml.org/sax/features/namespaces", false)

                            def testReport = parser.parseText(testResults)
                            // echo "${testReport}"
                            // def prop = Integer.parseInt(testReport.attribute('tests').toString())
                            // echo "${prop}"
                            runs = runs + Integer.parseInt(testReport.attribute('tests').toString())
                            fails = fails + Integer.parseInt(testReport.attribute('errors').toString())
                            skips = skips + Integer.parseInt(testReport.attribute('skipped').toString())
                            fails = fails + Integer.parseInt(testReport.attribute('failures').toString())
                        }
                        success = runs - ( fails + fails + skips )

                        echo "### TEST RESULTS ###"
                        echo "Success => ${success}"
                        echo "fails => ${fails}"
                        echo "### TEST RESULTS ###"

                        signalStageEnd('Test Result Extraction')
                    } catch (e) {
                        handleErr(e)
                        signalStageEnd('Test Result Extraction')
                        throw e
                    }
                }
            }
        }
    }
}

def signalStageStart(stageName) {
    signalStageEvent('STAGE_START', stageName);
}

def signalStageEnd(stageName) {
    signalStageEvent('STAGE_END', stageName);
}

def signalStageEvent(event, stageName) {
    switch (event) {
        case 'STAGE_START':
            echo "######################################### STAGE START: ${stageName} #########################################"
            break;
        case 'STAGE_END':
            echo "########################################## STAGE END: ${stageName} ##########################################"
            break;
    }
}

def handleErr(e) {
    def errMsg = e.getMessage()
    echo "Script failed with err => ${errMsg}"
}