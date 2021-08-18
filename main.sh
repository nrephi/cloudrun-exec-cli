# get parameters
# command=${1}
#
set -x

CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET=cloudrun_exec_cli_archive_bucket
echo "scripts arguments" ${1:1}
IFS='<<>>' read -r command parameters <<< "${1:1}"

curr_time=$(date +"%Y-%m-%d_%H-%M-%S")

workdir=$command$curr_time
echo "work_dir "$workdir

# Copy exec file
gsutil cp -r gs://${CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET}/$command $command

# go to folder $command
cd $workdir

# exec with params
params=$(echo $params | sed 's/&/ /g')
main.sh $params > outputlog.txt 2>&1

# copy file to storage
gsutil cp outputlog.txt gs://${CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET}/$command/outputlog.txt 

# remove the command folder
cd ..
rm -rf $workdir

