#
#   DIST.sh
#
#   David Janes
#   IOTDB
#   2014-12-04
#
#   Distribute iotdb-homestar to NPM
#

DO_NPM_IOTDB_PACKAGE=true
DIST_ROOT=/var/tmp/iotdb-homestar.dist.$$
IOTDB_ROOT=$HOME/iotdb

if [ ! -d "$DIST_ROOT" ]
then
    mkdir "$DIST_ROOT"
fi

if $DO_NPM_IOTDB_PACKAGE
then
    echo "=================="
    echo "NPM Packge: iotdb"
    echo "=================="
    (
        NPM_SRC=../iotdb-homestar
        cd $NPM_SRC || exit 1

        NPM_DST=$DIST_ROOT/iotdb-homestar
        echo "NPM_DST=$NPM_DST"

        if [ -d ${NPM_DST} ]
        then
            rm -rf "${NPM_DST}"
        fi
        mkdir "${NPM_DST}" || exit 1

        update-package --increment-version || exit 1

##        python -c "
##import json
##
##filename = 'package.json'
##jd = json.load(open(filename))
##versions = jd['version'].split('.')
##versions[-1] = '%d' % ( int(versions[-1]) + 1, )
##jd['version'] = '.'.join(versions)
##json.dump(jd, open(filename, 'w'), sort_keys=True, indent=4)
##print 'new package version:', jd['version']
##" || exit 1

        export COPYFILE_DISABLE=1
        tar cf - \
            --exclude "xx*" \
            --exclude "yy*" \
            --exclude ".iotdb" \
            --exclude "node_modules" \
            --exclude "Gruntfile.js" \
            README.md \
            LICENSE.txt \
            package.json \
            homestar.js \
            app/*.js \
            bin/homestar \
            bin/commands \
            dynamic static interactors \
        | ( cd "${NPM_DST}" && tar xvf - && npm publish ) || exit 1

        git commit -m "new release" package.json || exit 1
        git push || exit 1

        echo "end"
    )
fi
