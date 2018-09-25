`curl http://svl-jbuild-d1:8091/artifactory/Pega_PDM/branch/TestDevOps4/ExportWizard/ >> ./1.txt`
`cat 1.txt|grep -i href|tail -n 1|cut -d \" -f 2 > 1.txt`
