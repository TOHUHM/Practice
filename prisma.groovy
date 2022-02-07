        stage('Prisma Cloud Scan') {
            steps {
                prismaCloudScanImage  dockerAddress: "$DOCKER_HOST", image: "your.repo/your/image:your_tag", logLevel: 'debug', resultsFile: 'prisma-cloud-scan-results.json'
            }
        }

        stage('Prisma report ') {
            when {
                expression { env.CHANGE_ID != null }
            }
            steps {
                script {
                     def prismaResponse = readJSON file: 'prisma-cloud-scan-results.json'
                     def vuln = prismaResponse[0].entityInfo.vulnerabilities
                     def PULL_REQUEST = env.CHANGE_ID
                     def COMMIT_ID = env.GIT_COMMIT

                     //template for each line of the message.
                     def templateLine =  "| {cve} | {severity} | {cvss} | {package} | {version} | {status} | {description} |<br />"

                     //Message to build for the pr, you can add more items using prisma-result.json or other information coming from jenkins context
                     def message = "## Prisma scan result:<br />"
                     message += "**Scan passed:** ${prismaResponse[0].pass}<br />"
                     message += "**Scan Result:** ${prismaResponse[0].entityInfo.vulnerabilityDistribution}<br />"
                     message += "<details><summary>Details</summary><br /><br />"

                     message += templateLine.replace("{cve}","CVE").replace("{severity}","SEVERITY").replace("{cvss}","CVSS").replace("{package}","PACKAGE").replace("{version}","VERSION").replace("{status}","STATUS").replace("{description}", "DESCRIPTION")
                     message += templateLine.replace("{cve}","--").replace("{severity}","--").replace("{cvss}","--").replace("{package}","--").replace("{version}","--").replace("{status}","--").replace("{description}", "--")
                      //build the details for each vulnerabilities.
                     for ( def data : vuln ){
                      //sanitize the description which can contains special characters, and avoid the curl.
                      def description = data.description.replace('\\',' ').replace('\'',' ').replace('\"',' ').replace('/', ' ')
                      message += templateLine.replace("{cve}","${data.cve}").replace("{severity}","${data.severity}").replace("{cvss}","${data.cvss}").replace("{package}","${data.packageName}").replace("{version}","${data.packageVersion}").replace("{status}","${data.status}").replace("{description}", "${description}")
                      }
                     message += "</details><br />"

                     //push a comment to the opening PR, you repo should be on dkt united. we use curl since the plugin githubComment doesn't work.
                    withCredentials([usernamePassword(credentialsId: 'GitHubAppJenkins', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'no_need')]) {

                    sh("echo \'{\"commit_id\": \"$COMMIT_ID\", \"body\": \"$message\", \"event\": \"COMMENT\" }\' | sed \'s/<br \\/>/\\\\n/g\' > prisma_message")
                    sh("curl -X POST https://api.github.com/repos/dktunited/oneom-platform/pulls/$PULL_REQUEST/reviews \
                      -H 'Authorization: token $GITHUB_TOKEN' \
                      -H 'Content-Type: application/json' \
                      -d @prisma_message");
                    }
            }
}