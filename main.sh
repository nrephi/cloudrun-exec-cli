# get parameters
# command=${1}
#
set -x

# CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET=cloudrun_exec_cli_archive_bucket
echo "scripts arguments" ${1:1}
IFS='<<>>' read -r command parameters <<< "${1:1}"

curr_time=$(date +"%Y-%m-%d_%H-%M-%S")

workdir=$command$curr_time
echo "work_dir "$workdir
mkdir -p $workdir

# Copy exec file
gsutil cp -r gs://${CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET}/$command/scripts/* $workdir

# go to folder $command
cd $workdir

# exec with parameters
parameters=$(echo ${parameters:3} | sed 's/&/ /g')
ls
chmod 777 -R .
bash main.sh $parameters 2>&1 | tee  outputlog.txt

# copy file to storage
gsutil cp outputlog.txt gs://${CLOUDRUN_EXEC_CLI_ARCHIVE_BUCKET}/$command/logs/outputlog$curr_time.txt 

# remove the command folder
cd ..
rm -rf $workdir

