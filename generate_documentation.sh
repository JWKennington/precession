#Usage: bash generate_documentation.sh [-h|--help] [-web]

web=0
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "Usage: bash generate_documentation.sh [options]"
                        echo " "
                        echo "Generate automatic html documentation using pdoc"
                        echo "pdoc is available here https://github.com/BurntSushi/pdoc"
                        echo "and can be installed from Pypi: pip install pdoc."
                        echo "If -web, documentation is pushed to a dedicated git branch (gh-pages)"
                        echo "and published at http://dgerosa.github.io/precession/"
                        echo " "
                        echo "options:"
                        echo "-h, --help       show brief help"
                        echo "-web             push documentation to http://dgerosa.github.io/precession/"
                        exit 0
                        ;;
                -web)
                        shift
                        web=1
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done


if [ $web -eq 1 ]; then

    # Start from master
    git checkout master

    # Be sure your working branch is clean
    if [ "$(git status --porcelain)" ]; then 
      echo "Please, clean your working directory first."
      exit 1
    else 
      echo "Generating documentation, updating website"; 
    fi

# Check version of the code seen by pdoc
python <<END
import precession
print "Python module precession, version", precession.__version__
END

    # Generate documentation using pdc
    pdoc --html --overwrite precession
    # Get rid of precompiled files
    rm precession/*pyc precession/*/*pyc

    # Move html files somewhere else
    temp1=`mktemp`
    cp precession/index.html $temp1
    temp2=`mktemp`
    cp precession/test/index.html $temp2

    # Commit new html to master branch
    git add *
    git commit -m "generate_documentation.sh"
    git push

    # Move html files to gh-pages branch (directories there should exist)
    git checkout gh-pages
    mv $temp1 index.html
    mv $temp2 test/index.html

    # Commit new html to gh-pages branch
    git add *
    git commit -m "generate_documentation.sh"
    git push

    # Get rid of temp files
    rm -f $temp1 $temp2

    # Back to master
    git checkout master

else
    echo "Generating documentation, local only"; 
    pdoc --html --overwrite precession
    rm precession/*pyc precession/*/*pyc

fi