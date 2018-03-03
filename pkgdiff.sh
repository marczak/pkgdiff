#!/bin/bash

DEBUG=0

# Did we get *some* input? Hopefully it's a pkg
if [ "${1}xx" == "xx" ]; then
  echo "Please supply a pkg file."
  exit 1
fi

# ...does it at least end in ".pkg"?
PKGEXT="${1##*.}"
if [ $PKGEXT != "pkg" ]; then
  echo "This doesn't look like a pkg."
  echo "Extension is ${PKGEXT}"
  exit 4
fi

# ...is it a bundle?
if file --mime-type "${1}" | grep -q directory$; then
  if [ $DEBUG -eq 1 ]; then
    echo "It is a bundle!"
  fi
  # No tmp dir needed
  PKGBASE=${1}
fi

# ...is it a compressed flat file?
if file --mime-type "${1}" | grep -q x-xar$; then
  if [ $DEBUG -eq 1 ]; then
    echo "It is a compressed flat package"
  fi

  # Get temp directory for working
  PKGBASE=$(mktemp -qd)
  if [ $? -ne 0 ]; then
    echo "${0}: Can not create temp dir, exiting..."
    exit 10
  fi

  if [ $DEBUG -eq 1 ]; then
    echo "Created ${PKGBASE}"
  fi

  # Unflatten package
  xar -x -f "${1}" -C "${PKGBASE}"
fi

if [[ -f ${PKGBASE}/Bom ]]; then
  while read -sr FULLPATH PERMS IDS SIZE CRC
  do
    # Strip the leading dot from the path
    CURFILE=$(echo ${FULLPATH} | sed 's/\(^.\)\(.*\)/\2/')
    #echo "Path = ${CURFILE}"
    #echo "Perms = $PERMS, Size = $SIZE"
    # Tests
    # Does the file exist?
    if [[ ! -f ${CURFILE} ]]; then
      echo "${CURFILE} is a new install."
    else
      # It exists! Compare it.
      # Get current perms
      PFPERMS=$(stat -f "%Hp%Mp%Lp" ${CURFILE})

      # Get IDs
      PFIDS=$(stat -f "%u/%g" ${CURFILE})

      # Get size
      PFSIZE=$(stat -f "%z" ${CURFILE})

      # Get CRC
      PFCRC=$(cksum pkgdiff.sh | awk '{print $1}')

      /bin/echo -n "${CURFILE} is changed: "
      if [[ ${PERMS} != ${PFPERMS} ]]; then
        /bin/echo -n "Perms was ${PERMS}, now ${PFPERMS} "
      fi
      if [[ ${IDS} != ${PFIDS} ]]; then
        /bin/echo -n "Owners was ${IDS}, now ${PFIDS} "
      fi
      if [[ ${SIZE} != ${PFSIZE} ]]; then
	/bin/echo -n "Size was ${SIZE}, now ${PFSIZE} "
      fi
      if [[ ${CRC} != ${PFCRC} ]]; then
        /bin/echo -n "CRC was ${CRC}, now ${PFCRC} "
      fi
      echo
    fi
  done < <(lsbom -f ${PKGBASE}/Bom)
else
  echo "There is no Bom file...is this a metapackage, perhaps?"
  exit 50
fi
