cp -r ./source/* ../jassassin/source/source
cp -r ./themes/wixo/* ../jassassin/source/wixo
cp   ./_config.yml ../jassassin/source
cp   ./*.sh ../jassassin/source
cd ../jassassin
git checkout source
git add ./source/*
git status
git commit -m "backup wiki source"
git push


