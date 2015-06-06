#!/bin/sh

EXPORT_DIR=$BUILT_PRODUCTS_DIR/$QO_COPY_HEADERS_DESTINATION

handle_dir()
{
    EXPORT_SEARCH_DIR=$1
    DESTINATION_DIR=$2
    EXCLUDE_RAWLIST=$3
    EXCLUDE_FILELIST=$(echo $EXCLUDE_RAWLIST | tr "," "\n")

    [[ ! -d $DESTINATION_DIR ]] && mkdir -p $DESTINATION_DIR

    for SRC_EXPORT_FILE in $(find $EXPORT_SEARCH_DIR ! -type d \( -name "*.h" -o -name "*.hpp" \) -print 2>/dev/null)
    do
        FileName=$(basename ${SRC_EXPORT_FILE})
   
        FILE_SHOULD_BE_EXCLUDED=0
        for EX_FILE in $EXCLUDE_FILELIST
        do
              if [ $EX_FILE == $FileName ]; 
              then
                  FILE_SHOULD_BE_EXCLUDED=1
                  break
              fi
        done

        if [ $FILE_SHOULD_BE_EXCLUDED -eq 0 ];
        then
            #SubDirName="${SRC_EXPORT_FILE:${#EXPORT_SEARCH_DIR}+1:${#SRC_EXPORT_FILE}}"

            DST_EXPORT_FILE=${DESTINATION_DIR}"/"${FileName}

            if [ $SRC_EXPORT_FILE -nt $DST_EXPORT_FILE ]; then
                 echo "Copy " $FileName " in " $DST_EXPORT_FILE
                 cp -f -p $SRC_EXPORT_FILE $DST_EXPORT_FILE
            fi
       fi
    done
}

EXCLUDE_LIST=""
if [ $# -gt 1 ];
then
   if [ $1 == "-x" ]; 
   then
      EXCLUDE_LIST=$2
      shift
      shift
   fi
fi

for SEARCH_DIR in "$@"
do
    EXPORT_SEARCH_DIR=$SRCROOT/$SEARCH_DIR

    handle_dir $EXPORT_SEARCH_DIR $EXPORT_DIR $EXCLUDE_LIST
done
