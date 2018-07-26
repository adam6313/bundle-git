#!/bin/bash

Color_Off='\033[0m'
Green='\033[0;32m' 
Yellow='\033[0;33m'
IBlack='\033[0;90m'
OriginPath=$PWD

Entry() {
  abridge=$1
  cd
  # 檢查目錄 是否存在
  if [ -d "./Desktop/${file}" ]; then # 檢查目錄 存在
    echo "Directory $(pwd)/${file} does exists."
    echo $PWD
    cd Desktop/${file}
    echo $PWD
    CheckDependencies
  else                                # 檢查目錄 不存在
    echo "Directory $(pwd)/${file} does not exists."
  fi
} || {
  echo 'Fail'
}

Set() {
  Btcms=N
  if [ $file == "cypress-cms" ]; then
    echo "Do you need to build two versions(Bt-cms)? [Y/N]: \c" 
    read Btcms
  fi
  # echo "Please enter your version($(cat package.json | jq '.version' | tr -d '"')): \c"
  echo "${Green} ? ${Color_Off}Please enter your version ${IBlack}($(cat package.json | grep "[\"\']version[\"\']" | awk '{print $2}' | tr -d '",'))${Color_Off} \c"
  read ver

  echo "${Green} ? ${Color_Off}Please enter your commit: \c"
  read commit
            
  echo "${Green} ? ${Color_Off}Written into the ChangeLog? [Y/N]: \c"
  read Written

  GitOperate #func
}

CheckDependencies() {
  AlreadyGit=$(which git | grep -o '\/')
  if [ ! -z "$AlreadyGit" ];
    then Set
    else 
      echo "${Yellow}Build dependency please install git"
      exit
  fi
}

GitOperate() {
  versionLine=$(cat package.json | grep -n [\'\"]version[\"\'] | awk -F':' '{print $1}')
  sed -i '' "${versionLine}s/.*/  \"version\": \"$ver\",/" package.json
  # jq '.version = "'${ver}'"' package.json > tmp.$$.json && mv tmp.$$.json package.json
  Git #func
  if [ $Btcms == 'Y' -o $Btcms == 'y' ];
    then 
      Git dist2 builds
      Git dist
    else Git dist build   #func
  fi

  if [ ${Written} == "Y" -o ${Written} == "y" ]; then
    DATE=`date '+%Y-%m-%d %H:%M'`
    cd $OriginPath
    ./index-macos "${abridge}" "${ver}" "${commit}" "${DATE}" "${SheetName}" "${gid}"
  fi
  echo "Success !!"
}

Git() {
  WorkFile=$1
  Script=$2
  if [ ! -z "$WorkFile" ];
    then
      Command="--git-dir=${WorkFile}/.git --work-tree=${WorkFile}"
      git ${Command} pull
      # rm -rf ${WorkFile}/index.html ${WorkFile}/static
      if [ ! -z "$Script" ]; then
        npm run $Script
      fi
  fi
  branch=$(git ${Command} branch | grep '*' | sed 's/*//g')

  commitID=$(git ${Command} rev-parse HEAD)
  [ ! -z ${WorkFile} ] && $(sed -i '' "s/AIV_SHORT/${commitID}/" ${WorkFile}/index.html)
  
  git ${Command} add .
  git ${Command} commit -m "${commit}"
  git ${Command} tag -a "${ver}" -m "${commit}"
  git ${Command} push origin ${branch} --tag
}

function Help () {
# Using a here doc with standard out.
cat <<-END
Usage: sh run.sh [options]

options:
   -h --help    involved overview.
Bundle file, commit file and push
   cms     cypress-cms
   pd      payday
   as      ActivitySystem
   gta     gta
   gof     gameoffice
END
}

case $1 in
    "-h" | "--help")
      Help
      exit
    ;;
    "v2")
        cd cypress-cms
        npm run dev
    ;;
    "order")
        cd orderdetail
        npm run dev
     ;;
     "game")
       ./glgen server -p 1324
     ;;
     "switch")
       cd GameSwitch
       npm run dev
     ;;
     "rn")
        prefix=$2
        dir=$3
        files=$(ls ${dir}${prefix}*)

        for foo in ${files}
        do
        INDEX=$(( INDEX+1 ))
        newname=`echo "$foo" | sed "s/$prefix//"`
        echo -e "${INDEX}. ${foo} rename to ${newname}"
        mv ${foo} ${newname}
        done
     ;;
     "cms")
       file=cypress-cms
       SheetName=Bo-Front
       gid=261584070
       Entry $1 ${file}
     ;;
     "pd")
       file=payday
       SheetName=PayDay-Front
       gid=1713810997
       Entry $1 ${file}
     ;;
     "as")
       file=ActivitySystem
       SheetName=ActivitySystem
       gid=1696696277
       Entry $1 ${file}
     ;;
     "gta" )
       file=gta
       Entry $1 ${file}
     ;;
     "gof" )
       file=gameoffice
       SheetName=GameOffice-Front
       gid=412322791
       Entry $1 ${file}
     ;;
     "adam" )
       file=AdamTest
       SheetName=GameOffice-Front2
       gid=52059714
       Entry $1 ${file}
     ;;
esac

